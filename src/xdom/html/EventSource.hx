package xdom.html;

#if macro
import haxe.macro.*;

typedef Evt<X, Y> = Dynamic;
typedef NativeEvent = Dynamic;
#else
import tink.domspec.EventFrom as Evt;
import js.html.Event as NativeEvent;
#end

@:callable
abstract EventSource<T, E:NativeEvent>(Callback<Evt<T, E>>->CallbackLink) {

  #if !macro
  inline function new(f) this = f;

  public function once(c:Callback<Evt<T, E>>) {
    var link:CallbackLink = null;
    link = this(function (v) {
      c.invoke(v);
      link.dissolve();
      c = null;
      link = null;
    });
    return link;
  }

  @:to public function toSignal():Signal<Evt<T, E>>
    return Signal.create({
      var link:CallbackLink = null;
      {
        activate: function (cb) link = this(cb),
        suspend: function () link.dissolve()
      }
    });

  public function map<R>(f:Evt<T, E>->R)
    return toSignal().map(f);

  @:noCompletion public function delegate<C>(s:Selector<C>, cb:Callback<Evt<C, E>>):CallbackLink {
    return this(function (e) {
      var root:js.html.Element = cast e.currentTarget,
          cur:js.html.Element = e.target;

      while (cur != null) {
        if (cur.matches(s)) {
          //perhaps Object.assign is better here
          var Event:Class<Dynamic> = cast function () {
            js.Lib.nativeThis.currentTarget = cur;
          }
          untyped Event.prototype = e;

          cb.invoke(js.Syntax.construct(Event));
        }
        if (cur == root) break;
        cur = cur.parentElement;
      }

    });
  }

  @:noCompletion 
  static public function make<T, E:NativeEvent>(target:T, event:String)
    return 
      if (target != null && untyped target.children != null) {
        var target:js.html.Element = cast target;
        new EventSource<T, E>(function (cb) {
          function handle(event) cb.invoke(event);
          target.addEventListener(event, handle);
          return target.removeEventListener.bind(event, handle);
        });
      }
      else {
        #if debug
        console.warning('attempted to register `$event` event on', target);
        #end
        new EventSource<T, E>(function (cb) return null);
      }
  #end

  macro public function within(ethis, selector, ?cb) {
    function delegate(cb)
      return macro @:pos(Context.currentPos()) $ethis.delegate(xdom.Selector.parse($selector), $cb);

    return switch cb {
      case null | macro null:
        macro @:pos(Context.currentPos()) {
          var __link = null;
          tink.core.Signal.create({
            activate: function (cb) __link = ${delegate(macro cb)},
            suspend: function () __link.dissolve()
          });
        }
      default:
        delegate(cb);
    }
  }
  
}