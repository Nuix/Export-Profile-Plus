class TextPathField < CustomFieldBase
	def name
		return "Stored Text Path"
	end

	def tool_tip
		return "Exports a field with the item's text path if available"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				text_info = item.getTextObject
				text_stored_path = text_info.getStoredPath
				if !text_stored_path.nil?
					next text_stored_path.toString
				else
					next ""
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end