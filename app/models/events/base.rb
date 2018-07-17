# frozen_string_literal: true

module Events
  class Base
    Dates = Struct.new(:start_time, :end_time, :status)

    def initialize(event)
      @event = event
    end

    attr_accessor :place_id, :address_id, :partner_id

    def rrule
      nil
    end

    # Convert h1 and h2 to h3
    # Strip out all shady tags
    # Convert all html to markdown
    def html_sanitize(input)
      return if input.blank?

      allowed_tags = %w[a strong b em i ul ol li blockquote h3 h4 h5 h6]

      str = Nokogiri::HTML.fragment(input)
      str.css(*['h1', 'h2']).each { |header| header.name = 'h3' }
      str = str.to_s

      str = ActionController::Base.helpers.sanitize(str, tags: allowed_tags)

      Kramdown::Document.new(str).to_html
    end

    def attributes
      { uid:         uid&.strip,
        summary:     summary,
        description: description,
        location:    location&.strip,
        rrule:       rrule,
        place_id:    place_id,
        address_id:  address_id,
        partner_id:  partner_id,
        footer:      footer
      }
    end

    def footer; end

    def recurring_event?
      false
    end

    def postcode
      postal = location.match(Address::POSTCODE_REGEX).try(:[], 0)
      postal = /M[1-9]{2}(?:\s)?(?:[1-9])?/.match(location).try(:[], 0) if postal.blank? # check for instances of M14 or M15 4 or whatever madness they've come up with

      if postal.blank?
        # See if Google returns a more informative address
        results = Geocoder.search(location)
        if results.first
          formatted_address = results.first.data['formatted_address']

          postal = Address::POSTCODE_REGEX.match(formatted_address).try(:[], 0)
        end
      end

      postal
    end

    def ip_class
      @event&.ip_class if @event.respond_to?(:ip_class)
    end

    def private?
      ip_class&.casecmp('private')&.zero? || (@event.description&.include?('#placecal-ignore'))
    end
  end
end