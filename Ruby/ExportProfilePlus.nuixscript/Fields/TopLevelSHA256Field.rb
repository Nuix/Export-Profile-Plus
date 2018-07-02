class TopLevelSHA256Field < CustomFieldBase
	def name
		return "Top Level SHA256"
	end

	def tool_tip
		return "Exports a field with the SHA256 of an item's top level item (if it has one)"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				top_level_item = item.getTopLevelItem
				if top_level_item.nil?
					next ""
				else
					top_level_sha256 = top_level_item.getDigests.getSha256
					if top_level_sha256.nil?
						next ""
					else
						next top_level_sha256
					end
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end