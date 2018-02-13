class TopLevelMd5Field < CustomFieldBase
	def name
		return "Top Level MD5"
	end

	def tool_tip
		return "Exports a field with the MD5 of an item's top level item (if it has one)"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				top_level_item = item.getTopLevelItem
				if top_level_item.nil?
					next ""
				else
					top_level_md5 = top_level_item.getDigests.getMd5
					if top_level_md5.nil?
						next ""
					else
						next top_level_md5
					end
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end