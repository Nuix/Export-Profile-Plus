class ItemTextField < CustomFieldBase
	def name
		return "Item Text"
	end

	def tool_tip
		return "Exports a field with the item's text as the value"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next item.getTextObject.toString
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end