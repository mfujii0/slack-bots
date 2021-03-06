class SlacksController < ApplicationController
  protect_from_forgery except: [:sudden_death]

  def sudden_death
    secret = false
    message = ''
    OptionParser.new do |opt|
      opt.on('--secret') { secret = true }
      message = opt.parse(params[:text].split).join
    end

    text = "```#{(message.presence || '突然の死').sudden_death}```"
    send_log("`#{params[:user_name]}` さんが ##{params[:channel_name]} で突然の死を使いました。\n#{text}")

    response = {
      text: text,
      response_type: 'in_channel'
    }.to_json

    if secret
      post_json(params[:response_url], response)
    else
      render plain: response, content_type: 'application/json'
    end
  end

  def xian
    text = %w(:xian: :xian: xian :xian-x::xian-i::xian-a::xian-n:).sample
    send_log("`#{params[:user_name]}` さんが ##{params[:channel_name]} で `/xian` を使いました。\n#{text}")
    render plain: {
      text: text,
      response_type: 'in_channel'
    }.to_json, content_type: 'application/json'
  end

  def tsurai
    options = {}
    message = ''
    OptionParser.new do |opt|
      opt.on('-u') { options[:u] = true }
      message = opt.parse(params[:text].split).join
    end

    original_file = ''
    default_message = ''
    font = ''
    if options[:u]
      original_file = Rails.root + 'app/assets/images/ureshii.png'
      default_message = 'うれしい時に挙げる札'
      font = Rails.configuration.x.font_file.ureshii
    else
      original_file = Rails.root + 'app/assets/images/tsurai.jpg'
      default_message = 'つらい時に挙げる札'
      font = Rails.configuration.x.font_file.tsurai
    end

    image = generate_tsurai_image(message, original_file, default_message, font)
    text = "`#{params[:user_name]}` さんが `#{message}` を挙げました。"
    image_url = request.base_url + '/' + image
    json = {
      text: text,
      link_names: 1,
      unfurl_links: 1,
      response_type: 'in_channel',
      attachments: [
        {
          image_url: image_url
        }
      ]
    }.to_json
    post_json(params[:response_url], json)

    return head(:ok) unless ENV['SLACK_TSURAI_LOG_URL']

    log = {
      text: "`#{params[:user_name]}` さんが ##{params[:channel_name]} で `#{message}` を挙げました。",
      channel: %w(directmessage privategroup).include?(params[:channel_name]) ? ENV['SLACK_LOG_GROUP'] : ENV['SLACK_LOG_CHANNEL'],
      link_names: 1,
      unfurl_links: 1,
      attachments: [
        {
          image_url: image_url
        }
      ]
    }.to_json
    post_json(ENV['SLACK_TSURAI_LOG_URL'], log)

    # TODO
    # 画像加工が3秒制限に収まらなければ success だけ先に返すようにする
    head :ok
  end

  def yoki
    json = {
      text: "`#{params[:text].presence || '良き。'}` by `#{params[:user_name]}`",
      link_names: 1,
      unfurl_links: 1,
      response_type: 'in_channel',
    }.to_json
    post_json(params[:response_url], json)

    return head(:ok) unless ENV['SLACK_YOKI_LOG_URL']

    log = {
      text: "`#{params[:text].presence || '良き。'}` by `#{params[:user_name]}` in ##{params[:channel_name]}",
      channel: %w(directmessage privategroup).include?(params[:channel_name]) ? ENV['SLACK_LOG_GROUP'] : ENV['SLACK_LOG_CHANNEL'],
      link_names: 1,
      unfurl_links: 1,
    }.to_json
    post_json(ENV['SLACK_YOKI_LOG_URL'], log)

    head :ok
  end

  private

  def generate_tsurai_image(message, original_file, default_message, font)
    message = default_message if message.blank?
    message_len = message.length
    message = message.chars.join("\n")
    file_name = "#{SecureRandom.hex}.jpg"
    file_path = "public/slack/tsurai/images/#{file_name}"

    image = Magick::Image.read(original_file)[0]
    characters = Magick::Image.new(image.columns, image.rows) { self.background_color = 'none' }

    draw = Magick::Draw.new # 描画オブジェクト

    draw.annotate(characters, 0, 0, 104, 0, message) do
      self.font = font # フォント
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
