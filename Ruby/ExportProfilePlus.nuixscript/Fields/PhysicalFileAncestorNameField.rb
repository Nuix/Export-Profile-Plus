class PhysicalFileAncestorNameField < CustomFieldBase
	def initialize
	end	

	def name
		return "Physical File Ancestor Name"
	end

	def tool_tip
		return "Yields the name of the physical file ancestor item if there is one"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				result = ""
				path_items = item.getPath
				path_items.each do |path_item|
					if path_item.isPhysicalFile
						result = path_item.getLocalisedName
						break
					end
				end
				next result
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end