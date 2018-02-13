# Note that the upfront data collection for this field can take some time!
class ProductionSetHistoryField < CustomFieldBase
	def name
		return "Production Set History"
	end

	def tool_tip
		return "Returns a listing of when this item was added and/or removed from production sets based on history events stored in the case."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				next @production_set_history[item].join("; ")
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end

	def setup(items)
		@production_set_history = Hash.new{|h,k| h[k] = [] }
		annotation_events = $current_case.getHistory({
			"type" => "annotation",
		})
		annotation_events.each do |event|
			event_details = event.getDetails
			production_set_name = event_details["productionSet"]
			if !production_set_name.nil?
				added = event_details["added"]
				if added == true
					event.getAffectedItems.each{|item| @production_set_history[item] << "Added to '#{production_set_name}' #{event.getStartDate}"}
				else
					event.getAffectedItems.each{|item| @production_set_history[item] << "Removed from '#{production_set_name}' #{event.getStartDate}"}
				end
			end
		end
	end

	def cleanup
		@production_set_lookup = nil
	end
end