class CustomFieldBase
	@@item_sets = []
	def self.item_sets
		return @@item_sets
	end

	def self.item_sets=(value)
		@@item_sets = value
	end

	@@prod_sets = []
	def self.prod_sets
		return @@prod_sets
	end

	def self.prod_sets=(value)
		@@prod_sets = value
	end

	@@handle_excluded_items = true
	def self.handle_excluded_items
		return @@handle_excluded_items
	end

	def self.handle_excluded_items=(value)
		@@handle_excluded_items = value
	end

	@@delimiter = "; "
	def self.delimiter
		return @@delimiter
	end

	def self.delimiter=(value)
		@@delimiter = value
	end
	
	def name
		raise "Derived class must override this method and return a name"
	end

	#You may override this in derived class to provide a tool tip
	#for the given custom field
	def tool_tip
		return ""
	end

	def decorate(profile)
		raise "Derived class must override this method and return an updated metadata profile"
	end

	#Can be overridden in derived class to allow the class to perform any initialization
	def setup(items)
	end

	#Can be overridden in derived class to allow the class to perform any cleanup afterwards
	def cleanup
	end

	# Allows the custom field to specify that it has dependencies and should be calculated after
	# other fields.  Override and return an integer greater than 0 if it should follow other scripts
	def dependencies
		0
	end

	#Allows the custom field to specify that the user needs to select at least one item set
	#for this field to operate.  Override and return true if you need a selected item set
	def needs_item_set
		return false
	end

	#Allows the custom field to specify that the user needs to select at least one production set
	#for this field to operate.  Override and return true if you need a selected production set
	def needs_prod_set
		return false
	end

	def self.fields
		ObjectSpace.each_object(Class).select{ |klass| klass < self }.map{|f|f.new}
	end

	def self.get_nuix_field(name)
		all_metadata = $current_case.getMetadataItems
		matching_metadata = all_metadata.select{|f| f.getName.downcase == name.downcase}
		if matching_metadata.size > 0
			return matching_metadata.first
		else
			raise "Unable to locate metadata field named: #{name}"
		end
	end
end