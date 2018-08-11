package xdom;

class XDom {
  static public var document(default, never):xdom.html.Document = js.Browser.document;
  static public var console(default, never):js.html.Console = js.Browser.console;

  static public inline function alert(v:Dynamic) js.Browser.alert(v);

  static public function X<T:js.html.Node>(value:T):Wrapped<T> return value;
}