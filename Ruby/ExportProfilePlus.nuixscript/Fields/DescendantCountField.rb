class DescendantCountField < CustomFieldBase
	def initialize
	end	

	def name
		return "Descendant Count"
	end

	def tool_tip
		return "Yields the count of descendants a given item has"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				if CustomFieldBase.handle_excluded_items == true
					next item.getDescendants.reject{|i|i.isExcluded}.size
				else
					next item.getDescendants.size
				end
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end