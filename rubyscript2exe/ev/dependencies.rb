def dlls(file)

	# Only the dependencies in the same directory as the executable or any non-Windows directory in %PATH%.

  todo		= []
  res		= []

  todo << File.expand_path(file)

  paden	= ENV["PATH"].split(/;/)
  paden	= ENV["PATH"].split(/:/)	if paden.length == 1

  paden << File.dirname(file)

  windir1	= (ENV["WINDIR"] || "").gsub(/\\/, "/").downcase
  drive		= windir1.scan(/^(.):/).shift.shift
  windir2	= windir1.sub(/^#{drive}:/, "/cygdrive/#{drive.downcase}")

  paden	= paden.collect{|pad| pad.gsub(/\\/, "/").downcase}
  paden	= paden.select{|pad| pad.downcase}
  paden	= paden.reject{|pad| pad =~ /^#{windir1}/}
  paden	= paden.reject{|pad| pad =~ /^#{windir2}/}

  while todo.length > 0
    todo2	= todo
    todo	= []

    todo2.each do |file|
      File.open(file, "rb") do |f|
        while (line = f.gets)
          strings	= line.scan(/[\w\-\.]+/)	# Hack ???
          strings	= strings.reject{|s| s !~ /\.(so|o|dll)$/i}

          strings.each do |lib|
            pad	= paden.find{|pad| File.file?(File.expand_path(lib, pad))}

            unless pad.nil?
              lib	= File.expand_path(lib, pad)

              if File.file?(lib) and not res.include?(lib)
                todo << lib
                res << lib
              end
            end
          end
        end
      end
    end
  end

  res
end

def ldds(file, notthedefaults=true)

	# All dependencies.

  todo		= []
  res		= []
  tempfile	= "/tmp/ev.dependencies.%d.tmp" % Process.pid

  todo << File.expand_path(file)

  while todo.length > 0
    todo2	= todo
    todo	= []

    todo2.each do |file|
      File.copy(file, tempfile)		# Libraries on Debian are no executables.
      File.chmod(0755, tempfile)

      libs	= `ldd #{tempfile}`.split(/\r*\n/).collect{|line| line.split(/\s+/)[3]}			if linux?
      libs	= `otool -L #{tempfile}`.split(/\r*\n/)[1..-1].collect{|line| line.split(/\s+/)[1]}	if darwin?

      libs.compact.each do |lib|
        if File.file?(lib) and not res.include?(lib)
          todo << lib
          res << lib
        end
      end

      File.delete(tempfile)
    end
  end

	# http://www.linuxbase.org/spec/refspecs/LSB_1.3.0/gLSB/gLSB/rlibraries.html
	# http://www.linuxbase.org/spec/refspecs/LSB_1.3.0/IA32/spec/rlibraries.html

  lsb_common	= ["libX11.so.6", "libXt.so.6", "libGL.so.1", "libXext.so.6", "libICE.so.6", "libSM.so.6", "libdl.so.2", "libcrypt.so.1", "libz.so.1", "libncurses.so.5", "libutil.so.1", "libpthread.so.0", "libpam.so.0", "libgcc_s.so.1"]
  lsb_ia32	= ["libm.so.6", "libdl.so.2", "libcrypt.so.1", "libc.so.6", "libpthread.so.0", "ld-lsb.so.1"]
  lsb		= lsb_common + lsb_ia32

  res.reject!{|s| lsb.include?(File.basename(s))}	if notthedefaults

  res
end
