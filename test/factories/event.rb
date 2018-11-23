# frozen_string_literal: true

FactoryBot.define do
  factory(:event) do
    summary { 'N.A (Narcotics Anonymous)' }
    raw_location_from_source { 'Unformatted Address, Ungeolocated Lane, Manchester' }
    dtstart { Time.now + 1.day }
    dtend { Time.now + 1.day + 2.hours }
    is_active { true }
    address

    trait :with_place do
      association :place, factory: :partner
    end

    trait :with_partner do
      association :partner
    end
  end
end
