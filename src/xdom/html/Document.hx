package xdom.html;

import js.html.HTMLDocument as Doc;

@:build(xdom.macros.Build.events(([tink.domspec.Events]:Document)))
@:forward
abstract Document(Wrapped<Doc>) from Doc from Wrapped<Doc> {
  public var body(get, never):Wrapped<js.html.BodyElement>;
    inline function get_body() 
      return (this.body:Wrapped<js.html.BodyElement>);

  public function getElementById(id:String):Element
    return this.getElementById(id);

  @:to function toNode():Node
    return (this:js.html.Node);

  //TODO: getElementsByTagName
}