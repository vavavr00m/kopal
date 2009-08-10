require 'test_helper'

class ProfileCommentTest < ActiveSupport::TestCase

  def setup
    @new_record = Kopal::ProfileComment.new
    @new_record.name = "Example"
    @new_record.email = "example@example.net"
    @new_record.website_address = "http://example.net/"
    @new_record.comment_text = "Hello, world!"
  end

  def test_duplicate_comment_text_can_not_be_saved_instantly
    p = Proc.new {
      c = Kopal::ProfileComment.new
      c.name = "example"
      c.email = 'something@example.net'
      c.comment_text = 'duplication'
      c.save!
    }
    assert_nothing_raised { p.call }
    assert_raise(ActiveRecord::RecordInvalid) { p.call }
  end

  def test_email_must_have_valid_syntax
    @new_record.email = 'bad-bad-email!!@'
    assert !@new_record.valid?
    assert @new_record.errors["email"]
    assert_equal 1, @new_record.errors.size
  end

  def test_website_address_must_have_valid_syntax
    @new_record.website_address = 'bad-bad-website-address'
    assert !@new_record.valid?
    assert @new_record.errors["website_address"]
    assert_equal 1, @new_record.errors.size
  end

  def tes_can_not_save_blank_comment_text
    @new_record.comment_text = "                          "
    assert !@new_record.valid?
    assert @new_record.errors["comment_text"]
    assert_equal 1, @new_record.errors.size
  end

  def test_assert_is_kopal_identity_is_false_by_default
    assert_equal false, @new_record.kopal_identity?
  end

end
