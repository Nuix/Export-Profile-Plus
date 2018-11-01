class RecipientCountField < CustomFieldBase
	def initialize
	end	

	def name
		return "Recipient Count"
	end

	def tool_tip
		return "Exports a count of recipient addresses for an item"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				com = item.getCommunication
				if !com.nil?
					domains = {}
					address_count = com.getTo.size + com.getCc.size + com.getBcc.size
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