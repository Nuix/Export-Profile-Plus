class FamilyCountField < CustomFieldBase
	def initialize
	end	

	def name
		return "Family Count"
	end

	def tool_tip
		return "Yields the number of items in the family this item belongs to"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				family_items = item.getFamily
				if family_items.nil?
					next 0
				else
					next family_items.size
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end