class ItemFamilyTextField < CustomFieldBase
	def name
		return "Item Family Text"
	end

	def tool_tip
		return "Exports a field with the text of all the family members concatenated into a single value in position order."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				result = []
				family_items = item.getFamily
				if !family_items.nil?
					family_items.each do |family_item|
						result << family_item.getTextObject.toString
					end
					next result.join("\n")
				else
					next item.getTextObject.toString
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end