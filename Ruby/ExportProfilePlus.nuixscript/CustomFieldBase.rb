class CustomFieldBase
	@@item_sets = []
	def self.item_sets
		return @@item_sets
	end

	def self.item_sets=(value)
		@@item_sets = value
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

	#Allows the custom field to specify that the user needs to select at least one item set
	#for this field to operate.  Override and return true if you need a selected item set
	def needs_item_set
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