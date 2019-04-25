class DuplicatePathDirectoriesField < CustomFieldBase
	def name
		return "Duplicate Path Directories"
	end

	def tool_tip
		return "Resolves to a given item's dupe paths value, with filenames removed from end of paths"
	end

	def decorate(profile)
		duplicate_paths_field = CustomFieldBase.get_nuix_field("Duplicate Paths")
		profile = profile.addMetadata("Duplicate Path Directories") do |item|
			begin
				dupe_paths = duplicate_paths_field.evaluate(item)
				dupe_paths = dupe_paths.split("; ")
				dupe_paths = dupe_paths.map do |p|
					parent_file = java.io.File.new(p).getParentFile
					if parent_file.nil?
						next ""
					else
						next parent_file.getPath
					end
				end
				next dupe_paths.uniq.sort.join(CustomFieldBase.delimiter)
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end