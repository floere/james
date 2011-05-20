# Don't change this file
# configure your james in the config subdirectory

# JAMES_ROOT
unless defined?(JAMES_ROOT)
  JAMES_ROOT = File.join(File.dirname(__FILE__), '.')
end

# add each dialog lib subdir to the load path
Dir['dialogs/**'].each do | dialog_dir |
  dialog_init_path = dialog_dir + '/init.rb'
  dialog_load_path = dialog_dir + '/lib'
  # add dialog lib to load_path
  # TODO unshift?
  $: << dialog_load_path
  # eval init.rb
  eval(IO.read(dialog_init_path), binding, dialog_init_path)
end

# borrowed from rails
# add to string
class String
  
  def camelize(lower_case_and_underscored_word = self, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end

  def constantize(camel_cased_word = self)
    unless /^(::)?([A-Z]\w*)(::[A-Z]\w*)*$/ =~ camel_cased_word
      raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
    end

    camel_cased_word = "::#{camel_cased_word}" unless $1
    Object.module_eval(camel_cased_word, __FILE__, __LINE__)
  end
  
end