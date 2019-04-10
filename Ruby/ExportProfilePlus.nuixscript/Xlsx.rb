# Only load NuixVersion class if not already loaded
if !Object.const_defined?("NuixVersion")
	class NuixVersion
		include Comparable

		attr_accessor :major
		attr_accessor :minor
		attr_accessor :bugfix
		attr_accessor :build

		def initialize(major,minor=0,bugfix=0,build=0)
			@major = major
			@minor = minor
			@bugfix = bugfix
			@build = build
		end

		def self.parse(string)
			return new(*string.strip.split("\.").map{|n|n.to_i})
		end

		def self.current
			version_string = NUIX_VERSION
			parts = version_string.split(".").map{|p|p.to_i}
			return new(*parts)
		end

		def to_s
		  return [@major,@minor,@bugfix,@build].join(".")
		end

		def <=>(other)
			case other
			when String
				other = NuixVersion.parse(other)
			when Numeric
				other = NuixVersion.parse(other.to_s)
			end

			return [@major,@minor,@bugfix,@build] <=> [other.major,other.minor,other.bugfix,other.build]
		end
	end
end

module AsposeCells
	include_package "com.aspose.cells"
end

class Xlsx
	class << self
		@@save_formats = {
			:xlsx => AsposeCells::FileFormatType::XLSX,
			:csv => AsposeCells::FileFormatType::CSV,
			:html => AsposeCells::FileFormatType::HTML,
			:pdf => AsposeCells::FileFormatType::PDF,
			:ods => AsposeCells::FileFormatType::ODS,
			:xps => AsposeCells::FileFormatType::XPS,
			:tiff => AsposeCells::FileFormatType::TIFF,
		}

		@@alignment_constants = {
			:top => com.aspose.cells.TextAlignmentType::TOP,
			:center => com.aspose.cells.TextAlignmentType::CENTER,
			:bottom => com.aspose.cells.TextAlignmentType::BOTTOM,
			:left => com.aspose.cells.TextAlignmentType::LEFT,
			:right => com.aspose.cells.TextAlignmentType::RIGHT,
			:justify => com.aspose.cells.TextAlignmentType::JUSTIFY,
		}
	end

	attr_accessor :file
	attr_accessor :workbook
	attr_accessor :created_styles

	def initialize(file=nil)
		#Ensure the Aspose licence is initialized
		if NuixVersion.current < 7
			# Package before Nuix 7.0
			com.nuix.util.AsposeCells.ensureInitialised
		elsif NuixVersion.current < 7.4
			# Package before Nuix 7.4
			com.nuix.util.aspose.AsposeCells.ensureInitialised
		else
			# Package Nuix in Nuix 7.4
			com.nuix.data.util.aspose.AsposeCells.ensureInitialised
		end
		@file = file
		if !file.nil? && java.io.File.new(file).exists
			@workbook = AsposeCells::Workbook.new(file)
		else
			@workbook = AsposeCells::Workbook.new
			@workbook.getWorksheets.removeAt("Sheet1")
		end

		@created_styles = {}
	end

	def save(path=nil,format=:xlsx)
		path ||= @file
		if !path.is_a?(String)
			path = path.getAbsolutePath
		end
		@workbook.save(path,@@save_formats[format])
	end

	def get_sheet(name)
		ws = @workbook.getWorksheets.get(name)
		if !ws.nil?
			return Sheet.new(ws,self)
		else
			return Sheet.new(@workbook.getWorksheets.add(name),self)
		end
	end

	def modify_style(aspose_style,style_hash)
		style_hash.each do |key,value|
			case key
			when :font_name
				aspose_style.getFont.setName(value)
			when :font_size
				aspose_style.getFont.setSize(value)
			when :font_color
				aspose_style.getFont.setColor(resolve_color(value))
			when :font_bold
				aspose_style.getFont.setBold(value)
			when :font_italic
				aspose_style.getFont.setItalic(value)
			when :font_underline
				aspose_style.getFont.setUnderline(value)
			when :font_strikeout
				aspose_style.getFont.setStrikeout(value)
			when :font_subscript
				aspose_style.getFont.setSubscript(value)
			when :font_superscript
				aspose_style.getFont.setSuperscript(value)
			when :h_align, :horizontal_alignment
				aspose_style.setHorizontalAlignment(@@alignment_constants[value])
			when :v_align, :vertical_alignment
				aspose_style.setVerticalAlignment(@@alignment_constants[value])
			when :format
				aspose_style.setCustom(value || "")
			when :text_wrapped
				aspose_style.setTextWrapped(value)
			when :rotation
				aspose_style.setRotationAngle(value)
			when :background_color
				aspose_style.setForegroundColor(resolve_color(value))
				aspose_style.setPattern(com.aspose.cells.BackgroundType::SOLID)
			end
		end
	end

	def create_style(key,style)
		new_style_index = @workbook.getStyles.add
		aspose_style = @workbook.getStyles.get(new_style_index)
		modify_style(aspose_style,style)
		created_styles[key] = aspose_style
	end

	def resolve_color(color)
		if color.is_a?(String) && com.aspose.cells.Color.respond_to?("get#{color}".to_sym)
			return com.aspose.cells.Color.send("get#{color}".to_sym)
		elsif color.is_a?(Hash)
			return com.aspose.cells.Color.fromArgb(color[:a] || 255, color[:r], color[:g], color[:b])
		end
	end

	class Sheet
		attr_accessor :aspose_worksheet
		attr_accessor :workbook
		attr_accessor :current_row

		def initialize(aspose_worksheet,workbook)
			@aspose_worksheet = aspose_worksheet
			@workbook = workbook
			@current_row = @aspose_worksheet.getCells.getMaxDataRow + 1
		end

		def last_row
			return @current_row - 1
		end

		def [](row,col)
			return get_cell(row,col).getValue
		end

		def []=(row,col,value)
			cell = get_cell(row,col).setValue(value)
		end

		def <<(values)
			Array(values).each_with_index do |value,col_index|
				self[@current_row,col_index] = value
			end
			@current_row += 1
		end

		def each_cell(rows=nil,cols=nil,&block)
			row_set = resolve_row_range(rows)
			col_set = resolve_col_range(cols)
			row_set.each do |r|
				col_set.each do |c|
					yield(r,c,get_cell(r,c))
				end
			end
		end

		def create_style(key,style)
			@workbook.create_style(key,style)
		end

		def style_cells(rows,cols,style)
			case style
			when Symbol
				aspose_style = @workbook.created_styles[style]
				if aspose_style.nil?
					raise "Could not resolve created style: #{style}"
				end
				each_cell(rows,cols) do |row,col,cell|
					cell.setStyle(aspose_style)
				end
			when Hash
				each_cell(rows,cols) do |row,col,cell|
					aspose_style = cell.getStyle
					@workbook.modify_style(aspose_style,style)
					cell.setStyle(aspose_style)
				end
			end
		end

		def merge_cells(row_range,col_range)
			#To allow for specifying a single row or col we need
			#to coerce single values into ranges
			if row_range.is_a?(Fixnum)
				row_range = (row_range..row_range)
			end
			if col_range.is_a?(Fixnum)
				col_range = (col_range..col_range)
			end
			row_count = row_range.last - row_range.first + 1
			col_count = col_range.last - col_range.first + 1
			@aspose_worksheet.getCells.merge(row_range.first,col_range.first,row_count,col_count)
		end

		def auto_fit_columns(max_width=nil)
			@aspose_worksheet.autoFitColumns
			if !max_width.nil?
				resolve_col_range(nil).each do |col_index|
					if @aspose_worksheet.getCells.getColumnWidthInch(col_index) > max_width
						set_col_width(col_index,max_width)
					end
				end
			end
		end

		def set_col_width(col,width,unit=nil)
			case unit
			when :inches
				@aspose_worksheet.getCells.setColumnWidthInch(col, width)
			when :pixels
				@aspose_worksheet.getCells.setColumnWidthPixel(col, width)
			else
				@aspose_worksheet.getCells.setColumnWidth(col, width)
			end
		end

		def set_row_height(row,height,unit=nil)
			case unit
			when :inches
				@aspose_worksheet.getCells.setRowHeightInch(row, height)
			when :pixels
				@aspose_worksheet.getCells.setRowHeightPixel(row, height)
			else
				@aspose_worksheet.getCells.setRowHeight(row, height)
			end
		end

		def auto_fit_rows
			@aspose_worksheet.autoFitRows
		end

		def set_landscape
			page_setup = @aspose_worksheet.getPageSetup
			page_setup.setOrientation(AsposeCells::PageOrientationType::LANDSCAPE)
		end

		def set_portrait
			page_setup = @aspose_worksheet.getPageSetup
			page_setup.setOrientation(AsposeCells::PageOrientationType::PORTRAIT)
		end

		def set_print_gridlines(value)
			page_setup = @aspose_worksheet.getPageSetup
			page_setup.setPrintGridlines(value)
		end

		private

		def aspose_workbook
			return @aspose_worksheet.getWorkbook
		end

		def get_cell(row,col)
			return @aspose_worksheet.getCells.get(row,col)
		end

		def resolve_row_range(rows)
			row_set = Array(rows)
			if rows.nil?
				row_set = (0..@aspose_worksheet.getCells.getMaxDataRow)
			end
			return row_set
		end

		def resolve_col_range(cols)
			col_set = Array(cols)
			if cols.nil?
				col_set = (0..@aspose_worksheet.getCells.getMaxDataColumn)
			end
			return col_set
		end
	end
end