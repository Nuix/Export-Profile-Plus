# Menu Title: Export Profile Plus
# Needs Selected Items: true

# Written by Jason Wells
# Tested against Nuix 6.2

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

load File.join(script_directory,"Xlsx.rb")
load File.join(script_directory,"CustomFieldBase.rb")
load File.join(script_directory,"DAT.rb")

# Load field class files
fields_directory = File.join(script_directory,"Fields")
Dir.glob(File.join(fields_directory,"**","*.rb")).each do |field_class_file|
	load field_class_file
end

require 'csv'

#===================#
# Initialize Dialog #
#===================#
LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

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

load_file_tab = dialog.addTab("load_file_tab","Load Files")
load_file_tab.appendCheckBox("export_csv","Export CSV",false)
load_file_tab.appendSaveFileChooser("csv_file","CSV File","Comma Separated Values","csv")
load_file_tab.enabledOnlyWhenChecked("csv_file","export_csv")

load_file_tab.appendCheckBox("export_dat","Export DAT",false)
load_file_tab.appendSaveFileChooser("dat_file","DAT File","DAT File","dat")
load_file_tab.enabledOnlyWhenChecked("dat_file","export_dat")

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

item_sets_tab = dialog.addTab("item_sets_tab","Item Sets")
item_sets_tab.appendHeader("This tab allows you to define items sets used in scripted fields which require a selected item set.")
item_set_choices = $current_case.getAllItemSets.map{|set|Choice.new(set,set.getName)}
item_sets_tab.appendChoiceTable("item_sets","Item Sets",item_set_choices)

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

	next true
end

#============================#
# Display Dialog and Do Work #
#============================#
dialog.display
if dialog.getDialogResult == true
	puts "Beginning export..."

	items = $current_selected_items
	values = dialog.toMap

	CustomFieldBase.item_sets = values["item_sets"]

	base_profile = nil
	if values["use_base_profile"]
		base_profile = $utilities.getMetadataProfileStore.getMetadataProfile(values["base_profile"])
	else
		base_profile = $utilities.getMetadataProfileStore.createMetadataProfile
	end

	#Allow custom fields to perform any initialization
	values["custom_fields"].each do |custom_field|
		custom_field.setup(items)
	end	

	values["custom_fields"].each do |custom_field|
		base_profile = custom_field.decorate(base_profile)
	end

	export_fields = base_profile.getMetadata

	ProgressDialog.forBlock do |pd|
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
		pd.logMessage("XLSX File: #{values["xlsx_file"]}") if values["export_xlsx"]

		pd.setTitle("Export Profile Plus")
		pd.setMainProgress(0,items.size)
		pd.setSubProgressVisible(false)

		pd.setMainStatusAndLogIt("Exporting...")
		
		# Initialize variables which will be used to hold writers to
		# various formats we might be exporting
		csv = nil
		dat = nil
		xlsx = nil
		sheet = nil
		custom = nil

		# Will be using this to periodically report progress updates
		last_progress = Time.now

		# Extract settings dialog values into convenient variables
		export_csv = values["export_csv"]
		export_dat = values["export_dat"]
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

		# If were applying custom metadata its a good idea we close all workbench
		# tabs first, may improve performance and reduce potential errors
		if values["single_custom_metadata"] || values["apply_custom_metadata"]
			$window.closeAllTabs
		end

		# Open writers for the various formats we're exporting to
		html = File.open(values["html_file"],"w:utf-8") if export_html
		csv = CSV.open(values["csv_file"],"w:utf-8") if export_csv
		dat = DAT.create(values["dat_file"]) if export_dat
		if export_xlsx
			xlsx = Xlsx.new
			sheet = xlsx.get_sheet("Export")
		end
		custom_file = File.open(values["custom_file"],"w:utf-8") if export_custom

		# Get headers and write to all formats we're exporting to
		headers = export_fields.map{|f|f.getName}
		csv << headers if export_csv
		dat << headers if export_dat
		sheet << headers if export_xlsx
		if export_custom
			custom_file.puts(headers.map{|v|"#{custom_quote}#{v}#{custom_quote}"}.join(custom_delimiter))
		end

		# If we're exporting to HTML we will write the initial structure to it
		if export_html
			html << "<!DOCTYPE HTML>"
			html << "<html>"
			html << "<head><style>"
			html << ".label { vertical-align:top; }"
			html << ".value { }"
			html << "td { border-left:1px solid black; border-top:1px solid black; }"
			html << "table { border-right:1px solid black; border-bottom:1px solid black; border-collapse:collapse; width: 100%; }"
			html << "body { margin:50px 0px; padding:0px;text-align:center; font-family: arial; }"
			html << "pre { white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word; max-height:250px; overflow-y:scroll;}"
			html << "hr { margin-top: 40px; }"
			html << "#content { width:1024px; margin:0px auto; text-align:left; padding:15px; border:1px dashed #333; }"
			html << "</style></head>"
			html << "<body><div id=\"content\">"
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
			# build up collection of column values into an array
			record_values = export_fields.map{|f|f.evaluate(item)}

			# If we're applying custom metadata for each column
			# record it now
			if apply_custom_metadata
				cm = item.getCustomMetadata
				headers.each_with_index do |header,header_index|
					cm[header] = record_values[header_index]
				end
			end

			# Write values to the various formats we may be exporting to
			csv << record_values if export_csv
			dat << record_values if export_dat
			if export_xlsx
				sheet << record_values.map do |v|
					if v.is_a?(String) && v.size > 32000
						next v[0...32000]
					else
						next v
					end
				end
			end
			if export_custom
				custom_file.puts(record_values.map{|v|"#{custom_quote}#{v}#{custom_quote}"}.join(custom_delimiter))
			end
			if export_html
				html << "<hr/>"
				html << "<table>"
				headers.size.times do |c|
					html << "<tr><td class=\"label\"><b>#{headers[c]}</b></td><td class=\"value\"><pre>#{record_values[c]}</pre></td></tr>"
				end
				html << "</table>"
			end

			# If were annotating concatenated values into single field lets do that now
			if single_custom_metadata
				custom_field_value = ""
				headers.size.times do |col_index|
					column_value = record_values[col_index]
					next if scm_skip_empty && (column_value.nil? || column_value.strip.empty?)
					if include_names
						custom_field_value << headers[col_index]
						custom_field_value << ": ".freeze
					end
					custom_field_value << column_value
					custom_field_value << (col_index != last_col ? "; ".freeze : "".freeze)
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
		if !xlsx.nil?
			xlsx.save(values["xlsx_file"])
		end
		custom_file.close if !custom_file.nil?
		if !html.nil?
			html << "</div></body></html>"
			html.close
		end

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

	# If we closed all the workbench tabs, we should also open a new one
	# back up for the user now that were done
	if values["single_custom_metadata"] || values["apply_custom_metadata"]
		$window.openTab("workbench",{:search=>""})
	end
end