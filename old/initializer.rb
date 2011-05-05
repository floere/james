# Don't change this file
# configure your james in the config subdirectory

# JAMES_ROOT
unless defined?(JAMES_ROOT)
  JAMES_ROOT = File.join(File.dirname(__FILE__), '.')
end

# add each dialogue lib subdir to the load path
Dir['dialogues/**'].each do | dialogue_dir |
  dialogue_init_path = dialogue_dir + '/init.rb'
  dialogue_load_path = dialogue_dir + '/lib'
  # add dialogue lib to load_path
  # TODO unshift?
  $: << dialogue_load_path
  # eval init.rb
  eval(IO.read(dialogue_init_path), binding, dialogue_init_path)
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