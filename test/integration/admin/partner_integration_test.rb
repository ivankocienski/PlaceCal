# frozen_string_literal: true

# rubocop:disable Style/StringLiterals

require 'test_helper'

class AdminPartnerIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = create(:root)
    @default_site = create_default_site
    @partner = create(:partner)
    get "http://admin.lvh.me"
    sign_in @admin
  end

  test "Edit form has correct fields" do
    get edit_admin_partner_path(@partner)
    assert_response :success

    assert_select 'h1', text: "Edit Partner: #{@partner.name}"

    assert_select 'h2', text: 'Basic Information'
    assert_select 'label', text: 'Name *'
    assert_select 'label', text: 'Summary'
    assert_select 'label', text: 'Description'
    assert_select 'label', text: 'Image'
    assert_select 'label', text: 'Website address'
    assert_select 'label', text: 'Facebook link'
    assert_select 'label', text: 'Twitter handle'

    assert_select 'h2', text: 'Address'
    assert_select 'label', text: 'Street address *'
    assert_select 'label', text: 'Street address 2'
    assert_select 'label', text: 'Street address 3'
    assert_select 'label', text: 'City'
    assert_select 'label', text: 'Postcode *'

    assert_select 'h2', text: 'Contact Information'
    assert_select 'h3', text: 'Public Contact'
    assert_select 'label', text: 'Public name'
    assert_select 'label', text: 'Public email'
    assert_select 'label', text: 'Public phone'
    assert_select 'h3', text: 'Partnership Contact'
    assert_select 'label', text: 'Partner name'
    assert_select 'label', text: 'Partner email'
    assert_select 'label', text: 'Partner phone'
  end
end
