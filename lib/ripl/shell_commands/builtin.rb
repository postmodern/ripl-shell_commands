module Ripl
  module ShellCommands
    module Builtin
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
end
