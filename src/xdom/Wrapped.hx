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

#if !macro
@:build(xdom.macros.Build.events(([tink.domspec.Events]:Wrapped<T>)))
#end
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

  public var children(get, never):Collection<Element>;
    inline function get_children()
      return (untyped this.children || [] : Collection<Element>);

  public var dataset(get, never):Dataset;
    inline function get_dataset()
      return (untyped this.dataset || {} : Dataset);

  //TODO: firstChild, firstElementChild, ...
  @:noCompletion public function qsa<R>(selector:Selector<R>):Collection<R> 
    return
      if (this != null && untyped this.querySelectorAll != null) {
        if (this == cast document) cast document.querySelectorAll(selector);
        else {
          var e:js.html.Element = cast this;
          cast (
            if (e.matches(selector))
              [e]
            else 
              []
          ).concat(
            (cast e.querySelectorAll(Selector.prefixed(e, selector)) : Collection<js.html.Element>)
          );
        }
      }
      else Collection.empty();
  
  @:to static function upcast<T:js.html.Node>(w:Wrapped<T>):Wrapped<js.html.Node>
    return cast w;
  #end
}