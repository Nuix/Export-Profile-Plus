class BinaryAvailableField < CustomFieldBase
	def name
		return "Binary Available"
	end

	def tool_tip
		return "Exports a field containing true or false based on whether Nuix believes the binary is available"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				binary_info = item.getBinary
				binary_info.getBinaryData.getLength
				next true
			rescue Exception => exc
				next false
			end
		end
	end
end