require 'spec_helper'
require 'ripl/shell_commands'

describe Ripl::ShellCommands do
  describe "PATHS" do
    subject { described_class::PATHS }

    it "should parse ENV['PATH']" do
      subject.join(File::PATH_SEPARATOR).should == ENV['PATH']
    end
  end

  describe "EXECUTABLES" do
    subject { described_class::EXECUTABLES }

    it "should determine if an executable exists in PATHS" do
      subject['dir'].should be_true
    end

    it "should ignore non-executable files" do
      subject['brltty-config'].should be_false
    end

    it "should ignore aliases" do
      subject['cd'].should be_false
    end
  end

  describe "PATTERN" do
    subject { described_class::PATTERN }

    it "should match !commands" do
      subject.should =~ "!ls"
    end

    it "should not match leading whitespace" do
      subject.should_not =~ "  !ls"
    end

    it "should not match commands beginning with decimals" do
      subject.should_not =~ "!10"
    end

    it "should not match commands beginning with punctuation" do
      subject.should_not =~ "!["
    end
  end

  describe "parse" do
    it "should commands into the command name and additional arguments" do
      subject.parse("echo foo").should == ['echo', ['foo']]
    end

    it "should respect single quoted Strings" do
      subject.parse("echo 'foo bar'").should == ['echo', ['foo bar']]
    end

    it "should respect double quoted Strings" do
      subject.parse("echo \"foo bar\"").should == ['echo', ['foo bar']]
    end

    it "should respect escaped characters" do
      subject.parse("echo foo\\ bar").should == ['echo', ['foo bar']]
    end

    context "when \#{ } is present" do
      let(:variable) { 'x'  }
      let(:value)    { '42' }
      before(:all) do
        eval("#{variable} = #{value}",Ripl.shell.binding)
      end

      it "should evaluate each embedded expression in the Ripl shell" do
        subject.parse("echo \#{x}").should == ['echo', [value]]
      end
    end
  end

  describe "executable?" do
    let(:path) { `which dir`.chomp }

    it "should not be true for regular files" do
      subject.executable?('README.md').should be_false
    end

    it "should not be true for directories" do
      subject.executable?('.').should be_false
    end

    it "should be true for executables" do
      subject.executable?(path).should be_true
    end
  end

  describe "exec" do
    it "should execute commands" do
      subject.exec('true').should be_true
    end

    it "should allow redirecting output" do
      subject.exec('echo foo >/dev/null').should be_true
    end

    it "should return the exit status" do
      subject.exec('false').should be_false
    end
  end

  describe "cd" do
    let(:old)    { Dir.pwd }
    let(:dir)    { ENV['HOME'] }

    before(:all) { subject.cd(dir) }
    after(:all)  { Dir.chdir(old)  }

    it "should change the current working directory" do
      Dir.pwd.should == dir
    end

    it "should update ENV['OLDPWD']" do
      ENV['OLDPWD'].should_not == old
    end

    context "when given no arguments" do
      before(:all) { subject.cd }

      it "should switch back to the current working directory" do
        Dir.pwd.should == ENV['HOME']
      end
    end

    context "when given -" do
      before(:all) { subject.cd('-') }

      it "should switch back to the current working directory" do
        Dir.pwd.should == old
      end
    end
  end

  describe "export" do
    context "when given NAME=VALUE pairs" do
      let(:name)  { 'FOO' }
      let(:value) { '1' }

      before(:all) { subject.export("#{name}=#{value}") }

      it "should set ENV[NAME] to VALUE" do
        ENV[name].should == value
      end
    end

    context "when given NAME= pairs" do
      let(:name)  { 'BAR' }

      before(:all) { subject.export("#{name}=") }

      it "should set ENV[NAME] to ''" do
        ENV[name].should == ''
      end
    end
  end

  describe "#loop_eval" do
    subject { Ripl.shell }

    it "should eval normal Ruby input" do
      subject.eval_input('1 + 1').should == 2
    end

    it "should execut !commands" do
      subject.eval_input('!dir >/dev/null').should be_true
    end

    it "should not execute blacklisted !commands" do
      subject.eval_input('!true').should be_false
    end

    it "should not execut !commands within multi-line input" do
      lines = [
        '1 + 1',
        '!true',
        '2 + 2'
      ]

      subject.eval_input(lines.join($/)).should == 4
    end
  end
end
