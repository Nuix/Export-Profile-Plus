# Menu Title: Export Profile Plus
# Needs Selected Items: true

# Written by Jason Wells
# Contributions by Michael Kamida
# Tested against Nuix 8.4

#===================#
# Load Dependencies #
#===================#
script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.controls.models.Choice"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

load File.join(script_directory,"Xlsx.rb")
load File.join(script_directory,"CustomFieldBase.rb")
load File.join(script_directory,"DAT.rb")
load File.join(script_directory,"TSV.rb")
load File.join(script_directory,"HTML.rb")
load File.join(script_directory,"FilenameSuffixer.rb")

# Load field class files
fields_directory = File.join(script_directory,"Fields")
Dir.glob(File.join(fields_directory,"**","*.rb")).each do |field_class_file|
	load field_class_file
end

require 'csv'

#===================#
# Initialize Dialog #
#===================#

#Make sure some items are selected
if $current_selected_items.nil? || $current_selected_items.size < 1
	CommonDialogs.showError("This script requires that some items be selected before running it.")
	exit 1
end

# Get listing of existing metadata profile names
profile_names = $utilities.getMetadataProfileStore.getMetadataProfiles.map{|p|p.getName}

# Build a list of choices based on script based fields we loaded earlier
custom_fields = CustomFieldBase.fields.sort_by{|f|f.name}
puts "Custom Fields:"
puts custom_fields.map{|cf|"\t#{cf.name}"}.join("\n")
custom_field_choices = custom_fields.map{|cf|Choice.new(cf,cf.name,cf.tool_tip)}

# Build our settings dialog
dialog = TabbedCustomDialog.new("Export Profile Plus")

profile_tab = dialog.addTab("profile_tab","Profile Fields")
profile_tab.appendCheckBox("use_base_profile","Build Upon Base Profile",false)
profile_tab.appendComboBox("base_profile","Base Profile",profile_names)
profile_tab.enabledOnlyWhenChecked("base_profile","use_base_profile")
profile_tab.appendChoiceTable("custom_fields","Additional Fields",custom_field_choices)
profile_tab.appendCheckBox("handle_excluded_items","Do not report on excluded items",true)
profile_tab.appendTextField("multi_value_delimiter","Multi-value Field Delimiter","; ")

load_file_tab = dialog.addTab("load_file_tab","Load Files")
load_file_tab.appendCheckBox("export_csv","Export CSV",false)
load_file_tab.appendSaveFileChooser("csv_file","CSV File","Comma Separated Values","csv")
load_file_tab.enabledOnlyWhenChecked("csv_file","export_csv")

load_file_tab.appendCheckBox("export_dat","Export DAT",false)
load_file_tab.appendSaveFileChooser("dat_file","DAT File","DAT File","dat")
load_file_tab.enabledOnlyWhenChecked("dat_file","export_dat")

load_file_tab.appendCheckBox("export_tsv","Export TSV",false)
load_file_tab.appendSaveFileChooser("tsv_file","TSV File","TSV File","tsv")
load_file_tab.enabledOnlyWhenChecked("tsv_file","export_tsv")

load_file_tab.appendCheckBox("export_xlsx","Export XLSX",false)
load_file_tab.appendSaveFileChooser("xlsx_file","XLSX File","XLSX File","xlsx")
load_file_tab.enabledOnlyWhenChecked("xlsx_file","export_xlsx")

load_file_tab.appendCheckBox("export_html","Export HTML",false)
load_file_tab.appendSaveFileChooser("html_file","HTML File","HTML File","html")
load_file_tab.enabledOnlyWhenChecked("html_file","export_html")

load_file_tab.appendCheckBox("export_custom","Export custom format",false)
load_file_tab.appendSaveFileChooser("custom_file","Custom File","Text File","txt")
load_file_tab.appendTextField("custom_delimiter","Custom Delimiter","|")
load_file_tab.appendTextField("custom_quote","Custom Quote","")
load_file_tab.enabledOnlyWhenChecked("custom_file","export_custom")
load_file_tab.enabledOnlyWhenChecked("custom_delimiter","export_custom")
load_file_tab.enabledOnlyWhenChecked("custom_quote","export_custom")

# Settings regarding overflow into new file/sheet when we exceed a given record count
load_file_tab.appendSeparator("Record Overflow")
load_file_tab.appendCheckBox("overflow_records","Overflow into new file/sheet when record count exceeds maximum",false)
load_file_tab.appendSpinner("maximum_records","Maximum records per file/sheet",1_000_000,100,100_000_000,100)
load_file_tab.enabledOnlyWhenChecked("maximum_records","overflow_records")

