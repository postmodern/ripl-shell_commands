require 'set'
require 'shellwords'
require 'ripl'

module Ripl
  #
  # Allows for executing shell commands prefixed by a `!`.
  #
  module ShellCommands
    # The directories of `$PATH`.
    PATHS = ENV['PATH'].split(File::PATH_SEPARATOR)

    # Names and statuses of executables.
    EXECUTABLES = Hash.new do |hash,key|
      hash[key] = executable?(key) || PATHS.any? do |dir|
        executable?(File.join(dir,key))
      end
    end

    # Builtin commands
    BUILTIN = Set['cd', 'export']

    # Blacklist of known commands that conflict with Ruby keywords.
    BLACKLIST = Set[
      '[', 'ap', 'begin', 'case', 'class', 'def', 'fail', 'false',
      'for', 'if', 'lambda', 'load', 'loop', 'module', 'p', 'pp',
      'print', 'proc', 'puts', 'raise', 'require', 'true', 'undef',
      'unless', 'until', 'warn', 'while'
    ]

    # Regexp to recognize `!commands`.
    PATTERN = /^![a-zA-Z][a-zA-Z0-9\._-]*/

    #
    # Dynamically execute shell commands, instead of Ruby.
    #
    # @param [String] input
    #   The input from the console.
    #
    def loop_eval(input)
      if (@buffer.nil? && input =~ PATTERN)
        command = input[1..-1]
        name, arguments = ShellCommands.parse(command)

        unless BLACKLIST.include?(name)
          if BUILTIN.include?(name)
            arguments ||= []

            return ShellCommands.send(name,*arguments)
          elsif EXECUTABLES[name]
            return ShellCommands.exec(name,*arguments)
          end
        end
      end

      super(input)
    end

    #
    # Parses a Console command.
    #
    # @param [String] command
    #   The Console command to parse.
    #
    # @return [String, Array<String>]
    #   The command name and additional arguments.
    #
    def self.parse(command)
      # evaluate embedded Ruby expressions
      command = command.gsub(/\#\{[^\}]*\}/) do |expression|
        eval(expression[2..-2],Ripl.shell.binding).to_s.dump
      end

      arguments = Shellwords.shellsplit(command)
      name      = arguments.shift

      return name, arguments
    end

    #
    # Determines if an executable exists on the system.
    #
    # @param [String] path
    #   The program path.
    #
    # @return [Boolean]
    #   Specifies whether the executable exists.
    #
    def self.executable?(path)
      File.file?(path) && File.executable?(path)
    end

    #
    # Default command which executes a command in the shell.
    #
    # @param [Array<String>] arguments
    #   The arguments of the command.
    #
    # @return [Boolean]
    #   Specifies whether the command exited successfully.
    #
    def self.exec(*arguments)
      system(Shellwords.shelljoin(arguments))
    end

    #
    # Equivalent of the `cd` command, using `Dir.chdir`.
    #
    # @param [Array<String>] arguments
    #   The arguments of the command.
    #
    # @return [Boolean]
    #   Specifies whether the directory change was successful.
    #
    def self.cd(*arguments)
      old_pwd = Dir.pwd

      new_cwd = if arguments.empty?
                  unless ENV['HOME']
                    warn "cd: HOME not set"
                    return false
                  end

                  ENV['HOME']
                elsif arguments.first == '-'
                  unless ENV['OLDPWD']
                    warn 'cd: OLDPWD not set'
                    return false
                  end

                  ENV['OLDPWD']
                else
                  arguments.first
                end

      Dir.chdir(new_cwd)
      ENV['OLDPWD'] = old_pwd
      return true
    end

    #
    # Equivalent of the `export` or `set` commands.
    #
    # @param [Array<String>] arguments
    #   The arguments of the command.
    #
    # @return [true]
    #
    def self.export(*arguments)
      arguments.each do |pair|
        name, value = pair.split('=',2)

        ENV[name] = value
      end
    end
  end
end

Ripl::Shell.send :include, Ripl::ShellCommands
