class MaterialDescendantCountField < CustomFieldBase
	def initialize
	end	

	def name
		return "Material Descendant Count"
	end

	def tool_tip
		return "Yields the count of material (flag:audited) descendants a given item has"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				if CustomFieldBase.handle_excluded_items == true
					next item.getDescendants.reject{|i|i.isExcluded}.select{|i|i.isAudited}.size
				else
					next item.getDescendants.select{|i|i.isAudited}.size
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end