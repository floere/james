temp	= File.expand_path((ENV["TMPDIR"] or ENV["TMP"] or ENV["TEMP"] or "/tmp").gsub(/\\/, "/"))
dir	= "#{temp}/oldandnewlocation.#{Process.pid}"

ENV["OLDDIR"]	= Dir.pwd								unless ENV.include?("OLDDIR")
ENV["NEWDIR"]	= File.expand_path(File.dirname($0))					unless ENV.include?("NEWDIR")
ENV["APPDIR"]	= File.expand_path(File.dirname((caller[-1] or $0).gsub(/:\d+$/, "")))	unless ENV.include?("APPDIR")
ENV["TEMPDIR"]	= dir									unless ENV.include?("TEMPDIR")

class Dir
  def self.rm_rf(entry)
    File.chmod(0755, entry)

    if File.ftype(entry) == "directory"
      pdir	= Dir.pwd

      Dir.chdir(entry)
        Dir.open(".") do |dir|
          dir.each do |e|
            Dir.rm_rf(e)	if not [".", ".."].include?(e)
          end
        end
      Dir.chdir(pdir)

      begin
        Dir.delete(entry)
      rescue => e
        $stderr.puts e.message
      end
    else
      begin
        File.delete(entry)
      rescue => e
        $stderr.puts e.message
      end
    end
  end
end

begin
  oldlocation
rescue NameError
  def oldlocation(file="")
    dir	= ENV["OLDDIR"]
    res	= nil

    if block_given?
      pdir	= Dir.pwd

      Dir.chdir(dir)
        res	= yield
      Dir.chdir(pdir)
    else
      res	= File.expand_path(file, dir)	unless file.nil?
    end

    res
  end
end

begin
  newlocation
rescue NameError
  def newlocation(file="")
    dir	= ENV["NEWDIR"]
    res	= nil

    if block_given?
      pdir	= Dir.pwd

      Dir.chdir(dir)
        res	= yield
      Dir.chdir(pdir)
    else
      res	= File.expand_path(file, dir)	unless file.nil?
    end

    res
  end
end

begin
  applocation
rescue NameError
  def applocation(file="")
    dir	= ENV["APPDIR"]
    res	= nil

    if block_given?
      pdir	= Dir.pwd

      Dir.chdir(dir)
        res	= yield
      Dir.chdir(pdir)
    else
      res	= File.expand_path(file, dir)	unless file.nil?
    end

    res
  end
end

begin
  tmplocation
rescue NameError
  dir	= ENV["TEMPDIR"]

  Dir.rm_rf(dir)	if File.directory?(dir)
  Dir.mkdir(dir)

  at_exit do
    if File.directory?(dir)
      Dir.chdir(dir)
      Dir.chdir("..")
      Dir.rm_rf(dir)
    end
  end

  def tmplocation(file="")
    dir	= ENV["TEMPDIR"]
    res	= nil

    if block_given?
      pdir	= Dir.pwd

      Dir.chdir(dir)
        res	= yield
      Dir.chdir(pdir)
    else
      res	= File.expand_path(file, dir)	unless file.nil?
    end

    res
  end
end
