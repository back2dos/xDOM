package xdom.html;

import tink.domspec.EventFrom as Evt;

@:callable
abstract EventSource<T, E:js.html.Event>(Callback<Evt<T, E>>->CallbackLink) {

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
}