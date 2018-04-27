require 'test_helper'

class Superadmin::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = create(:event)
    @root = create(:root)
  end

  it_allows_root_to_access('get', :index) do
    get superadmin_events_url
  end

  it_denies_access_to_non_root('get', :index) do
    get superadmin_events_url
  end

  test 'superadmin: should get index' do
    sign_in @root
    get superadmin_events_url
    assert_response :success
  end

  test 'superadmin: should show event' do
    sign_in @root
    get superadmin_event_url(@event)
    assert_response :success
  end

  it_allows_root_to_access('get', :new) do
    get new_superadmin_event_url
  end

  it_denies_access_to_non_root('get', :new) do
    get new_superadmin_event_url
  end

  test 'superadmin: should get new' do
    sign_in @root
    get new_superadmin_event_url
    assert_response :success
  end

  test 'superadmin: should create event' do
    sign_in @root
    address = create(:address)

    assert_difference('Event.count') do
      post superadmin_events_url, params: { event: attributes_for(:event).merge( address_id: address.id ) }
    end

    assert_redirected_to superadmin_event_url(Event.last)
  end

  test 'superadmin: should get edit' do
    sign_in @root
    get edit_superadmin_event_url(@event)
    assert_response :success
  end

  test 'superadmin: should update event' do
    sign_in @root
    patch superadmin_event_url(@event), params: { event: attributes_for(:event) }
    assert_redirected_to superadmin_event_url(@event)
  end

  test 'superadmin: should destroy event' do
    sign_in @root
    assert_difference('Event.count', -1) do
      delete superadmin_event_url(@event)
    end

    assert_redirected_to superadmin_events_url
  end
end
