### 0.1.0 / 2012-12-02

* Initial release
  * Extracted from [ronin](https://github.com/ronin-ruby/ronin).
  * Use `Ripl.shell.binding` instead of `Ripl.config[:binding]`, which is not
    set when running the `ripl` executable.
  * No longer use `singleton_class.method_defined?` (Ruby 1.9 only) in
    {Ripl::ShellCommands#loop_eval}.
  * No longer use `Shellwords.shelljoin` in {Ripl::ShellCommands.exec},
    which was re-escaping all arguments.
  * Added specs.

