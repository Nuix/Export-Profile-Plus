class CcRecipientCountField < CustomFieldBase
	def initialize
	end	

	def name
		return "CC Recipient Count"
	end

	def tool_tip
		return "Exports a count of recipient addresses in the CC field for an item"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				com = item.getCommunication
				if !com.nil?
					address_count = com.getCc.size
					next address_count
				else
					next 0
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end