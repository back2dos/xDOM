package xdom;

#if macro
  import haxe.macro.Expr;
  import haxe.macro.Context;
  using tink.MacroApi;
#end

abstract Selector<T>(String) to String {

  inline function new(s)
    this = s;

  #if macro
    static var types = [
      for (group in Context.getType('tink.domspec.Tags').getFields().sure())
        for (f in group.type.getFields().sure())
          f.name => switch f.type.getID(false).split('.').pop().split('Attr')[0] {
            case 'Global': macro : js.html.Element;
            case v: 'js.html.${v}Element'.asComplexType();
          }
    ];
  #end
  static public macro function parse(e:Expr) {
    var tags = {
      var unique = new Map();
      for (s in tink.csss.Parser.parse(e.getString().sure(), e.pos).sure()) {
        for (t in s)
          if (!types.exists(t.tag)) e.reject('unknown tag ${t.tag}');
        unique[s[s.length - 1].tag] = true;
      }
      [for (t in unique.keys()) t];
    }

    var type = switch tags {
      case [tag]:
        types[tag];
      default: macro : js.html.Element;
    }
    
    return macro @:pos(e.pos) @:privateAccess new xdom.Selector<xdom.Wrapped<$type>>($e);
  }
}