cm_tab = dialog.addTab("cm_tab","Custom Metadata")
cm_tab.appendCheckBox("apply_custom_metadata","Apply as Custom Metadata Fields",false)

scm_tab = dialog.addTab("scm_tab","Concatenated Custom Metadata")
scm_tab.appendCheckBox("single_custom_metadata","Apply as Single Concatenated Custom Metadata Field",false)
scm_tab.appendTextField("scm_field_name","Field Name","ProfileValues")
scm_tab.appendCheckBox("scm_include_names","Include Field Names",true)
scm_tab.appendCheckBox("scm_skip_empty","Exclude Null or Empty Values",false)
scm_tab.enabledOnlyWhenChecked("scm_field_name","single_custom_metadata")
scm_tab.enabledOnlyWhenChecked("scm_include_names","single_custom_metadata")
scm_tab.enabledOnlyWhenChecked("scm_skip_empty","single_custom_metadata")

all_item_sets = $current_case.getAllItemSets
# ItemSet.findDuplicates errors for item sets created with a scripted expression
non_scripted_item_sets = all_item_sets.reject{|set| set.getSettings["deduplication"] == "SCRIPTED"}
item_set_choices = non_scripted_item_sets.map{|set|Choice.new(set,set.getName)}

item_sets_tab = dialog.addTab("item_sets_tab","Item Sets")
item_sets_tab.appendHeader("This tab allows you to define items sets used in scripted fields which require a selected item set.")
item_sets_tab.appendChoiceTable("item_sets","Item Sets",item_set_choices)

prod_sets_tab = dialog.addTab("prod_sets_tab","Production Sets")
prod_sets_tab.appendHeader("This tab allows you to define production sets used in scripted fields which require a selected production set.")
prod_set_choices = $current_case.getProductionSets.map{|prod|Choice.new(prod,prod.getName)}
prod_sets_tab.appendChoiceTable("production_sets","Production Sets",prod_set_choices)

# Define validations of user settings
dialog.validateBeforeClosing do |values|
	# Make sure that if were exporting CSV that file path was provided
	if values["export_csv"] && values["csv_file"].empty?
		CommonDialogs.showWarning("Please provide a valid value for CSV File.")
		next false
	end

	# Make sure that if were exporting DAT that file path was provided
	if values["export_dat"] && values["dat_file"].empty?
		CommonDialogs.showWarning("Please provide a valid value for DAT File.")
		next false
	end

	# Make sure that if were exporting TSV that file path was provided
	if values["export_tsv"] && values["tsv_file"].empty?
		CommonDialogs.showWarning("Please provide a valid value for TSV File.")
		next false
	end

	# Make sure that if were exporting HTML that file path was provided
	if values["export_html"] && values["html_file"].empty?
		CommonDialogs.showWarning("Please provide a valid value for HTML File.")
		next false
	end

	# Make sure that if were exporting XLSX that file path was provided
	if values["export_xlsx"] && values["xlsx_file"].empty?
		CommonDialogs.showWarning("Please provide a valid value for XLSX File.")
		next false
	end

	# If exporting XLSX warn about potential field value truncation
	if values["export_xlsx"] && values["custom_fields"].any?{|cf| cf.name == "Item Text"}
		message = "You are exporting field 'Item Text' to an XLSX spreadsheet.\n"
		message << "Excel has a 32K character limit per cell.  Text longer than this will be truncated!\n"
		message << "Are you sure you want to proceed?"
		title = "Proceed with possible text truncation?"
		confirmed = CommonDialogs.getConfirmation(message,title)
		if !confirmed
			next false
		end
	end

	# If exporting custom delimited format make sure user provided file path
	if values["export_custom"] && values["custom_file"].strip.empty?
		CommonDialogs.showWarning("Please provide a valid value for Custom File.")
		next false
	end

	# If user did not select any script based fields make sure that was there intent
	if values["custom_fields"].size < 1
		if values["use_base_profile"]
			message = "You have no additional fields selected, are you sure you want to proceed?"
			title = "Proceed without additional fields?"
			confirmed = CommonDialogs.getConfirmation(message,title)
			if !confirmed
				next false
			end
		else
			# If we reached here neither a base profile nor script based fields were selected
			# so we have nothing to be exported
			CommonDialogs.showWarning("When not using a base profile, at least one additional field must be selected.")
			next false
		end
	end

	# If exporting concatenated values into single custom metadata field make sure
	# user has provided a custom metadata field name
	if values["single_custom_metadata"]
		if values["scm_field_name"].nil? || values["scm_field_name"].empty?
			CommonDialogs.showWarning("Please provide a valid value for 'Field Name'.")
			next false
		end
	end

	# Warn user that we will be closing all workbench tabs if we are going to be applying
	# custom metadata to items
	if values["single_custom_metadata"] || values["apply_custom_metadata"]
		message = "The script needs to close all workbench tabs when applying custom metadata, proceed?"
		title = "Close all tabs?"
		if !CommonDialogs.getConfirmation(message,title)
			next false
		end
	end

	# If using fields that require item set selection make sure item sets are selected
	if values["item_sets"].size < 1
		if values["custom_fields"].any?{|cf|cf.needs_item_set == true}
			CommonDialogs.showWarning("Please select at least one item set on the item sets tab.")
			next false
		end
	end

	# If using fields that require production set selection make sure production sets are selected
	if values["production_sets"].size < 1
		if values["custom_fields"].any?{|cf|cf.needs_prod_set == true}
			CommonDialogs.showWarning("Please select at least one production set on the production sets tab.")
			next false
		end
	end

	next true
