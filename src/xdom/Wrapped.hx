package xdom;

#if macro 
  import haxe.macro.*;
#else
  import js.html.*;
  import xdom.html.*;
  import js.html.Node.*;
#end


private typedef Native = 
  #if macro {} #else js.html.Node #end

@:forward
abstract Wrapped<T:Native>(T) from T to T {

  macro public function find(ethis:Expr, selector:Expr) 
    return macro @:pos(Context.currentPos()) $ethis.qsa(xdom.Selector.parse($selector));

  macro public function each(ethis:Expr, selector:Expr, cb) 
    return macro @:pos(Context.currentPos()) $ethis.qsa(xdom.Selector.parse($selector)).each($cb);



  #if !macro
  public var nodeList(get, never):Collection<Node>;
    inline function get_nodeList()
      return (untyped this.nodeList || [] : Collection<Node>);

  public var elements(get, never):Collection<Element>;
    inline function get_elements()
      return (untyped this.elements || [] : Collection<Element>);

  public var dataset(get, never):Dataset;
    inline function get_dataset()
      return (untyped this.dataset || {} : Dataset);

  @:noCompletion public function qsa<R>(selector:Selector<R>):Collection<R>
    return 
      try cast (cast this:js.html.Element).querySelectorAll(selector)
      catch (e:Dynamic) cast EMPTY;//not sure if silent pokemon clause is really reasonable here

  static var EMPTY = [];
  #end
}

#if !macro
@:forward
abstract Dataset(Dynamic<DatasetValue>) {
  @:arrayAccess inline function __getProperty(name:String):DatasetValue
    return js.Syntax.field(this, name);

  @:arrayAccess inline function __setProperty(name:String, value:DatasetValue):DatasetValue
    return untyped this[name] = value;

  public inline function keys()
    return untyped Object.getOwnPropertyNames(this);

  public inline function toggle(name:String, ?force:Bool)
    __setProperty(name, if (force == null) !__getProperty(name) else !force);
}

abstract If<Cond, Cons, Alt, Ret>(Dynamic) {
  @:from static function negative<Cond, Cons, Ret>(v:Class<Void>):If<Cond, Cons, Ret, Ret>
    return cast null;

  @:from static function positive<Cond, Alt, Ret>(v:Cond):If<Cond, Ret, Alt, Ret>
    return cast null;

}

@:forward
abstract DatasetValue(String) from String {

  @:to inline function toInt()
    return Std.parseInt(this);

  @:to inline function toFloat()
    return Std.parseFloat(this);

  @:to inline function toFlag()
    return this != null;

  @:from static inline function ofFlag(flag:Bool):DatasetValue
    return if (flag) '' else null;

  @:from static inline function ofNumber(f:Float):DatasetValue
    return if (Math.isNaN(f)) null else Std.string(f);

  @:op(!a) static inline function not(v:DatasetValue):Bool
    return v != null;

  @:op(a || b) static inline function lOrBool(v:DatasetValue, b:Bool):Bool
    return v != null || b;

  @:op(a || b) static inline function rOrBool(b:Bool, v:DatasetValue):Bool
    return b || v != null;

  @:op(a || b) static inline function lOr(v:DatasetValue, w:DatasetValue):Bool
    return v != null || w != null;

  @:op(a && b) static inline function lAndBool(v:DatasetValue, b:Bool):Bool
    return v != null && b;

  @:op(a && b) static inline function rAndBool(b:Bool, v:DatasetValue):Bool
    return b && v != null;

  @:op(a && b) static inline function lAnd(v:DatasetValue, w:DatasetValue):Bool
    return v != null && w != null;

}
#end