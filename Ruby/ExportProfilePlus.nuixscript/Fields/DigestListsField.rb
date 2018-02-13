class DigestListsField < CustomFieldBase
	def name
		return "Digest Lists"
	end

	def tool_tip
		return "Returns a list of digest lists a given item shares its MD5 with"
	end

	def decorate(profile)
		iutil = $utilities.getItemUtility
		return profile.addMetadata(self.name) do |item|
				begin
				result = []
				@digest_list_reference_items.each do |name,items|
					if iutil.intersection([item],items).size > 0
						result << name
					end
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
			next result.sort.join("; ")
		end
	end

	def setup(items)
		@digest_list_reference_items = {}
		$utilities.getDigestListStore.getDigestListNames.each do |name|
			query = "digest-list:\"#{name}\""
			@digest_list_reference_items[name] = $current_case.searchUnsorted(query)
		end
	end

	def cleanup
		@digest_list_reference_items = nil
	end
end