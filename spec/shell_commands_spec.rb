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
end
