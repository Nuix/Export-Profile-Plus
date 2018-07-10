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
				next item.getDescendants.select{|i|i.isAudited}.size
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end