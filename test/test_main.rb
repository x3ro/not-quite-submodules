require 'helper'

class Test < MiniTest::Unit::TestCase

  def test_in_dir
    pwd = Dir.pwd
    NotQuiteSubmodules.in_dir('./lib') do
      assert_equal File.expand_path('./lib', pwd), Dir.pwd
    end
    assert_equal pwd, Dir.pwd
  end

  def test_execute_command
    assert_equal "test", NotQuiteSubmodules.execute_command("echo -n test")
    assert_raises(RuntimeError) { NotQuiteSubmodules.execute_command("bogus_command_42") }
  end

end
