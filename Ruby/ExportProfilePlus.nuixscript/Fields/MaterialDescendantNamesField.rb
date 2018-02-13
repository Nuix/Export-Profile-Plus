class MaterialDescendantNamesField < CustomFieldBase
	def initialize
	end	

	def name
		return "Material Descendant Names"
	end

	def tool_tip
		return "Yields a semicolon delimited list containing the name of all audited descendants of a given item"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next item.getDescendants.select{|i| i.isAudited}.map{|i| i.getLocalisedName}.join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end