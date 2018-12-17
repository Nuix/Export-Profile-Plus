class SelectProductionSetDocidsField < CustomFieldBase
	def name
		return "Select Production Set DOCIDs"
	end

	def tool_tip
		return "Returns a list DOCIDs for specific selected production sets a given item is a member of."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				ids = []
				item.getProductionSetItems.each do |prod_set_item|
					prod_set_guid = prod_set_item.getProductionSetGuid
					if @selected_prod_set_guids[prod_set_guid] == true
						ids << prod_set_item.getDocumentNumber.toString
					end
				end
				next ids.join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end

	def setup(items)
		@selected_prod_set_guids = {}
		CustomFieldBase.prod_sets.each do |production_set|
			@selected_prod_set_guids[production_set.getGuid] = true
		end
	end

	def cleanup
		@prod_set_by_guid = nil
	end

	def needs_prod_set
		return true
	end
end