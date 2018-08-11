package xdom.macros;

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

using tink.MacroApi;

class Build {
  static function events(e:Expr) {
    var ret = Context.getBuildFields();

    function add(td:TypeDefinition)
      for (f in td.fields) ret.push(f);

    var added = new Map();

    switch e {
      case macro ([$a{types}]:$as):
        for (e in types)
          for (f in e.pos.getOutcome(Context.getType(e.toString()).getFields()))
            if (f.name.startsWith('on') && !added[f.name]) {

              added[f.name] = true;

              var event = {  
                var ct = f.type.toComplex();
                
                var t = Context.followWithAbstracts((macro {
                  var x = null;
                  function handler(_) {};
                  (handler : $ct);
                  handler(x);
                  x;
                }).typeof().sure());

                switch t {
                  case TMono(_): macro : js.html.Event;
                  default: t.toComplex();
                }
              }

              var field = f.name,
                  getter = 'get_${f.name}',
                  type = macro : xdom.html.EventSource<$as, $event>;

              add(macro class {//TODO: use more meaningful positions here
                public var $field(get, never):$type;
                inline function $getter():$type
                  return xdom.html.EventSource.make(this, $v{f.name.substr(2)});
              });
            }
      default: e.reject();
    }
    
    return ret;
  }
}