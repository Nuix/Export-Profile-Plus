class AllProductionSetDocidsField < CustomFieldBase
	def name
		return "All Production Set DOCIDs"
	end

	def tool_tip
		return "Returns a list DOCIDs for all production sets a given item is a member of."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next item.getProductionSetItems.map{|pi|pi.getDocumentNumber.toString}.join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end

	def setup(items)
	end

	def cleanup
	end
end