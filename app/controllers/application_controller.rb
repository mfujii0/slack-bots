require 'net/http'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def post_json(url, json)
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    post = Net::HTTP::Post.new(uri.path)
    post.body = json
    post["Content-Type"] = "application/json"
    https.request(post)
  end

  def send_log(message, log_channel_name = '#sudden-death-log')
    return unless ENV['SLACK_WEBHOOK']
    message = { text: message } unless message.is_a?(Hash)
    message.reverse_merge!(
      channel: log_channel_name,
      link_names: 1,
      unfurl_links: 1,
    )
    post_json(ENV['SLACK_WEBHOOK'], message.to_json)
  end
end
