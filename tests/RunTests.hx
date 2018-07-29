package ;

import xdom.XDom.*;

class RunTests {
  static function main() {
    var c = document.body.find('input');
    $type(c);
    c.each(e -> e.checked = false);
  }
  
}