class TopLevelAllCustodiansField < CustomFieldBase
	def initialize
	end	

	def name
		return "Top Level All Custodians"
	end

	def tool_tip
		return "Yields a delimited list of all custodians which have a top level MD5 duplicate of the given item, if the item is itself top level"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			if !item.isTopLevel
				next ""
			end

			begin
				result = []
				result << item.getCustodian
				if CustomFieldBase.handle_excluded_items == true
					result += item.getDuplicates.reject{|i|i.isExcluded}.select{|i|i.isTopLevel}.map{|i|i.getCustodian}
				else
					result += item.getDuplicates.select{|i|i.isTopLevel}.map{|i|i.getCustodian}
				end
				result = result.reject{|c|c.nil? || c.strip.empty?}
				result = result.uniq
				result = result.sort
				next result.join(CustomFieldBase.delimiter)
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end