class Kopal::MailTouch < ActionMailer::Base
  

  def new_comment(sent_at = Time.now)
    subject    'MailTouch#new_comment'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def new_friendship_request(sent_at = Time.now)
    subject    'MailTouch#new_friendship_request'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def new_message(sent_at = Time.now)
    subject    'MailTouch#new_message'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def upcoming_birthday(sent_at = Time.now)
    subject    'MailTouch#upcoming_birthday'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def new_label(sent_at = Time.now)
    subject    'MailTouch#new_label'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def new_question(sent_at = Time.now)
    subject    'MailTouch#new_question'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
