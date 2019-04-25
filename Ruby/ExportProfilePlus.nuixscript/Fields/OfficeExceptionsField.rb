class OfficeExceptionsField < CustomFieldBase
	def initialize
	end	

	def name
		return "Office Exceptions"
	end

	def tool_tip
		return "Yields a delimited list of details relating to office documents."
	end

	def decorate(profile)
		return profile.addMetadata(self.name) do |item|
			begin
				props = item.getProperties
				rtOfficeExceptionsArr = []
				rtOfficeExceptionsArr << "Contains Comments" if props["Contains Comments"]
				rtOfficeExceptionsArr << "Contains Hidden Slides" if props["Contains Hidden Slides"]
				rtOfficeExceptionsArr << "Contains Hidden Text" if props["Contains Hidden Text"]
				rtOfficeExceptionsArr << "Contains White Text" if props["Contains White Text"]
				rtOfficeExceptionsArr << "Excel Hidden Columns" if props["Excel Hidden Columns"]
				rtOfficeExceptionsArr << "Excel Hidden Rows" if props["Excel Hidden Rows"]
				rtOfficeExceptionsArr << "Excel Hidden Sheets" if props["Excel Hidden Sheets"]
				rtOfficeExceptionsArr << "Excel Hidden Workbook" if props["Excel Hidden Workbook"]
				rtOfficeExceptionsArr << "Excel Protected Sheets" if props["Excel Protected Sheets"]
				rtOfficeExceptionsArr << "Excel Very Hidden Sheets" if props["Excel Very Hidden Sheets"]
				rtOfficeExceptionsArr << "Excel Workbook Write Protected" if props["Excel Workbook Write Protected"]
				rtOfficeExceptionsArr << "Excel Print Areas" if props["Excel Print Areas"]
				rtOfficeExceptionsArr << "Track Changes" if props["Contains Track Changes"] || props["Track Changes"]

				next rtOfficeExceptionsArr.join(CustomFieldBase.delimiter)
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end
end