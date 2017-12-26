class SlacksController < ApplicationController
  protect_from_forgery except: [:sudden_death]

  def sudden_death
    render plain: {
      text: "```#{params[:text].sudden_death}```",
      response_type: 'in_channel'
    }.to_json, content_type: 'application/json'
  end

  def tsurai
    text = "`#{params[:user_name]}` さんが `#{params[:text]}時に挙げる札` を挙げました。"
    json = {
      text: text,
      response_type: 'in_channel',
      attachments: [
        {
          image_url: view_context.image_url('/slack/tsurai/images/tsurai.jpg', only_path: false)
        }
      ]
    }.to_json

    # TODO
    # 画像加工が3秒制限に収まらなければ success だけ先に返すようにする
    post_json(params[:response_url], json)
    head :ok
  end

  private

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
