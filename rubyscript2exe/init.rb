$: << File.dirname(File.expand_path(__FILE__))

$".delete "rubyscript2exe.rb"

if defined?(oldlocation)
  oldlocation do
    require "rubyscript2exe"
  end
else
  require "rubyscript2exe"
end

if __FILE__ == $0

required	= $"
required	= required.reject{|a| File.dirname(a) == ALLINONERUBY::TEMPDIR}	if defined?(ALLINONERUBY::TEMPDIR)
required	= required.collect{|a| "-r '#{a}'"}

require "ev/oldandnewlocation"
require "ev/dependencies"
require "ev/ftools"
require "rbconfig"

exit	if RUBYSCRIPT2EXE.is_compiling?

def backslashes(s)
  s	= s.gsub(/^\.\//, "").gsub(/\//, "\\\\")	if windows?
  s
end

def linux?
  not darwin? and not windows? and not cygwin?
end

def darwin?
  not (target_os.downcase =~ /darwin/).nil?
end

def windows?
  not (target_os.downcase =~ /32/).nil?
end

def cygwin?
  not (target_os.downcase =~ /cyg/).nil?
end

def target_os
  Config::CONFIG["target_os"] or ""
end

def copyto(files, dest)
  [files].flatten.sort.uniq.each do |fromfile|
    tofile	= File.expand_path(File.basename(fromfile), dest)

    $stderr.puts "Copying #{fromfile} ..."	if VERBOSE

    File.copy(fromfile, tofile)			unless File.file?(tofile)
  end
end

RUBY	= ARGV.include?("--rubyscript2exe-ruby")
RUBYW	= ARGV.include?("--rubyscript2exe-rubyw")
NOSTRIP	= ARGV.include?("--rubyscript2exe-nostrip")
STRACE	= ARGV.include?("--rubyscript2exe-strace")
TK	= ARGV.include?("--rubyscript2exe-tk")
VERBOSE	= ARGV.include?("--rubyscript2exe-verbose")
QUIET	= (ARGV.include?("--rubyscript2exe-quiet") and not VERBOSE)

ARGV.delete_if{|arg| arg =~ /^--rubyscript2exe-/}

script	= ARGV.shift

if script.nil?
  usagescript	= "init.rb"
  usagescript	= "rubyscript2exe.rb"	if defined?(TAR2RUBYSCRIPT)
  $stderr.puts <<-EOF

	Usage: ruby #{usagescript} application.rb[w] [--rubyscript2exe-rubyw|--rubyscript2exe-ruby] [--rubyscript2exe-nostrip]
               or
	       ruby #{usagescript} application[/] [--rubyscript2exe-rubyw|--rubyscript2exe-ruby] [--rubyscript2exe-nostrip]

	On Linux and Darwin, there's no difference between ruby and rubyw.

	For more information, see
	http://www.erikveen.dds.nl/rubyscript2exe/index.html .
	EOF

  exit 1
end

bindir1	= Config::CONFIG["bindir"]
libdir1	= Config::CONFIG["libdir"]
bindir2	= tmplocation("bin/")
libdir2	= tmplocation("lib/")
appdir2	= tmplocation("app/")

app	= File.basename(script.gsub(/\.rbw?$/, ""))

$stderr.puts "Tracing #{app} ..."	unless QUIET

libs		= $:.collect{|a| "-I '#{a}'"}
loadscript	= tmplocation("require2lib2rubyscript2exe.rb")
verbose		= (VERBOSE ? "--require2lib-verbose" : "")
quiet		= (QUIET ? "--require2lib-quiet" : "")
argv		= ARGV.collect{|a| "'#{a}'"}

ENV["REQUIRE2LIB_LIBDIR"]	= libdir2
ENV["REQUIRE2LIB_LOADSCRIPT"]	= loadscript

oldlocation do
  unless File.exist?(script)
    $stderr.puts "#{script} doesn't exist."

    exit 1
  end

  apprb	= script		if File.file?(script)
  apprb	= "#{script}/init.rb"	if File.directory?(script)

  unless File.file?(apprb)
    $stderr.puts "#{apprb} doesn't exist."

    exit 1
  end

  command	= backslashes("#{bindir1}/ruby") + " #{required.join(" ")} #{libs.join(" ")} -r '#{newlocation("require2lib.rb")}' '#{apprb}' #{verbose} #{quiet} #{argv.join(" ")}"

  system(command)

  unless File.file?(loadscript)
    $stderr.puts "Couldn't execute this command (rc=#{$?}):\n#{command}"
    $stderr.puts "Stopped."

    exit 16
  end
end

load(loadscript)

Dir.mkdir(bindir2)	unless File.directory?(bindir2)
Dir.mkdir(libdir2)	unless File.directory?(libdir2)
Dir.mkdir(appdir2)	unless File.directory?(appdir2)

rubyw	= false
rubyw	= true		if script =~ /\.rbw$/
rubyw	= true		if RUBYSCRIPT2EXE::RUBYW
rubyw	= false		if RUBY
rubyw	= true		if RUBYW

if linux? or darwin?
  rubyexe	= "#{bindir1}/ruby"
else
  rubyexe	= "#{bindir1}/ruby.exe"
  rubywexe	= "#{bindir1}/rubyw.exe"
end

$stderr.puts "Copying files..."	unless QUIET

copyto([RUBYSCRIPT2EXE::DLLS].flatten.collect{|s| oldlocation(s)}, bindir2)
copyto([RUBYSCRIPT2EXE::BIN].flatten.collect{|s| oldlocation(s)}, bindir2)
copyto([RUBYSCRIPT2EXE::LIB].flatten.collect{|s| oldlocation(s)}, libdir2)

copyto(rubyexe, bindir2)	if (linux? or darwin?) and File.file?(rubyexe)
copyto(ldds(rubyexe), bindir2)	if (linux? or darwin?)

copyto(rubyexe, bindir2)	if (windows? or cygwin?) and File.file?(rubyexe)
copyto(rubywexe, bindir2)	if (windows? or cygwin?) and File.file?(rubywexe)
copyto(dlls(rubyexe), bindir2)	if (windows? or cygwin?) and File.file?(rubyexe)

copyto(oldlocation(script), appdir2)	if File.file?(oldlocation(script))
Dir.copy(oldlocation(script), appdir2)	if File.directory?(oldlocation(script))

copyto(Dir.find(libdir2, /\.(so|o|dll)$/i).collect{|file| ldds(file)}, bindir2)	if linux? or darwin?
copyto(Dir.find(libdir2, /\.(so|o|dll)$/i).collect{|file| dlls(file)}, bindir2)	if windows? or cygwin?

if TK or RUBYSCRIPT2EXE::TK
  if File.file?("#{libdir2}/tk.rb")
    $stderr.puts "Copying TCL/TK..."	unless QUIET

    require "tk"

    tcllib	= Tk::TCL_LIBRARY
    tklib	= Tk::TK_LIBRARY

    Dir.copy(tcllib, File.expand_path(File.basename(tcllib), libdir2))
    Dir.copy(tklib, File.expand_path(File.basename(tklib), libdir2))
  end
end

if not NOSTRIP and RUBYSCRIPT2EXE::STRIP and (linux? or darwin?)
  $stderr.puts "Stripping..."	unless QUIET

  system("cd #{bindir2} ; strip --strip-all * 2> /dev/null")
  system("cd #{libdir2} ; strip --strip-all * 2> /dev/null")
end

rubyexe	= "ruby.exe"
rubyexe	= "rubyw.exe"		if rubyw
rubyexe	= "ruby"		if linux?
rubyexe	= "ruby"		if darwin?
eeeexe	= "eee.exe"
eeeexe	= "eeew.exe"		if rubyw
eeeexe	= "eee_linux"		if linux?
eeeexe	= "eee_darwin"		if darwin?
appeee	= "#{app}.eee"
appexe	= "#{app}.exe"
appexe	= "#{app}_linux"	if linux?
appexe	= "#{app}_darwin"	if darwin?
appico	= "#{app}.ico"
strace	= ""
strace	= "strace"		if STRACE

$stderr.puts "Creating #{appexe} ..."	unless QUIET

File.open(tmplocation("bootstrap.rb"), "w") do |f|
  f.puts "# Set up the environment"

  f.puts "# Define some RUBYSCRIPT2EXE constants"

  f.puts "module RUBYSCRIPT2EXE"
  f.puts "  RUBYEXE	= '#{rubyexe}'"
  f.puts "  COMPILED	= true"
  f.puts "  USERDIR	= Dir.pwd"
  f.puts "end"

  f.puts "dir	= File.expand_path(File.dirname(__FILE__))"
  f.puts "dir.sub!(/^.:/, '/cygdrive/%s' % $&[0..0].downcase)	if dir =~ /^.:/"	if cygwin?
  f.puts "bin		= dir + '/bin'"
  f.puts "lib		= dir + '/lib'"

  f.puts "verbose	= $VERBOSE"
  f.puts "$VERBOSE	= nil"
  f.puts "s		= ENV['PATH'].dup"
  f.puts "$VERBOSE	= verbose"
  f.puts "if Dir.pwd[1..2] == ':/'"
  f.puts "  s << (';'+bin.gsub(/\\//, '\\\\'))"
  f.puts "else"
  f.puts "  s << (':'+bin)"
  f.puts "end"
  f.puts "ENV['PATH']   = s"

  f.puts "$:.clear"
  f.puts "$: << lib"

  f.puts "# Load eee.info"

  f.puts "eeedir		= File.dirname(__FILE__)"
  f.puts "eeeinfo		= File.expand_path('eee.info', eeedir)"
  f.puts "if File.file?(eeeinfo)"
  f.puts "  lines	= File.open(eeeinfo){|f| f.readlines}"
  f.puts "  badline	= lines.find{|line| line !~ /^EEE_/}"
  f.puts "  while badline"
  f.puts "    pos		= lines.index(badline)"
  f.puts "    raise 'Found badline at position 0.'	if pos == 0"
  f.puts "    lines[pos-1..pos]	= lines[pos-1] + lines[pos]"
  f.puts "    badline		= lines.find{|line| line !~ /^EEE_/}"
  f.puts "  end"
  f.puts "  lines.each do |line|"
  f.puts "    k, v	= line.strip.split(/\s*=\s*/, 2)"
  f.puts "    k.gsub!(/^EEE_/, '')"
  f.puts "    v	= File.expand_path(v)	if k == 'APPEXE'"
  f.puts "    RUBYSCRIPT2EXE.module_eval{const_set(k, v)}"
  f.puts "  end"
  f.puts "  ARGV.concat(RUBYSCRIPT2EXE::PARMSLIST.split(/\000/))"
  f.puts "end"

  f.puts "# Set the RubyGems environment"

  if RUBYSCRIPT2EXE::RUBYGEMS
    f.puts "ENV.keys.each do |key|"
    f.puts "  ENV.delete(key)	if key =~ /^gem_/i"
    f.puts "end"
    f.puts "ENV['GEM_PATH']=lib+'/rubyscript2exe.gems'"
    f.puts "require 'rubygems'"
  end

  f.puts "# Start the application"

  f.puts "load($0 = ARGV.shift)"
end

File.open(tmplocation("empty.rb"), "w") do |f|
end

File.open(tmplocation(appeee), "w") do |f|
  f.puts "r bin"
  f.puts "r lib"
  f.puts "f bootstrap.rb"
  f.puts "f empty.rb"
  f.puts "r app"
  f.puts "i eee.info"

  apprb	= File.basename(script)	if File.file?(oldlocation(script))
  apprb	= "init.rb"	if File.directory?(oldlocation(script))

	# ??? nog iets met app/bin?
  if linux?
    f.puts "c PATH=%tempdir%/bin:$PATH ; export LD_LIBRARY_PATH=%tempdir%/bin:$LD_LIBRARY_PATH ; chmod +x %tempdir%/bin/* ; #{strace} %tempdir%/bin/#{rubyexe} -r %tempdir%/bootstrap.rb -T1 %tempdir%/empty.rb %tempdir%/app/#{apprb}"
  elsif darwin?
    f.puts "c PATH=%tempdir%/bin:$PATH ; export DYLD_LIBRARY_PATH=%tempdir%/bin:$DYLD_LIBRARY_PATH ; chmod +x %tempdir%/bin/* ; %tempdir%/bin/#{rubyexe} -r %tempdir%/bootstrap.rb -T1 %tempdir%/empty.rb %tempdir%/app/#{apprb}"
  elsif cygwin?
    f.puts "c %tempdir%\\bin\\#{rubyexe} -r %tempdir1%/bootstrap.rb -T1 %tempdir1%/empty.rb %tempdir1%/app/#{apprb}"
  else
    f.puts "c %tempdir%\\bin\\#{rubyexe} -r %tempdir%\\bootstrap.rb -T1 %tempdir%\\empty.rb %tempdir%\\app\\#{apprb}"
  end
end

too_long	= File.read(tmplocation(appeee)).split(/\r*\n/).select{|line| line.length > 255}

unless too_long.empty?
  too_long.each do |line|
    $stderr.puts "Line is too long (#{line.length}): #{line}"
  end

  $stderr.puts "Stopped."

  exit 16
end

from	= newlocation(eeeexe)
from	= applocation(eeeexe)	unless File.file?(from)
from	= oldlocation(eeeexe)	unless File.file?(from)
to	= tmplocation(eeeexe)

File.copy(from, to)	unless from == to
File.chmod(0755, to)	if linux? or darwin?

tmplocation do
  ENV["EEE_EXE"]	= eeeexe
  ENV["EEE_DIR"]	= Dir.pwd
  ENV["EEE_TEMPDIR"]	= RUBYSCRIPT2EXE::TEMPDIR	if RUBYSCRIPT2EXE::TEMPDIR

  eeebin1	= newlocation("eee.exe")
  eeebin1	= newlocation("eee_linux")	if linux?
  eeebin1	= newlocation("eee_darwin")	if darwin?

  unless File.file?(eeebin1)
    eeebin1	= applocation("eee.exe")
    eeebin1	= applocation("eee_linux")	if linux?
    eeebin1	= applocation("eee_darwin")	if darwin?
  end

  unless File.file?(eeebin1)
    eeebin1	= oldlocation("eee.exe")
    eeebin1	= oldlocation("eee_linux")	if linux?
    eeebin1	= oldlocation("eee_darwin")	if darwin?
  end

  eeebin2	= tmplocation("eee.exe")
  eeebin2	= tmplocation("eee_linux")	if linux?
  eeebin2	= tmplocation("eee_darwin")	if darwin?

  from	= eeebin1
  to	= eeebin2

  File.copy(from, to)	unless from == to
  File.chmod(0755, to)	if linux? or darwin?

  system(backslashes("#{eeebin2} #{appeee} #{appexe}"))
end

from	= tmplocation(appexe)
to	= oldlocation(appexe)

File.copy(from, to)	unless from == to

oldlocation do
  system(backslashes("reshacker -modify #{tmplocation(appexe)}, #{appexe}, #{appico}, icon,appicon,"))	if File.file?(appico) and (windows? or cygwin?)
end

end	# if __FILE__ == $0
