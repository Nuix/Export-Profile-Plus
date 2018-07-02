class AllCustodiansField < CustomFieldBase
	def initialize
	end	

	def name
		return "All Custodians"
	end

	def tool_tip
		return "Yields a semicolon delimited list of all custodians which have an MD5 duplicate of the given item"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				result = []
				result << item.getCustodian
				result += item.getDuplicates.map{|i|i.getCustodian}
				result = result.reject{|c|c.nil? || c.strip.empty?}
				result = result.uniq
				result = result.sort
				next result.join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end