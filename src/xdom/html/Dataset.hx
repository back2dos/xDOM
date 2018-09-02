package xdom.html;

@:forward
abstract Dataset(Dynamic<DatasetValue>) {
  @:arrayAccess inline function __getProperty(name:String):DatasetValue
    return (untyped this[name]:DatasetValue);

  @:arrayAccess inline function __setProperty(name:String, value:DatasetValue):DatasetValue
    return untyped this[name] = value;

  public inline function keys()
    return untyped Object.getOwnPropertyNames(this);

  public inline function toggle(name:String, ?force:Bool)
    __setProperty(name, if (force == null) !__getProperty(name) else !force);
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