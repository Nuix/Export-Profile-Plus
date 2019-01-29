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
				audited_items = item.getDescendants.select{|i| i.isAudited}
				if CustomFieldBase.handle_excluded_items == true
					next audited_items.reject{|i|i.isExcluded}.map{|i| i.getLocalisedName}.join("; ")
				else
					next audited_items.map{|i| i.getLocalisedName}.join("; ")
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end