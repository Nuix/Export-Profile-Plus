class DuplicateCustodianAndPath < CustomFieldBase
	def name
		return "Duplicate Custodians and Paths"
	end

	#You may override this in derived class to provide a tool tip
	#for the given custom field
	def tool_tip
		return "Delimited list of custodian and path of each duplicate of a given item."
	end

	def decorate(profile)
		profile = profile.addMetadata("Duplicate Custodians and Paths") do |item|
			begin
				values = []
				dupes = item.getDuplicates
				if CustomFieldBase.handle_excluded_items == true
					dupes = dupes.reject{|i|i.isExcluded}
				end
				dupes.each do |dupe_item|
					path_string = dupe_item.getPath.map{|i|i.getLocalisedName}.join("/")
					custodian = dupe_item.getCustodian
					if custodian.nil? || custodian.strip.empty?
						custodian = "No Custodian"
					end
					values << "#{custodian}/#{path_string}"
				end
				next values.uniq.sort.join(CustomFieldBase.delimiter)
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
		return profile
	end
end