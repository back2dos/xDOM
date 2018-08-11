package ;

import tink.unit.*;
import tink.testrunner.Runner;
import xdom.XDom.*;

class RunTests {
  static function main() {
    var tests = TestBatch.make([   
      new Basic() 
    ]);
    Runner.run(tests).handle(Runner.exit);
  }
  
}

class Basic {
  public function new() {}
  public function queries(test:AssertionBuffer) {
    document.body.innerHTML = '
      <div>
        <button class="foo">1</button>
        <button class="bar">2</button>
        <button class="foo bar">3</button>
        <button class="beeb bop">4</button>
      </div>
    ';

    test.assert(document.find('button').length == 4);

    var count = 0;

    document.onclick.once(function () count++);
    document.onclick.within('button.foo').once(function () count++);
    document.onclick.within('button.bar').once(function () count++);
    document.onclick.within('button.foo.bar', function () count++);

    test.assert(count == 0);

    document.find('button.bop')[0].click();

    test.assert(count == 1);

    document.find('button.bop')[0].click();

    test.assert(count == 1);

    document.find('button.foo.bar')[0].click();

    test.assert(count == 4);

    document.find('button.foo.bar')[0].click();

    test.assert(count == 5);

    return test.done();
  }
}