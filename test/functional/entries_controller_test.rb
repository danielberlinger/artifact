require 'test_helper'

class EntriesControllerTest < ActionController::TestCase

  setup do
    @token1, @token2 = '123', '456'
    @e1 = FactoryGirl.create(:entry, :title => 'Entry1', :access_token => @token1, :access_token_expires_at => 2.days.from_now)
    @e2 = FactoryGirl.create(:entry, :title => 'Entry2', :access_token => @token2, :access_token_expires_at => 2.days.ago)
  end

  context 'signed in user' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in :user, @user
    end

    should 'view index' do
      get :index

      assert_response :success
      assert_match(/Entry(1|2)/, response.body)
    end

    should 'view index by tag' do
      get :show_by_tag, :tag => 'foo'

      assert_response :success
    end

    should 'be allowed to search' do
      get :search, :query => 'Entry1'

      assert_response :success
      assert_match(/Entry1/, response.body)
    end

    should 'view "new" page' do
      get :new

      assert_response :success
    end

    should 'be allowed to create entry' do
      post :create, :entry => {:title => 'Entry3', :content => 'foo'}

      assert_response :redirect
      assert assigns(:entry)
      assert_redirected_to(entry_path(assigns(:entry)))
    end

    should 'view "edit" page' do
      get :edit, :id => @e1

      assert_response :success
    end

    should 'be allowed to update entry' do
      put :update, :id => @e1, :entry => {:title => 'Entry21', :content => 'other'}

      assert_response :redirect
      assert assigns(:entry)
      assert_redirected_to(entry_path(assigns(:entry)))
    end

    should 'be allowed to delete entry' do
      assert_difference 'Entry.count', -1 do
        delete :destroy, :id => @e1
      end

      assert_response :redirect
      assert_redirected_to(entries_path())
    end

    should 'view details page' do
      get :show, :id => @e1

      assert_response :success
    end

    should 'be allowed to set access token' do
      @e1.access_token = nil
      @e1.save!

      put :set_token, :id => @e1

      assert_not_nil @e1.reload.access_token
    end

    should 'be allowed to remove access token' do
      assert_not_nil @e1.access_token

      delete :remove_token, :id => @e1

      assert_nil @e1.reload.access_token
    end
  end

  context 'anonymous user' do
    setup do
      session.clear
    end

    should 'NOT view index' do
      get :index

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'NOT view index by tag' do
      get :show_by_tag, :tag => 'foo'

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'NOT be allowed to search' do
      get :search, :query => 'Entry1'

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'view "new" page' do
      get :new

      assert_response :success
    end

    should 'be allowed to create entry' do
      post :create, :entry => {:title => 'Entry3', :content => 'foo'}

      assert_response :success
      assert_equal 'Entry was successfully created.', response.body
    end

    should 'NOT view "edit" page' do
      get :edit, :id => @e1

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'NOT be allowed to update entry' do
      put :update, :id => @e1, :entry => {:title => 'Entry21', :content => 'other'}

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'NOT be allowed to delete entry' do
      assert_no_difference 'Entry.count' do
        delete :destroy, :id => @e1
      end

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'view details page WITH valid access token' do
      get :show, :id => @e1, :token => @token1

      assert_response :success
      assert_match(/Entry1/, response.body)
    end

    should 'NOT view details page WITHOUT valid access token' do
      get :show, :id => @e1

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'NOT be allowed to set access token' do
      put :set_token, :id => @e1

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end

    should 'NOT be allowed to remove access token' do
      delete :remove_token, :id => @e1

      assert_response :redirect
      assert_redirected_to new_user_session_path
    end
  end

end