end

def ensure_file_directory(file_path)
	java.io.File.new(file_path).getParentFile.mkdirs
end

#============================#
# Display Dialog and Do Work #
#============================#
dialog.display
if dialog.getDialogResult == true
	puts "Beginning export..."
	start_time = Time.now

	items = $current_selected_items
	values = dialog.toMap

	CustomFieldBase.item_sets = values["item_sets"]
	CustomFieldBase.prod_sets = values["production_sets"]
	CustomFieldBase.handle_excluded_items = values["handle_excluded_items"]
	CustomFieldBase.delimiter = values["multi_value_delimiter"]

	base_profile = nil
	if values["use_base_profile"]
		base_profile = $utilities.getMetadataProfileStore.getMetadataProfile(values["base_profile"])
	else
		base_profile = $utilities.getMetadataProfileStore.createMetadataProfile
	end

	ProgressDialog.forBlock do |pd|
		# Establish header order for export
		headers = base_profile.getMetadata.map(&:getName) + values['custom_fields'].map(&:name)
		# Sort and calculate custom values
		values['custom_fields'].sort_by(&:dependencies).each do |custom_field|
			#Allow custom fields to perform any initialization
			pd.logMessage("Performing setup: #{custom_field.name}")
			custom_field.setup(items)
			pd.logMessage("Attaching scripted field: #{custom_field.name}")
			base_profile = custom_field.decorate(base_profile)
		end
		# Build Hash of {name => MetadataItem} that will be exported
		export_fields = {}
		base_profile.get_metadata.each { |m| export_fields[m.get_name] = m }

		pd.logMessage("Selected Items: #{items.size}")
		if values["use_base_profile"]
			pd.logMessage("Base Profile: #{values["base_profile"]}")
		end
		pd.logMessage("Additional Fields:")
		values["custom_fields"].each do |custom_field|
			pd.logMessage("\t#{custom_field.name}")
		end
		pd.logMessage("CSV File: #{values["csv_file"]}") if values["export_csv"]
		pd.logMessage("DAT File: #{values["dat_file"]}") if values["export_dat"]
		pd.logMessage("TSV File: #{values["tsv_file"]}") if values["export_tsv"]
		pd.logMessage("XLSX File: #{values["xlsx_file"]}") if values["export_xlsx"]

		pd.setTitle("Export Profile Plus")
		pd.setMainProgress(0,items.size)
		pd.setSubProgressVisible(false)

		pd.setMainStatusAndLogIt("Exporting...")
		
		# Initialize variables which will be used to hold writers to
		# various formats we might be exporting
		csv = nil
		dat = nil
		tsv = nil
		html = nil
		xlsx = nil
		sheet = nil
		custom = nil

		# Will be using this to periodically report progress updates
		last_progress = Time.now

		# Extract settings dialog values into convenient variables
		export_csv = values["export_csv"]
		export_dat = values["export_dat"]
		export_tsv = values["export_tsv"]
		export_xlsx = values["export_xlsx"]
		export_html = values["export_html"]
		export_custom = values["export_custom"]
		custom_delimiter = values["custom_delimiter"]
		custom_quote = values["custom_quote"]
		include_names = values["scm_include_names"]
		custom_field_name = values["scm_field_name"]
		scm_skip_empty = values["scm_skip_empty"]
		single_custom_metadata = values["single_custom_metadata"]
		apply_custom_metadata = values["apply_custom_metadata"]
		overflow_records = values["overflow_records"]
		maximum_records = values["maximum_records"]

		html_file = values["html_file"]
		csv_file = values["csv_file"]
		dat_file = values["dat_file"]
		tsv_file = values["tsv_file"]
		xlsx_file = values["xlsx_file"]
		custom_file_name = values["custom_file"]

		# If user has enabled record overflow, check if the number of items we are exporting
		# exceeds the maximum.  We will then change how we name the exported files to account for this.
		will_need_overflow = (overflow_records && items.size > maximum_records)

		# Used to suffix file/sheet names for record overflow
		overflow_index = 1

		# Zero file width for overflow naming
		# Ex 2: File_01, File_02 / Sheet 01, Sheet 02
		overflow_naming_width = 2

		# How many records written to current files
		current_record_count = 0

		# If were applying custom metadata its a good idea we close all workbench
		# tabs first, may improve performance and reduce potential errors
		if values["single_custom_metadata"] || values["apply_custom_metadata"]
			$window.closeAllTabs
		end

		# Open writers for the various formats we're exporting to
		ensure_file_directory(html_file) if export_html
		ensure_file_directory(csv_file) if export_csv
		ensure_file_directory(dat_file) if export_dat
		ensure_file_directory(tsv_file) if export_tsv

		# Create all the formats we will be exporting to
		html = HTML.create(html_file) if export_html
		csv = CSV.open(csv_file,"w:utf-8") if export_csv
		dat = DAT.create(dat_file) if export_dat
		tsv = TSV.create(tsv_file) if export_tsv
		if export_xlsx
			xlsx = Xlsx.new
			if will_need_overflow
				sheet = xlsx.get_sheet("Export #{overflow_index.to_s.rjust(overflow_naming_width,"0")}")
			else
				sheet = xlsx.get_sheet("Export")
			end
		end
		custom_file = File.open(custom_file_name,"w:utf-8") if export_custom

		# Write headers to all formats we're exporting to
		csv << headers if export_csv
		dat << headers if export_dat
		tsv << headers if export_tsv
		html.begin_table(headers) if export_html
		sheet << headers if export_xlsx
		if export_custom
			custom_file.puts(headers.map{|v|"#{custom_quote}#{v}#{custom_quote}"}.join(custom_delimiter))
		end

		last_col = headers.size - 1

		# Iterate each item
		items.each_with_index do |item,item_index|
			# Break from iteration if user requested abort in the progress dialog
			break if pd.abortWasRequested

			# Periodically update progress dialog
			if (Time.now - last_progress) > 0.5
				pd.setMainProgress(item_index+1)
				pd.setSubStatus("#{item_index+1}/#{items.size}")
				last_progress = Time.now
			end
			
			# Have each column evaluate against the given item and
			# build up collection of column values into a Hash
			record_values = export_fields.transform_values { |f| f.evaluate(item) }

			# If we're applying custom metadata for each column
			# record it now
			if apply_custom_metadata
				cm = item.getCustomMetadata
				headers.each do |header|
					# Handle a couple fields we know will give us an internal Nuix class when we call evaluateUnformatted
					if header == "Position" || header == "Language"
						cm[header] = record_values[header]
					else
						# Record raw value as custom metadata
						raw_value = export_fields[header].evaluateUnformatted(item)

						# Try to handle some of the undocumented internal data type evaluateUnformatted may provide back
						if raw_value.nil?
							raw_value = ""
						elsif raw_value.is_a?(com.nuix.common.ByteSize)
							raw_value = raw_value.getValue
						elsif raw_value.is_a?(com.nuix.util.expression.MultiValue) || raw_value.is_a?(com.nuix.filetype.MimeType)
							raw_value = record_values[header]
						end

						# First we will try to store as the actual data type returned by evaluateUnformatted
						raw_value_success = false
						begin
							cm[header] = raw_value
							raw_value_success = true
						rescue Exception => exc
							# This both logs that we stored the value as a string and leaves a breadcrumb of the item/field/data type that we had
							# issue with, in case we hope to add logic to handle the particular data type later
							puts "Unable to store raw value#{item.getLocalisedName} / #{item.getGuid} / #{header} / #{raw_value.class}, storing value as string"
						end

						# As a fallback we will just store the value as a string like the script used to
						if !raw_value_success
							cm[header] = record_values[header]
						end
					end
				end
			end

			# Are we overflowing and have we exceeded maximum records for current files/sheet?
			# If so we need to close everything out and start fresh
			if overflow_records && current_record_count >= maximum_records
				
				overflow_index += 1

				# Steps to close things out
				csv.close if !csv.nil?
				dat.close if !dat.nil?
				tsv.close if !tsv.nil?
				html.close if !html.nil?
				if !xlsx.nil?
					xlsx.save(values["xlsx_file"])
				end
				custom_file.close if !custom_file.nil?

				# Steps to start new files/sheet
				html = HTML.create(FilenameSuffixer.add_suffix(html_file,overflow_index,overflow_naming_width)) if export_html
				csv = CSV.open(FilenameSuffixer.add_suffix(csv_file,overflow_index,overflow_naming_width),"w:utf-8") if export_csv
				dat = DAT.create(FilenameSuffixer.add_suffix(dat_file,overflow_index,overflow_naming_width)) if export_dat
				tsv = TSV.create(FilenameSuffixer.add_suffix(tsv_file,overflow_index,overflow_naming_width)) if export_tsv
				if export_xlsx
					sheet = xlsx.get_sheet("Export #{overflow_index.to_s.rjust(overflow_naming_width,"0")}")
				end
				custom_file = File.open(FilenameSuffixer.add_suffix(custom_file_name,overflow_index,overflow_naming_width),"w:utf-8") if export_custom

				# Write headers to new files/sheet
				csv << headers if export_csv
				dat << headers if export_dat
				tsv << headers if export_tsv
				html.begin_table(headers) if export_html
				sheet << headers if export_xlsx
				if export_custom
					custom_file.puts(headers.map{|v|"#{custom_quote}#{v}#{custom_quote}"}.join(custom_delimiter))
				end

				current_record_count = 0
			end

			# Get array of values sorted in order of the headers
			ordered_values = headers.map { |h| record_values[h] }
			# Write values to the various formats we may be exporting to
			csv << ordered_values.map{|v|v.gsub(/[\r\n]/," ")} if export_csv
			dat << ordered_values if export_dat
			tsv << ordered_values if export_tsv
			html << ordered_values if export_html
			if export_xlsx
				sheet << ordered_values.map do |v|
					if v.is_a?(String) && v.size > 32000
						next v[0...32000]
					else
						next v
					end
				end
			end
			if export_custom
				custom_file.puts(ordered_values.map{|v|"#{custom_quote}#{v}#{custom_quote}"}.join(custom_delimiter))
			end

			current_record_count += 1

			# If were annotating concatenated values into single field lets do that now
			if single_custom_metadata
				custom_field_value = ""
				headers.each do |header|
					column_value = record_values[header]
					next if scm_skip_empty && (column_value.nil? || column_value.strip.empty?)
					
					if include_names
						custom_field_value << header
						custom_field_value << ": ".freeze
					end
					custom_field_value << column_value
					custom_field_value << ';'
				end
				# End final value with ':' instead of ';'
				unless custom_field_value.empty?
					custom_field_value.chop!
					custom_field_value << ':'
				end
				item.getCustomMetadata.putText(custom_field_name,custom_field_value)
			end
		end

		# If user did not cancel show a final progress number
		if !pd.abortWasRequested
			pd.setMainProgress(items.size)
			pd.setSubStatus("#{items.size}/#{items.size}")
		end

		# Close out all the file formats we have been writing to
		csv.close if !csv.nil?
		dat.close if !dat.nil?
		tsv.close if !tsv.nil?
		html.close if !html.nil?
		if !xlsx.nil?
			xlsx.save(values["xlsx_file"])
		end
		custom_file.close if !custom_file.nil?

		# Show a final progress depending on whether user aborted or not
		if pd.abortWasRequested
			pd.setMainStatusAndLogIt("User Aborted")
		else
			pd.setMainStatusAndLogIt("Export Completed")
		end
	end

	#Allow custom fields to perform any cleanup
	values["custom_fields"].each do |custom_field|
		custom_field.cleanup
	end

	finish_time = Time.now
	puts "Completed in #{finish_time - start_time} seconds"

	# If we closed all the workbench tabs, we should also open a new one
	# back up for the user now that were done
	if values["single_custom_metadata"] || values["apply_custom_metadata"]
		$window.openTab("workbench",{:search=>""})
	end
end