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

  public function once(c:Callback<Evt<T, E>>):CallbackLink
    return @:privateAccess EventSignal.callOnce(this, c);

  public var signal(get, never):Signal<Evt<T, E>>;

  @:to function get_signal():Signal<Evt<T, E>> {
    var self:Dynamic = this;
    if (self.__xdomSignal == null)
      self.__xdomSignal = Signal.create(
        function (cb) return this(cb)
      );
    return self.__xdomSignal;
  }

  public function map<R>(f:Evt<T, E>->R):Signal<R>
    return signal.map(f);

  public function filter(f:Evt<T, E>->Bool):Signal<Evt<T, E>>
    return signal.filter(f);

  public function select<R>(f:Evt<T, E>->Option<R>):Signal<R>
    return signal.select(f);

  public function join(other:Signal<Evt<T, E>>):Signal<Evt<T, E>>
    return signal.join(other);

  public function nextTime(?condition:Evt<T, E>->Bool):Future<Evt<T, E>>
    return signal.nextTime(condition);

  @:noCompletion public function delegate<C>(s:Selector<C>, cb:Callback<Evt<C, E>>):CallbackLink {
    var prefixed = null;
    return this(function (e) {
      var root:js.html.Element = cast e.currentTarget,
          cur:js.html.Element = e.target;

      if (prefixed == null)
        prefixed = Selector.prefixed(root, s, true);

      while (cur != null) {
        if (cur.matches(prefixed)) {
          var event:Dynamic = { currentTarget: cur };
          untyped Object.setPrototypeOf(event, e);
          cb.invoke(event);
        }
        if (cur == root) break;
        cur = cur.parentElement;
      }

    });
  }

  @:noCompletion 
  static public function make<T, E:NativeEvent>(target:T, event:String)
    return 
      if (target != null && untyped target.addEventListener != null) {
        var target:js.html.Element = cast target;
        new EventSource<T, E>(function (cb) {
          function handle(event) cb.invoke(event);
          target.addEventListener(event, handle);
          return target.removeEventListener.bind(event, handle);
        });
      }
      else {
        #if debug
        console.warn('attempted to register `$event` event on', target);
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
          xdom.html.EventSource.EventSignal.of(tink.core.Signal.create(
            function (cb) return ${delegate(macro cb)}
          ));
        }
      default:
        delegate(cb);
    }
  }
  
}

@:forward
abstract EventSignal<T>(Signal<T>) from Signal<T> to Signal<T> {
  public function once(c:Callback<T>):CallbackLink 
    return callOnce(this.handle, c);

  @:noCompletion
  static public inline function of<T>(s:Signal<T>):EventSignal<T>
    return (s:EventSignal<T>);

  @:extern static inline function callOnce<X>(register:Callback<X>->CallbackLink, c:Callback<X>) {
    var link:CallbackLink = null;
    link = register(function (v) {
      c.invoke(v);
      link.dissolve();
      c = null;
      link = null;
    });
    return link;
  }
}