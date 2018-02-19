class PushService
  # Separate production and development keys
  APP_KEY = ENV['PARSE_APP_KEY'] || 'DNjit5j3lhjeZye4v2g9ucoOstsWTUPlGzyf23Ie'
  REST_API_KEY = ENV['PARSE_REST_API_KEY'] || '8TcHgeHouCb9qLgeQDOs69JVO86ep2Ts7BOv9aHG'

  def initialize
    @api = 'https://api.parse.com/1/push'

    @headers = {
      'X-Parse-Application-Id' => APP_KEY,
      'X-Parse-REST-API-Key' => REST_API_KEY,
      'Content-Type' => 'application/json'
    }
  end

  # Send push notification to many users
  #
  # users   => an array of channels to push
  # content => string
  # options => additional options
  #
  # return http response result
  def send(users, content, options = {})
    body = {
      channels: channels(users),
      expiration_time: Time.zone.now + 15.minutes,
      data: {
        title: 'Pill Reminder from MIST System',
        alert: content
      }
    }

    HTTParty.post @api, headers: @headers, body: body.to_json
  end

  # Public: get an array of push channels
  #
  # user - array, string, or object with push_id
  #
  # Returns an array of channels
  def channels(users)
    if users.respond_to? :each
      users.map { |user| channel(user) }.compact
    else
      [channel(users)]
    end
  end

  # Public: get the push channel from a user
  #
  # user - string, or object with push_id
  #
  # Returns a channel
  def channel(user)
    if user.is_a? String
      user
    else
      user.send(:push_id)
    end
  end

end
