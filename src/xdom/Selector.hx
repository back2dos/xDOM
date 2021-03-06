package xdom;

#if macro
  import haxe.macro.Expr;
  import haxe.macro.Context;
  import tink.domspec.Macro.tags;
  using tink.MacroApi;
#end

abstract Selector<T>(String) to String {

  inline function new(s)
    this = s;

  static public macro function parse(e:Expr) {
    var found = {
      var unique = new Map(),
          universal = false;
      for (s in tink.csss.Parser.parse(e.getString().sure(), e.pos).sure()) {
        for (t in s)
          if (t.tag != null && !tags.exists(t.tag))
            e.reject('unknown tag ${t.tag}');
        switch s[s.length - 1].tag {
          case null: universal = true;
          case v: unique[v] = true;
        }
      }
      if (universal) [];
      else [for (t in unique.keys()) t];
    }

    var type = switch found {
      case [tag]:
        tags[tag].domCt;
      default: macro : js.html.Element;
    }

    return macro @:pos(e.pos) @:privateAccess new xdom.Selector<xdom.Wrapped<$type>>($e);
  }

  #if js
    static var hasScope =
      try {
        document.body.querySelectorAll(':scope>*');
        true;
      }
      catch (e:Dynamic)
        false;

    static var ns:Int = untyped (window._xdom_ns = (window._xdom_ns | 0) + 1);//in the unlikely but not impossible case that independently compiled xdom based js files are running in the same page
    static var counter = 0;

    static public function prefixed(scope:js.html.Element, selector:String, ?forceId:Bool) {

      if (scope.nodeType != js.html.Node.ELEMENT_NODE) return selector;

      var prefix =
        switch scope.id {
          case null, '':
            if (forceId || !document.documentElement.contains(scope))
              '#'+(scope.id = '_xdom_${ns}_${counter++}');//[data-xdom-id=...] might be a better choice performance wise. Even though it's probably more expensive to query, setting IDs does seem to invalidate layout on IE and Edge
            else if (hasScope) ':scope';
            else {
              var cur = scope;
              var path = [];

              do {
                switch cur.id {
                  case null, '':
                    path.push(cur.tagName);
                  case v:
                    path.push('#$v');
                    break;
                }
                cur = cur.parentElement;
              }
              while (cur != null);
              path.reverse();
              path.join('>');
            }
          case v: '#$v';
        }

      return '$prefix $selector';
    }
    static function __init__()
      #if (haxe_ver >=4) js.Syntax.code( #else untyped __js__( #end '
        if (typeof Element !== "undefined" && !Element.prototype.matches)
          Element.prototype.matches = Element.prototype.msMatchesSelector;
      ');
  #end



}