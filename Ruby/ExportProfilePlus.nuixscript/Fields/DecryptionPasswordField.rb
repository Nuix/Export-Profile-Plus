class DecryptionPasswordField < CustomFieldBase
	def initialize
		@password_handler = Proc.new { |pass_char_array|
			pass = java.lang.String.new(pass_char_array)
			next pass
		}
	end	

	def name
		return "Decryption Password"
	end

	def tool_tip
		return "Yields the password Nuix used to decrypt a given item (if there is one)"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next item.revealDecryptionPassword(@password_handler)
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end