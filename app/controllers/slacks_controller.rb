class SlacksController < ApplicationController
  protect_from_forgery except: [:sudden_death]

  def sudden_death
    render plain: {
      text: "```#{params[:text].sudden_death}```",
      response_type: 'in_channel'
    }.to_json, content_type: 'application/json'
  end
end
