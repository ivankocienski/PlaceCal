# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @neighbourhood_region_admin = create(:neighbourhood_region_admin)
  end

  test 'owned neighbourhoods returns all descendants' do
    # Does the admin only own one region neighbourhood?
    assert @neighbourhood_region_admin.neighbourhoods.length == 1
    assert @neighbourhood_region_admin.neighbourhoods.first.unit == 'region'

    # Does it return the region, the districts, and the wards?
    # We have five counties with one district each, all parenting one ward, plus the region
    # (See: factories/user.rb - neighbourhood_region_admin)
    owned_length = 1 + (5 * 3)
    assert @neighbourhood_region_admin.owned_neighbourhoods.to_a.length == owned_length

    # does it actually return both the districts and the wards?
    assert @neighbourhood_region_admin.owned_neighbourhoods.find_all { |u| u.unit == 'county' }.length   == 5
    assert @neighbourhood_region_admin.owned_neighbourhoods.find_all { |u| u.unit == 'district' }.length == 5
    assert @neighbourhood_region_admin.owned_neighbourhoods.find_all { |u| u.unit == 'ward' }.length     == 5
  end

  test 'can edit neighourhoods' do
    region = @neighbourhood_region_admin.neighbourhoods.first

    owned_neighbourhoods = @neighbourhood_region_admin.owned_neighbourhoods

    county   = owned_neighbourhoods.find_all { |u| u.unit == 'county' }.first
    district = owned_neighbourhoods.find_all { |u| u.unit == 'district' }.first
    ward     = owned_neighbourhoods.find_all { |u| u.unit == 'ward' }.first

    # We do not have permissions to edit the country!
    assert (@neighbourhood_region_admin.can_alter_neighbourhood? region.parent) == false

    # We should have permissions to edit a county, district, or ward neighbourhood
    assert @neighbourhood_region_admin.can_alter_neighbourhood?(county)
    assert @neighbourhood_region_admin.can_alter_neighbourhood?(district)
    assert @neighbourhood_region_admin.can_alter_neighbourhood?(ward)
  end

  test 'updates user role on save' do
    # Does this person manage at least one partner?
    @user.partners << create(:partner)
    @user.save
    assert @user.partner_admin?

    # Does this person manage at least one tag?
    @user.tags << create(:tag)
    @user.save
    assert @user.tag_admin?

    # Is this person a root? If they are, they're also a secretary
    @user.update(role: :root)
    assert @user.root?
  end

  test 'full name method gives sensible responses' do
    @user.update(first_name: 'Joan', last_name: '')
    assert_equal 'Joan', @user.full_name
    @user.update(first_name: '', last_name: 'Jones')
    assert_equal 'Jones', @user.full_name
    @user.update(first_name: 'Joan', last_name: 'Jones')
    assert_equal 'Joan Jones', @user.full_name
  end

  test 'admin name method gives sensible responses' do
    @user.update(first_name: 'Joan', last_name: '')
    assert_equal "Joan <#{@user.email}>", @user.admin_name
    @user.update(first_name: '', last_name: 'Jones')
    assert_equal "JONES <#{@user.email}>", @user.admin_name
    @user.update(first_name: 'Joan', last_name: 'Jones')
    assert_equal "JONES, Joan <#{@user.email}>", @user.admin_name
  end

  test 'without skip_password_validation' do
    user = User.new(email: 'test@test.com', role: 'citizen')
    assert_equal false, user.valid?
  end

  test 'with skip_password_valiation' do
    user = User.new(email: 'test@test.com', role: 'citizen')
    user.skip_password_validation = true
    assert_equal true, user.valid?

  end
end
