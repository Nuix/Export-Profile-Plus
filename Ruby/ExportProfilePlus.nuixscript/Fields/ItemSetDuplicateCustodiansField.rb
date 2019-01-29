class ItemSetDuplicateCustodians < CustomFieldBase
	def name
		return "Item Set Duplicate Custodians"
	end

	def tool_tip
		return "List of custodians which have a duplicate of a given item in select item sets"
	end

	def decorate(profile)
		profile = profile.addMetadata("Item Set Duplicate Custodians") do |item|
			begin
				custodians = {}
				CustomFieldBase.item_sets.each do |item_set|
					dupes = item_set.findDuplicates(item)
					if CustomFieldBase.handle_excluded_items == true
						dupes = dupes.reject{|i|i.isExcluded}
					end
					dupes.each do |dupe_item|
						custodians[dupe_item.getCustodian] = true
					end
				end
				next custodians.keys.reject{|c|c.nil? || c.strip.empty?}.sort.join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
		return profile
	end

	def needs_item_set
		return true
	end
end