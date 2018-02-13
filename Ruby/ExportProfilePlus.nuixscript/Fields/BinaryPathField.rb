class BinaryPathField < CustomFieldBase
	def name
		return "Stored Binary Path"
	end

	def tool_tip
		return "Exports a field with the item's binary path if available"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				binary_info = item.getBinary
				stored_path = binary_info.getStoredPath
				if stored_path.nil?
					next ""
				else
					next stored_path.toString
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end