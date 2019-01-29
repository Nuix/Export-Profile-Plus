class BinaryAvailableField < CustomFieldBase
	def name
		return "Binary Available"
	end

	def tool_tip
		return "Exports a field containing true or false based on whether Nuix believes the binary is available"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			binary_data = nil
			begin
				binary_info = item.getBinary
				binary_data = binary_info.getBinaryData
				binary_data.getLength
				next true
			rescue Exception => exc
				next false
			ensure
				if !binary_data.nil?
					binary_data.close
				end
			end
		end
	end
end