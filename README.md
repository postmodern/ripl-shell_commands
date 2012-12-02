# ripl-shell_commands

* [Homepage](https://github.com/postmodern/ripl-shell_commands#readme)
* [Issues](https://github.com/postmodern/ripl-shell_commands/issues)
* [Documentation](http://rubydoc.info/gems/ripl-shell_commands/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

A [ripl] plugin that allows inline shell commands.

## Features

## Examples

    >> require 'ripl/shell_commands'
    => true
    >> !date
    Sat Dec  1 21:47:55 PST 2012
    => true
    >> !cd /etc/
    => true
    >> @path = '/etc/profile.d/'
    => "/etc/profile.d/"
    >> !ls #{@path}
    bash_completion.sh  colorls.csh  less.sh                qt.sh
    chgems.sh           colorls.sh   PackageKit.sh          vim.csh
    chruby.sh           lang.csh     qt.csh                 vim.sh
    colorgrep.csh       lang.sh      qt-graphicssystem.csh  which2.csh
    colorgrep.sh        less.csh     qt-graphicssystem.sh   which2.sh
    >> true

## Requirements

* [Ruby] >= 1.9.1
* [ripl] ~> 0.3

## Install

    $ gem install ripl-shell_commands

## Copyright

Copyright (c) 2012 Hal Brodigan

See {file:LICENSE.txt} for details.

[Ruby]: http://www.ruby-lang.org/
[ripl]: https://github.com/cldwalker/ripl#readme
