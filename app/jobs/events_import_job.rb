class EventsImportJob < ApplicationJob

  # calendar_id - object id of calendar to be imported.
  # date - import events starting from this date. Must use format 'yyyy-mm-dd'.
  def perform(calendar_id: nil, date: nil, user_id: nil)
    from = date.present? ? Time.zone.parse(date) : Date.current.beginning_of_day

    if calendar_id.present?
      import_events_from_source(calendar_id, from)
    else
      Calendar.find_each do |calendar|
        import_events_from_source(calendar.id, from)
      end
    end

    if user_id
      user = User.find(user_id)
      EventsImportChannel.broadcast_to(user)
    end
  end

  def import_events_from_source(calendar_id, from)
    calendar = Calendar.find(calendar_id)
    calendar.import_events(from)
  rescue CalendarParser::InaccessibleFeed, CalendarParser::UnsupportedFeed => e
    calendar.critical_import_failure(e)
  rescue StandardError => e
    # TODO: Inform admin(s) when this fails
    error = "Could not automatically import data for calendar #{calendar.name} (id #{calendar_id}):  #{e}"
    calendar.critical_import_failure(error)
    puts error
    Rollbar.error error
    nil
  end
end
