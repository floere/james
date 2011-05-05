require "ftools"

class Dir
  def self.copy(from, to)
    if File.directory?(from)
      pdir	= Dir.pwd
      todir	= File.expand_path(to)

      File.mkpath(todir)

      Dir.chdir(from)
        Dir.open(".") do |dir|
          dir.each do |e|
            Dir.copy(e, todir+"/"+e)	if not [".", ".."].include?(e)
          end
        end
      Dir.chdir(pdir)
    else
      todir	= File.dirname(File.expand_path(to))

      File.mkpath(todir)

      File.copy(from, to)
    end
  end

  def self.move(from, to)
    Dir.copy(from, to)
    Dir.rm_rf(from)
  end

  def self.rm_rf(entry)
    begin
      File.chmod(0755, entry)
    rescue
    end

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

  def self.find(entry=nil, mask=nil)
    entry	= "."	if entry.nil?

    entry	= entry.gsub(/[\/\\]*$/, "")	unless entry.nil?

    mask	= /^#{mask}$/i	if mask.kind_of?(String)

    res	= []

    if File.directory?(entry)
      pdir	= Dir.pwd

      res += ["%s/" % entry]	if mask.nil? or entry =~ mask

      begin
        Dir.chdir(entry)

        begin
          Dir.open(".") do |dir|
            dir.each do |e|
              res += Dir.find(e, mask).collect{|e| entry+"/"+e}	unless [".", ".."].include?(e)
            end
          end
        ensure
          Dir.chdir(pdir)
        end
      rescue Errno::EACCES => e
        $stderr.puts e.message
      end
    else
      res += [entry]	if mask.nil? or entry =~ mask
    end

    res.sort
  end
end

class File
  def self.rollbackup(file, mode=nil)
    backupfile	= file + ".RB.BACKUP"
    controlfile	= file + ".RB.CONTROL"
    res		= nil

    File.touch(file)    unless File.file?(file)

	# Rollback

    if File.file?(backupfile) and File.file?(controlfile)
      $stderr.puts "Restoring #{file}..."

      File.copy(backupfile, file)				# Rollback from phase 3
    end

	# Reset

    File.delete(backupfile)	if File.file?(backupfile)	# Reset from phase 2 or 3
    File.delete(controlfile)	if File.file?(controlfile)	# Reset from phase 3 or 4

	# Backup

    File.copy(file, backupfile)					# Enter phase 2
    File.touch(controlfile)					# Enter phase 3

	# The real thing

    if block_given?
      if mode.nil?
        res	= yield
      else
        File.open(file, mode) do |f|
          res	= yield(f)
        end
      end
    end

	# Cleanup

    File.delete(backupfile)					# Enter phase 4
    File.delete(controlfile)					# Enter phase 5

	# Return, like File.open

    res	= File.open(file, (mode or "r"))	unless block_given?

    res
  end

  def self.touch(file)
    if File.exists?(file)
      File.utime(Time.now, File.mtime(file), file)
    else
      File.open(file, "a"){|f|}
    end
  end

  def self.which(file)
    res	= nil

    if windows?
      file	= file.gsub(/\.exe$/i, "") + ".exe"
      sep		= ";"
    else
      sep		= ":"
    end

    catch :stop do
      ENV["PATH"].split(/#{sep}/).reverse.each do |d|
        if File.directory?(d)
          Dir.open(d) do |dir|
            dir.each do |e|
              if (linux? and e == file) or (windows? and e.downcase == file.downcase)
                res	= File.expand_path(e, d)
                throw :stop
              end
            end
          end
        end
      end
    end

    res
  end

  def self.same_content?(file1, file2, blocksize=4096)
    res	= false

    if File.file?(file1) and File.file?(file2)
      res	= true

      data1	= nil
      data2	= nil

      File.open(file1, "rb") do |f1|
        File.open(file2, "rb") do |f2|
          catch :not_the_same do
            while (data1 = f1.read(blocksize))
              data2	= f2.read(blocksize)

              unless data1 == data2
                res	= false

                throw :not_the_same
              end
            end

            res	= false	if f2.read(blocksize)
          end
        end
      end
    end

    res
  end
end
