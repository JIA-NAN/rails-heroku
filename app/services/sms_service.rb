class SmsService
  # Separate production and development keys
  ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID'] || 'AC8d00e9e128cdbf8e963eb2379522c486'
  AUTH_TOKEN  = ENV['TWILIO_AUTH_TOKEN']  || 'a3ec661397c61faedfe8dc300acbbb9f'
  PHONE_NUM   = ENV['TWILIO_PHONE_NUM']   || '+15005550006'

  def initialize
    @client = Twilio::REST::Client.new ACCOUNT_SID, AUTH_TOKEN
  end

  # Send SMS notification to a user
  #
  # user    => a phone number
  # content => string
  # options => additional options
  #
  # return http response result
  def send(user, content, options = {})
    begin
      @client.account.messages.create({
        to:   phone(user),
        from: options[:from] || PHONE_NUM,
        body: content
      })

      return true
    rescue Twilio::REST::RequestError
      return false
    end
  end

  # Public: get the phone number from a user
  #
  # user - string, or object with sms_id
  #
  # Returns a phone number
  def phone(user)
    if user.is_a? String
      user
    else
      user.send(:sms_id)
    end
  end

end
