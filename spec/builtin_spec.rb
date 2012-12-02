require 'spec_helper'
require 'ripl/shell_commands/builtin'

describe Ripl::ShellCommands::Builtin do
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
