# test::unit::ui::console::testrunner
require "test/unit/ui/console/testrunner"

module BeQuietOnEmptyTests
  def output?(level)
    !@suite.tasks.empty? && super
    #level <= @output_level
  end
end

Test::Unit::UI::Console::TestRunner.send :include, BeQuietOnEmptyTests
