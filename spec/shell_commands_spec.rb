require 'spec_helper'
require 'ripl/shell_commands'

describe Ripl::ShellCommands do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
