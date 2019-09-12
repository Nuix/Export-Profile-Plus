# Class for creating TSV load files
class TSV
	# Creates a new instance, not intended to be called directly but
	# instead by call to self.create
	def initialize(file_handle)
		@file_handle = file_handle
	end

	# Given array 'values', converts array to TSV formatted line
	# and appends it to associate file
	def <<(values)
		@file_handle << TSV.to_tsv_line(Array(values))
	end

	# Used to create a new instance for the scope of the provided block
	# after which underlying file is closed.  If no block is provided will
	# instead return self, leaving closure of writer to caller.
	def self.create(file,&block)
		if block_given?
			File.open(file,"w:utf-8") do |tsv_file|
				writer = new(tsv_file)
				block.call(writer)
			end
		else
			tsv_file = File.open(file,"w:utf-8")
			writer = new(tsv_file)
			return writer
		end
	end

	# Closes the underlying file
	def close
		@file_handle.close
	end

	# Converts array of values to TSV formatted record line
	def self.to_tsv_line(values)
		# Replace some characters that are considered not to be allowed
		# raw in a given field's value
		# https://en.wikipedia.org/wiki/Tab-separated_values#Conventions_for_Lossless_Conversion_to_TSV
		escaped_values = values.map do |v|
			r = v
			r = v.gsub("\n","\\n")
			r = v.gsub("\t","\\t")
			r = v.gsub("\r","\\r")
			r = v.gsub("\\","\\\\")
			next r
		end
		#Build TSV formatted line
		return escaped_values.join("\t")+"\n"
	end
end