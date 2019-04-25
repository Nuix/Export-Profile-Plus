class SelectProductionSetDocidsField < CustomFieldBase
	def name
		return "Select Production Set DOCIDs"
	end

	def tool_tip
		return "Returns a delimited list DOCIDs for specific selected production sets a given item is a member of."
	end

	def docids_for_item(item)
		# Attempt to determine DOCID of top level item, note that
		# DOCID(s) returned are based on what production sets were selected
		# in the settings dialog
		result = []

		if NuixConnection.getCurrentNuixVersion.isLessThan("7.4")
			result = @docid_lookup[item.getGuid]
		else
			prod_set_items = item.getProductionSetItems
			prod_set_items.each do |prod_set_item|
				prod_set_guid = prod_set_item.getProductionSetGuid
				if @selected_prod_set_guids[prod_set_guid] == true
					result << prod_set_item.getDocumentNumber.toString
				end
			end
		end

		# If we get at least 1 DOCID resolved, return a value.  If multiple
		# production sets were selected and we resolve multiple DOCIDs, then
		# we return a delimited list of DOCIDs.  If none were resolved, then
		# we return a blank value.
		if result.size > 0
			return result.join(CustomFieldBase.delimiter)
		else
			return ""
		end
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next docids_for_item(item)
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

		# Before Nuix 7.4, we don't have Item.getProductionSetItems, so we have to
		# build a lookup for item DOCIDs
		if NuixConnection.getCurrentNuixVersion.isLessThan("7.4")
			# We will use this to only save a lookup for items actually being exported
			export_guids = {}
			items.each do |item|
				export_guids[item.getGuid] = true
			end

			@docid_lookup = Hash.new{|h,k| h[k] = []}
			CustomFieldBase.prod_sets.each do |production_set|
				production_set.getProductionSetItems.each do |prod_set_item|
					guid = prod_set_item.getItem.getGuid
					next if export_guids[guid] != true
					@docid_lookup[guid] << prod_set_item.getDocumentNumber.toString
				end
			end
		end
	end

	def cleanup
		@prod_set_by_guid = nil
		@docid_lookup = nil
	end

	def needs_prod_set
		return true
	end
end