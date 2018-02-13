class PropertyNamesField < CustomFieldBase
	def name
		return "Property Names"
	end

	def tool_tip
		return "Exports a field with list of property names present on each item"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				property_names = item.getProperties.keys.sort.join("; ")
				next property_names
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end