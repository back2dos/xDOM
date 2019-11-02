package xdom;

import js.html.*;

#if !haxe4
  typedef ConsoleInstance = Console;
#end

class XDom {
  static public var window(default, never):Window = js.Browser.window;
  static public var document(default, never):xdom.html.Document = js.Browser.document;
  static public var console(default, never):ConsoleInstance = js.Browser.console;

  static public inline function alert(v:Dynamic) js.Browser.alert(v);

  static public inline function X<T:Node>(value:T):Wrapped<T> return value;
}