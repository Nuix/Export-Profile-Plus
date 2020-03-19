class FilenameSuffixer
	def self.add_suffix(absolute_path,index,width=2)
		directory = File.dirname(absolute_path)
		extension = File.extname(absolute_path)
		filename_no_extension = File.basename(absolute_path, extension)
		suffixed_filename = filename_no_extension + "_" + index.to_s.rjust(width,"0")
		return File.join(directory,suffixed_filename+"."+extension)
	end
end