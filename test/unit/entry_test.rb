require 'test_helper'

class EntryTest < ActiveSupport::TestCase

  context 'validations' do
    should validate_presence_of(:title)
    should validate_presence_of(:content)
  end

  context 'access token' do
    setup do
      @token1, @token2 = '123', '456'
      @e1 = FactoryGirl.create(:entry, :access_token => @token1, :access_token_expires_at => 2.days.from_now)
      @e2 = FactoryGirl.create(:entry, :access_token => @token2, :access_token_expires_at => 2.days.ago)
    end

    context 'authorization' do
      should 'return true if token matches id' do
        assert Entry.authorize_by_token(@e1, @token1)
      end

      should 'return false if id missing' do
        assert !Entry.authorize_by_token(1234, @token1)
      end

      should 'return false if token missing' do
        assert !Entry.authorize_by_token(@e1, 'bogus')
      end

      should 'return false if token expired' do
        assert !Entry.authorize_by_token(@e2, @token2)
      end
    end

    should 'be considered valid' do
      assert @e1.valid_access_token?(@token1)
    end

    should 'be considered invalid is not matching' do
      assert !@e1.valid_access_token?(@token2)
    end

    should 'be considered invalid is expired' do
      assert !@e2.valid_access_token?(@token2)
    end

    should 'be set' do
      e = FactoryGirl.create(:entry)
      assert_nil e.access_token

      assert_difference 'Entry.where("access_token IS NOT NULL").count' do
        e.set_token
      end

      assert_not_nil e.reload.access_token
    end

    should 'be removed' do
      e = FactoryGirl.create(:entry, :access_token => '123')
      assert_not_nil e.access_token

      assert_difference 'Entry.where("access_token IS NOT NULL").count', -1 do
        e.remove_token
      end

      assert_nil e.reload.access_token
    end
  end

end
