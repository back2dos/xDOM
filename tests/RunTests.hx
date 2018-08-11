package ;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class RunTests {
  static function main() {
    var tests = TestBatch.make([    
    ]);
    Runner.run(tests).handle(Runner.exit);
  }
  
}