# Class for creating DAT load files
class DAT
	# Creates a new instance, not intended to be called directly but
	# instead by call to self.create
	def initialize(file_handle)
		@file_handle = file_handle
	end

	# Given array 'values', converts array to DAT formatted line
	# and appends it to associate file
	def <<(values)
		@file_handle << DAT.to_dat_line(Array(values))
	end

	# Used to create a new instance for the scope of the provided block
	# after which underlying file is closed.  If no block is provided will
	# instead return self, leaving closure of writer to caller.
	def self.create(file,&block)
		if block_given?
			File.open(file,"w:utf-8") do |dat_file|
				writer = new(dat_file)
				block.call(writer)
			end
		else
			dat_file = File.open(file,"w:utf-8")
			writer = new(dat_file)
			return writer
		end
	end

	# Closes the underlying file
	def close
		@file_handle.close
	end

	# Converts array of values to DAT formatted record line
	def self.to_dat_line(values)
		#Replace newlines in values with ®
		escaped_values = values.map{|v|v.gsub(/\r?\n/,"\u00AE")}
		#Build DAT formatted line
		return "\u00FE#{escaped_values.join("\u00FE\u00FE")}\u00FE\n"
	end
end