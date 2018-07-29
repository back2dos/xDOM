package teapot;

#if macro
import haxe.macro.Context.*;
using haxe.macro.Tools;
using tink.MacroApi;
#end

abstract EventType<T>(String) to String {
  
  inline function new(s:String)
    this = s;

  static var SUGGESTION = ~/\(Suggestion: (.*)\)/;
  static var SUGGESTIONS = ~/\(Suggestions: (.*)\)/;

  @:from static macro function ofString(s:String) {
    var pos = currentPos();

    var types = [
      for (part in s.split(' '))
        if (part != '') {
          var event = 'on$part';
          var type = followWithAbstracts(
            switch (
              (macro 
                (function (x) {
                  @:pos(pos) (null:tink.domspec.Events<js.html.Element>).$event.invoke(x);
                  return x;
                })(null)
              ).typeof()
            ) {
              case Success(v): v;
              case Failure(e): 
                var suggestion = 
                  if (SUGGESTION.match(e.message)) ' (Suggestion: ${SUGGESTION.matched(1).substr(2)})';
                  else if (SUGGESTIONS.match(e.message)) ' (Suggestions: ${SUGGESTIONS.matched(1).substr(2).split(", on").join(", ")})';
                  else '';
                e.pos.error('unknown event $s$suggestion');
            }
          ).toComplexType();

          macro @:pos(pos) (null:$type);
        }
    ];
    var type = typeof(macro @:pos(pos) $a{types}[0]).toComplexType();

    return macro @:pos(pos) (@:privateAccess new teapot.EventType<$type>($v{s}): teapot.EventType<$type>);
  }
}