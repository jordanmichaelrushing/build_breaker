class SayingsController < ApplicationController
  before_filter :authenticate_user!, except: [:create]
  def create
    if params[:token] == 'helloGazelleWorld'
      Saying.create(sayings_params)
      render json: {msg: "Thanks! Hope you don't have a potty mouth!"}
    end
  end

  private

  def sayings_params
    params.require(:sayings).permit(:msg)
  end
end