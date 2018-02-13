class HasProductionSetField < CustomFieldBase
	def name
		return "Has Production Set"
	end

	def tool_tip
		return "Returns true/false indicating whether is item is present in a production set."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next $current_case.count("has-production-set:1 AND guid:#{item.getGuid}") > 0
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end

	def setup(items)
	end

	def cleanup
	end
end