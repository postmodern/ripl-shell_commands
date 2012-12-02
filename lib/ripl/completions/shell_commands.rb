complete(:on => Ripl::ShellCommands::PATTERN) do |cmd|
  name   = cmd[1..-1]
  glob   = "#{name}*"
  paths  = Set[]

  # search through the BUILTIN command names
  Ripl::ShellCommands::BUILTIN.each do |command|
    if command.start_with?(name)
      paths << "!#{command}"
    end
  end

  # search through $PATH for similar program names
  Ripl::ShellCommands::PATHS.each do |dir|
    Dir.glob(File.join(dir,glob)) do |path|
      if (File.file?(path) && File.executable?(path))
        paths << "!#{File.basename(path)}"
      end
    end
  end

  # add the black-listed keywords last
  Ripl::ShellCommands::BLACKLIST.each do |keyword|
    paths << "!#{keyword}" if keyword.start_with?(name)
  end

  paths
end
