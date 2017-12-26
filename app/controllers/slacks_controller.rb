class SlacksController < ApplicationController
  protect_from_forgery except: [:sudden_death]

  def sudden_death
    render plain: {
      text: "```#{params[:text].sudden_death}```",
      response_type: 'in_channel'
    }.to_json, content_type: 'application/json'
  end

  def tsurai
    image = generate_tsurai_image(params[:text])
    text = "`#{params[:user_name]}` さんが `#{params[:text]}` を挙げました。"
    json = {
      text: text,
      response_type: 'in_channel',
      attachments: [
        {
          image_url: request.base_url + '/' + image
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

  ORIGINAL_FILE = Rails.root + 'app/assets/images/tsurai.jpg'
  def generate_tsurai_image(message)
    message_len = message.length
    message = message.chars.join("\n")
    file_name = "#{SecureRandom.hex}.jpg"
    file_path = "public/slack/tsurai/images/#{file_name}"

    image = Magick::Image.read(ORIGINAL_FILE)[0]
    characters = Magick::Image.new(image.columns, image.rows) { self.background_color = 'none' }

    draw = Magick::Draw.new # 描画オブジェクト

    draw.annotate(characters, 0, 0, 104, 0, message) do
      self.font = ENV['SLACK_TSURAI_FONT_FILE'] # フォント
      self.fill = 'black' # フォント塗りつぶし色
      self.stroke = 'transparent' # フォント縁取り色
      self.pointsize = [36, 288.0 / message_len].min # フォントサイズ
      self.gravity = Magick::NorthWestGravity # 描画基準位置
    end
    characters.rotate!(-12)

    image.composite!(characters, Magick::CenterGravity, Magick::OverCompositeOp)

    image.write(file_path)
    "slack/tsurai/images/#{file_name}"
  end
end
