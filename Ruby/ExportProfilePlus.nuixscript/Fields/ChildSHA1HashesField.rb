class ChildSHA1HashesField < CustomFieldBase
	def initialize
	end

	def name
		return "Child SHA1 Hashes"
	end

	def tool_tip
		return "Yields a semicolon delimited list containing the SHA1 hash of all child items of a given item"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				result = []
				child_items = item.getChildren
				if CustomFieldBase.handle_excluded_items == true
					child_items = child_items.reject{|i|i.isExcluded}
				end
				child_items.each do |child_item|
					hash = child_item.getDigests.getSha1
					if !hash.nil? && !hash.strip.empty?
						result << hash
					end
				end
				next result.join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end