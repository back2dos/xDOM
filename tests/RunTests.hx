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
  
  public function events(test:AssertionBuffer) {
    document.body.innerHTML = '
      <div>
        <button class="foo">1</button>
        <button class="bar">2</button>
        <button class="foo bar">3</button>
        <button class="beeb bop">4</button>
      </div>
    ';

    var roots:Array<xdom.html.Node> = [
      document,
      document.body,
      document.body.firstElementChild
    ];

    for (root in roots) {
      test.assert(root.find('button').length == 4);

      var count = 0;

      root.onclick.once(function () count++);
      root.onclick.within('button.foo').once(function () count++);
      root.onclick.within('button.bar').once(function () count++);
      root.onclick.within('button.foo.bar', function () count++);

      test.assert(count == 0);

      root.find('button.bop')[0].click();

      test.assert(count == 1);

      root.find('button.bop')[0].click();

      test.assert(count == 1);

      document.find('button.foo.bar')[0].click();

      test.assert(count == 4);

      root.find('button.foo.bar')[0].click();

      test.assert(count == 5);

    }

    return test.done();
  }

  public function scoping(test:AssertionBuffer) {

    document.body.innerHTML = '
      <section>
        <div>
          <button></button>
          <section>
            <button></button>
          </section>
        </div>
      </section>
    ';

    var buttons = document.find('button');

    var outer = buttons[0],
        inner = buttons[1];

    test.assert(document.find('div')[0].find('section button').length == 1);

    var counter = 0;
    document.find('div')[0].onclick.within('section button', function () counter++);

    test.assert(counter == 0);

    outer.click();

    test.assert(counter == 0);

    inner.click();

    test.assert(counter == 1);

    return test.done();
  }
}