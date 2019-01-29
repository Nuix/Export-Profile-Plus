class PhysicalFileAncestorMd5Field < CustomFieldBase
	def initialize
	end	

	def name
		return "Physical File Ancestor MD5"
	end

	def tool_tip
		return "Yields the MD5 digest of the physical file ancestor item if there is one"
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				result = ""
				path_items = item.getPath
				if CustomFieldBase.handle_excluded_items == true
					path_items = path_items.reject{|i|i.isExcluded}
				end
				path_items.each do |path_item|
					if path_item.isPhysicalFile
						md5 = path_item.getDigests.getMd5
						if !md5.nil? && !md5.strip.empty?
							result = md5
						end
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