package xdom;

class XDom {
  static public var document(default, never):WrappedDoc = js.Browser.document;
  static public var console(default, never) = js.Browser.console;

  static public inline function alert(v:Dynamic) js.Browser.alert(v);

  static public function X<T:js.html.Node>(value:T):Wrapped<T> return value;
}

@:forward
private abstract WrappedDoc(Wrapped<js.html.HTMLDocument>) from js.html.HTMLDocument {
  public var body(get, never):Wrapped<js.html.BodyElement>;
    function get_body() 
      return (this.body:Wrapped<js.html.BodyElement>);
}