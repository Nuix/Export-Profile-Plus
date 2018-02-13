class DescendantNamesField < CustomFieldBase
	def initialize
	end	

	def name
		return "Descendant Names"
	end

	def tool_tip
		return "Yields a semicolon delimited list containing the name of all descendants of a given item"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next item.getDescendants.map{|i| i.getLocalisedName}.join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end