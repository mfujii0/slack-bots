class PrimitiveLanguageController < ApplicationController
  def translate
    render plain: {
      text: 'オレサマ　オマエ　マルカジリ',
      response_type: 'in_channel'
    }.to_json, content_type: 'application/json'
  end
end
