class PropertiesAndContentTermOccurrencesField < CustomFieldBase
	def initialize
	end	

	def name
		return "Properties and Content Term Occurrences"
	end

	def tool_tip
		return "Yields the number total term occurrences in the given item's properties and content text."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				case_stats = $current_case.getStatistics
				term_stats = case_stats.getTermStatistics("guid:#{item.getGuid}",{"field"=>"all"})
				term_occurrences = term_stats.map{|t,c|c}.reduce(0,:+)
				next term_occurrences
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end