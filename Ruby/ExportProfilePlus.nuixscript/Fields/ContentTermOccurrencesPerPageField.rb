class ContentTermOccurrencesPerPageField < CustomFieldBase
  def name
    'Content Term Occurrences Per Page'
  end

  def tool_tip
    "Yields the number of words per page. Uses 'Content Term Occurrences Per Page' for the word count, if available as custom metadata."
  end

  def dependencies
    1
  end

  def decorate(profile)
    profile.addMetadata(name) do |item|
      begin
        image_info = item.get_printed_image.get_info
        # Ensure item has a stored PDF
        next if image_info.nil?
        # Ensure it's not slipsheeted
        next if image_info.is_slip_sheet

        words = content_term_occurrences(item)
        # Ensure word count is an integer
        next words unless words.is_a?(Integer)

        next (words / image_info.get_page_count)
      rescue Exception => e
        next "Error: #{e.message}"
      end
    end
  end

  def content_term_occurrences(item)
    # Check if custom metadata field exists
    words = item.get_custom_metadata.get('Content Term Occurrences')
    return words if words.is_a?(Integer)

    case_stats = $current_case.getStatistics
    term_stats = case_stats.getTermStatistics("guid:#{item.getGuid}", 'field' => 'content')
    term_stats.map { |_t, c| c }.reduce(0, :+)
  rescue Exception => e
    "Error getting word count: #{e.message}"
  end
end
