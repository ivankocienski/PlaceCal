module Events
  class XmlEvent < DefaultEvent

    def initialize(event)
      @event = event
    end

    def uid
      @event.attribute('id').text
    end

    def summary
      @event.at_css('name').text.gsub(/\A(\n)+\z/, '').strip
    end

    def description
      @event.at_css('description').text.gsub(/\A(\n)+\z/, '').strip
    end

    def location
    end

    def recurring_event?
      true
    end

    def occurrences
      @occurrences = []

      @event.css('events').each do |events|
        events.xpath('event').each do |event|
          start_time = DateTime.parse(event.at_css('opening_time_iso'))
          @occurrences << Dates.new(start_time, start_time + 1.hour, event.at_css('status').text)
        end
      end

      @occurrences
    end
  end
end
