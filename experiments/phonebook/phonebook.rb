class Phonebook

  def self.find number

    scriptcode = "tell application \"Address Book\"
    	set thePerson to person \"$2\"
    	set theProps to the properties of thePerson
    	set the firstName to the first name of theProps
    	set the lastName to last name of theProps
    	set the phnList to the value of every phone of thePerson
    	set testList to firstName & \" \" & lastName & \" \" & phnList
    	return testList
    end tell"

    p `osascript -e "#{scriptcode}"`

    # Just return the first find.
    #
    [name, address]
  end

end

Phonebook.find '+41449101694'