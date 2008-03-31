require "ev/ftools"
require "rbconfig"

exit	if __FILE__ == $0

module RUBYSCRIPT2EXE
end

module REQUIRE2LIB
  JUSTRUBYLIB	= ARGV.include?("--require2lib-justrubylib")
  JUSTSITELIB	= ARGV.include?("--require2lib-justsitelib")
  RUBYGEMS	= (not JUSTRUBYLIB)
  VERBOSE	= ARGV.include?("--require2lib-verbose")
  QUIET		= (ARGV.include?("--require2lib-quiet") and not VERBOSE)
  LOADED	= []

  ARGV.delete_if{|arg| arg =~ /^--require2lib-/}

  ORGDIR	= Dir.pwd
  THISFILE	= File.expand_path(__FILE__)
  LIBDIR	= File.expand_path((ENV["REQUIRE2LIB_LIBDIR"] or "."))
  LOADSCRIPT	= File.expand_path((ENV["REQUIRE2LIB_LOADSCRIPT"] or "."))
  RUBYLIBDIR	= Config::CONFIG["rubylibdir"]
  SITELIBDIR	= Config::CONFIG["sitelibdir"]

  at_exit do
    Dir.chdir(ORGDIR)

    REQUIRE2LIB.gatherlibs
  end

  def self.gatherlibs
    $stderr.puts "Gathering files..."	unless QUIET

    File.makedirs(LIBDIR)

    if RUBYGEMS
      begin
        Gem.dir
        rubygems	= true
      rescue NameError
        rubygems	= false
      end
    else
      rubygems		= false
    end

    pureruby	= true

    if rubygems
      require "fileutils"	# Hack ???

      requireablefiles	= []

      Dir.mkdir(File.expand_path("rubyscript2exe.gems", LIBDIR))
      Dir.mkdir(File.expand_path("rubyscript2exe.gems/gems", LIBDIR))
      Dir.mkdir(File.expand_path("rubyscript2exe.gems/specifications", LIBDIR))

      Gem::Specification.list.each do |gem|
        if gem.loaded?
          $stderr.puts "Found gem #{gem.name} (#{gem.version})."	if VERBOSE

          fromdir	= File.join(gem.installation_path, "specifications")
          todir		= File.expand_path("rubyscript2exe.gems/specifications", LIBDIR)

          fromfile	= File.join(fromdir, "#{gem.full_name}.gemspec")
          tofile	= File.join(todir, "#{gem.full_name}.gemspec")

          File.copy(fromfile, tofile)

          fromdir	= gem.full_gem_path
          todir		= File.expand_path(File.join("rubyscript2exe.gems/gems", gem.full_name), LIBDIR)

          Dir.copy(fromdir, todir)

          Dir.find(todir).each do |file|
            if File.file?(file)
              gem.require_paths.each do |lib|
                unless lib.empty?
                  lib	= File.expand_path(lib, todir)
                  lib	= lib + "/"

                  requireablefiles << file[lib.length..-1]	if file =~ /^#{lib}/
                end
              end
            end
          end
        end
      end
    end

    ($" + LOADED).each do |req|
      catch :found do
        $:.each do |lib|
          fromfile	= File.expand_path(req, lib)
          tofile	= File.expand_path(req, LIBDIR)

          if File.file?(fromfile)
            unless fromfile == tofile or fromfile == THISFILE
              unless (rubygems and requireablefiles.include?(req))	# ??? requireablefiles might be a little dangerous.
                if (not JUSTRUBYLIB and not JUSTSITELIB) or
                   (JUSTRUBYLIB and fromfile.include?(RUBYLIBDIR)) or
                   (JUSTSITELIB and fromfile.include?(SITELIBDIR))
                  $stderr.puts "Found #{fromfile} ."		if VERBOSE

                  File.makedirs(File.dirname(tofile))	unless File.directory?(File.dirname(tofile))
                  File.copy(fromfile, tofile)

                  pureruby	= false	unless req =~ /\.(rbw?|ruby)$/i
                else
                  $stderr.puts "Skipped #{fromfile} ."	if VERBOSE
                end
              end
            end

            throw :found
          end
        end

        #$stderr.puts "Can't find #{req} ."	unless req =~ /^ev\// or QUIET
        #$stderr.puts "Can't find #{req} ."	unless req =~ /^(\w:)?[\/\\]/ or QUIET
      end
    end

    $stderr.puts "Not all required files are pure Ruby."	unless pureruby	if VERBOSE

    unless LOADSCRIPT == ORGDIR
      File.open(LOADSCRIPT, "w") do |f|
        f.puts "module RUBYSCRIPT2EXE"
        RUBYSCRIPT2EXE.class_variables.each do |const|
          const	= const[2..-1]
          f.puts "  #{const.upcase}=#{RUBYSCRIPT2EXE.send(const).inspect}"
        end
        f.puts "  RUBYGEMS=#{rubygems.inspect}"
        f.puts "end"
      end
    end
  end
end

module Kernel
  alias :old_load :load
  def load(filename, wrap=false)
    REQUIRE2LIB::LOADED << filename	unless REQUIRE2LIB::LOADED.include?(filename)

    old_load(filename, wrap)
  end
end
