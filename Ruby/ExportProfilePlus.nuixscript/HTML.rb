# Class for creating HTML files
class HTML
	# Creates a new instance, not intended to be called directly but
	# instead by call to self.create
	def initialize(file_handle)
		@file_handle = file_handle

		# Write the initial HTML out to the file directly
		@file_handle << "<!DOCTYPE HTML>"
		@file_handle << "<html>"
		@file_handle << "<head><style>"
		@file_handle << "td { border-left:1px solid black; border-top:1px solid black; }"
		@file_handle << "th { border-left:1px solid black; border-top:1px solid black; font-weight:bold; }"
		@file_handle << "table { border-right:1px solid black; border-bottom:1px solid black; border-collapse:collapse; width: 100%; }"
		# @file_handle << "body { margin:50px 0px; padding:0px;text-align:center; font-family: arial; }"
		@file_handle << "pre { margin:0px; white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word; }"
		# @file_handle << "hr { margin-top: 40px; }"
		# @file_handle << "#content { width:1024px; margin:0px auto; text-align:left; padding:15px; border:1px dashed #333; }"
		@file_handle << "</style></head>"
		@file_handle << "<body><div id=\"content\">"
	end

	def begin_table(headers)
		@file_handle << "<hr/>"
		@file_handle << "<table><thead><tr>"
		headers.each do |header|
			@file_handle << "<th class=\"label\">#{header}</th>"
		end
		@file_handle << "</thead><tbody>"
	end

	# Given array 'values', converts array to HTML table row formatted line
	# and appends it to associate file
	def <<(values)
		@file_handle << HTML.to_table_line(Array(values))
	end

	# Used to create a new instance for the scope of the provided block
	# after which underlying file is closed.  If no block is provided will
	# instead return self, leaving closure of writer to caller.
	def self.create(file,&block)
		if block_given?
			File.open(file,"w:utf-8") do |html_file|
				writer = new(html_file)
				yield writer
			end
		else
			html_file = File.open(file,"w:utf-8")
			writer = new(html_file)
			return writer
		end
	end

	# Closes the underlying file
	def close
		@file_handle << "</tbody></table></div></body></html>"
		@file_handle.close
	end

	# Converts array of values to HTML table formatted record line
	def self.to_table_line(values)
		row_html = "<tr>" + values.map{|value| "<td class=\"value\"><pre>#{value}</pre></td>" }.join("") + "</tr>"
		return row_html
	end
end