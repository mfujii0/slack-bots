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
end
