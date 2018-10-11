package xdom;

import js.html.*;

class XDom {
  static public var window(default, never):Window = js.Browser.window;
  static public var document(default, never):xdom.html.Document = js.Browser.document;
  static public var console(default, never):pick.First<"ConsoleInstance", "Console"> = js.Browser.console;

  static public inline function alert(v:Dynamic) js.Browser.alert(v);

  static public inline function X<T:Node>(value:T):Wrapped<T> return value;
}