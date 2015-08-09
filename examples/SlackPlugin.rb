require 'json'

class SlackPlugin
  def test_method
    HTTP.post(ENV['SLACK_URL'], :body => {
      :username => "Hello World",
      :color    => "good",
      :pretext  => "Hello World from Plugg!",
      :text     => "Hello World from Plugg!"
    }.to_json)
  end

  def set_params(p)
    puts "Inside set_params"
  end

  def to_s
    "Slack Plugin"
  end
end
