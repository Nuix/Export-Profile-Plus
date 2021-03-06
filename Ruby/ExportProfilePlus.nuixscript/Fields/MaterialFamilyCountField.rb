class MaterialFamilyCountField < CustomFieldBase
	def initialize
	end	

	def name
		return "Material Family Count"
	end

	def tool_tip
		return "Yields the number of items in the family this item belongs to that are material/audited"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				family_items = item.getFamily
				if family_items.nil?
					next 0
				else
					if CustomFieldBase.handle_excluded_items == true
						material_family_items = family_items.reject{|i|i.isExcluded}.select{|i|i.isAudited}
					else
						material_family_items = family_items.select{|i|i.isAudited}
					end
					next material_family_items.size
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end