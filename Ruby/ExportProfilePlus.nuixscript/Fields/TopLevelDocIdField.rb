class TopLevelDocIdField < CustomFieldBase
	def name
		return "Top Level DOCID"
	end

	def tool_tip
		tip = "Exports a field with DOCID(s) of a given item's top level item."
		tip += " When the item itself is top level yields a blank value."
		tip += " DOCID returned is based upon selected production sets in settings dialog!"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				# Top level items return blank for them self
				next "" if item.isTopLevel

				top_level_item = item.getTopLevelItem
				if top_level_item.nil?
					next "" # Return blank if there is no top level item
				else
					# Attempt to determine DOCID of top level item, note that
					# DOCID(s) returned are based on what production sets were selected
					# in the settings dialog
					result = []
					prod_set_items = top_level_item.getProductionSetItems
					prod_set_items.each do |prod_set_item|
						prod_set_guid = prod_set_item.getProductionSetGuid
						if @selected_prod_set_guids[prod_set_guid] == true
							result << prod_set_item.getDocumentNumber.toString
						end
					end

					# If we get at least 1 DOCID resolved, return a value.  If multiple
					# production sets were selected and we resolve multiple DOCIDs, then
					# we return a delimited list of DOCIDs.  If none were resolved, then
					# we return a blank value.
					if result.size > 0
						next result.join("; ")
					else
						next ""
					end
				end
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