class PropertiesTermCountField < CustomFieldBase
	def initialize
	end	

	def name
		return "Properties Term Count"
	end

	def tool_tip
		return "Yields the number distinct terms present in the given item's properties text"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				case_stats = $current_case.getStatistics
				term_stats = case_stats.getTermStatistics("guid:#{item.getGuid}",{"field"=>"properties"})
				term_count = term_stats.size
				next term_count
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end