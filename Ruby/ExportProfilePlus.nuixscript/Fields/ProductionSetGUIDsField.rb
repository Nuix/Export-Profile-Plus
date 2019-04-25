class ProductionSetGUIDsField < CustomFieldBase
	def name
		return "Production Set GUIDs"
	end

	def tool_tip
		return "Returns a delimited list production set GUIDs for all production sets a given item is a member of."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next @production_set_lookup[item].map{|ps| ps.getGuid}.join(CustomFieldBase.delimiter)
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end

	def setup(items)
		@production_set_lookup = Hash.new{|h,k| h[k] = []}
		$current_case.getProductionSets.each do |production_set|
			production_set.getItems.each do |item|
				@production_set_lookup[item] << production_set
			end
		end
	end

	def cleanup
		@production_set_lookup = nil
	end
end