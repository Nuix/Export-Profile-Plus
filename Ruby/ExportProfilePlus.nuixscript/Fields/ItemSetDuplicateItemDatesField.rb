class ItemSetDuplicateItemDates < CustomFieldBase
	def name
		return "Item Set Duplicate Item Dates"
	end

	#You may override this in derived class to provide a tool tip
	#for the given custom field
	def tool_tip
		return "Delimited list of item dates for items which are a duplicate of a given item in select item sets"
	end

	def decorate(profile)
		profile = profile.addMetadata("Item Set Duplicate Item Dates") do |item|
			begin
				dates = []
				CustomFieldBase.item_sets.each do |item_set|
					dupes = item_set.findDuplicates(item)
					if CustomFieldBase.handle_excluded_items == true
						dupes = dupes.reject{|i|i.isExcluded}
					end
					dupes.each do |dupe_item|
						item_date = dupe_item.getDate
						if !item_date.nil?
							dates << item_date
						end
					end
				end
				next dates.sort.join(CustomFieldBase.delimiter)
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