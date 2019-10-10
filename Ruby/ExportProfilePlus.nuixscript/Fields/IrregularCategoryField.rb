class IrregularCategoryField < CustomFieldBase
	def name
		return "Irregular Category"
	end

	def tool_tip
		return "Returns a delimited list of irregular categories the given item belongs to"
	end

	def decorate(profile)
		iutil = $utilities.getItemUtility
		return profile.addMetadata(self.name) do |item|
			begin
				result = []
				@irregular_reference_items.each do |name,items|
					if iutil.intersection([item],items).size > 0
						result << name
					end
				end
				next result.sort.join(CustomFieldBase.delimiter)
			rescue Exception => exc
				next "Error: #{exc.message}"
			end
		end
	end

	def setup(items)
		@irregular_categories = {
			"Corrupted Container" => "properties:FailureDetail AND encrypted:0 AND has-text:0 AND ( has-embedded-data:1 OR kind:container OR kind:database )",
			"Unsupported Container" => "kind:( container OR database ) AND encrypted:0 AND has-embedded-data:0 AND NOT flag:partially_processed AND NOT flag:not_processed AND NOT properties:FailureDetail",
			"Non-searchable PDFs" => "mime-type:application/pdf AND NOT content:*",
			"Text Updated" => "previous-version-docid:*",
			"Bad Extension" => "flag:irregular_file_extension",
			"Unrecognised" => "kind:unrecognised",
			"Unsupported Items" => "encrypted:0 AND has-embedded-data:0 AND ( ( has-text:0 AND has-image:0 AND NOT flag:not_processed AND NOT kind:multimedia AND NOT mime-type:application/vnd.ms-shortcut AND NOT mime-type:application/x-contact AND NOT kind:system AND NOT mime-type:( application/vnd.logstash-log-entry OR application/vnd.ms-iis-log-entry OR application/vnd.ms-windows-event-log-record OR application/vnd.ms-windows-event-logx-record OR application/vnd.tcpdump.record OR filesystem/x-ntfs-logfile-record OR server/dropbox-log-event OR text/x-common-log-entry OR text/x-log-entry ) AND NOT mime-type:( application/vnd.logstash-log OR application/vnd.logstash-log-entry OR application/vnd.ms-iis-log OR application/vnd.ms-iis-log-entry OR application/vnd.ms-windows-event-log OR application/vnd.ms-windows-event-log-record OR application/vnd.ms-windows-event-logx OR application/vnd.ms-windows-event-logx-chunk OR application/vnd.ms-windows-event-logx-record OR application/vnd.tcpdump.pcap OR application/vnd.tcpdump.record OR application/x-pcapng OR server/dropbox-log OR server/dropbox-log-event OR text/x-common-log OR text/x-common-log-entry OR text/x-log-entry OR text/x-nuix-log ) AND NOT mime-type:application/vnd.ms-exchange-stm ) OR mime-type:application/vnd.lotus-notes )",
			"Empty" => "mime-type:application/x-empty",
			"Encrypted" => "encrypted:1",
			"Decrypted" => "flag:decrypted",
			"Deleted" => "deleted:1",
			"Corrupted" => "properties:FailureDetail AND NOT encrypted:1",
			"Text Stripped" => "flag:text_stripped",
			"Text Not Indexed" => "flag:text_not_indexed",
			"Licence Restricted" => "flag:licence_restricted",
			"Not Processed" => "flag:not_processed",
			"Partially Processed" => "flag:partially_processed",
			"Text Not Processed" => "flag:text_not_processed",
			"Images Not Processed" => "flag:images_not_processed",
			"Reloaded" => "flag:reloaded",
			"Poisoned" => "flag:poison",
			"Slack Space" => "flag:slack_space",
			"Unallocated Space" => "flag:unallocated_space",
			"Carved" => "flag:carved",
			"Deleted - All Blocks Available" => "flag:fully_recovered",
			"Deleted - Some Blocks Available" => "flag:partially_recovered",
			"Deleted - Metadata Recovered" => "flag:metadata_recovered",
			"Hidden Stream" => "flag:hidden_stream",
		}

		@irregular_reference_items = {}
		@irregular_categories.each do |name,query|
			@irregular_reference_items[name] = $current_case.searchUnsorted(query)
		end
	end

	def cleanup
		@irregular_categories = nil
		@irregular_reference_items = nil
	end
end
