package xdom.html;

#if macro
  import haxe.macro.*;
#end

abstract Collection<T>(Array<T>) {//This is actually never an Array but rather an HTMLCollection or NodeList or something, but since we're only using length and array access it's fine
  public var length(get, never):Int;
    inline function get_length() return this.length;

  @:arrayAccess inline function get(index:Int):T
    return (cast this[index] : T);

  @:extern public inline function each(f:T->Void)
    for (i in 0...this.length) f(cast this[i]);

  @:to public function toArray():Array<T>
    return untyped Array.prototype.slice(this);

  macro public function find(ethis:Expr, selector:Expr) 
    return macro @:pos(Context.currentPos()) $ethis.qsa(xdom.Selector.parse($selector));

  #if !macro
  @:noCompletion public function qsa<R>(selector:Selector<R>):Collection<R> {
    var ret = [];
    for (e in this)
      ret = ret.concat(cast (cast e:Node).qsa(selector));
    return cast ret;
  }
  #end
}