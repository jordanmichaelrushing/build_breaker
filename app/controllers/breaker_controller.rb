class BreakerController < ApplicationController
  before_filter :authenticate_user!, except: [:create, :show]
  def index
    @last = Breaker.last
    @last = @last ? @last.name : "No One"
  end

  def show
    if params[:token] == 'helloGazelleWorld'
      breaker = Breaker.last
      payload = breaker ? {success: true, breaker: breaker} : {success: false}
      render json: payload
    else
      render json: {success: false}
    end
  end

  def create
    if params[:token] == 'helloGazelleWorld'
      Breaker.create(name: params[:name], broken_at: params[:broken_at])
    end
    render json: {}
  end

  def ping
    broken = Breaker.last
    master = Master.last
    if ((broken && master.nil?) || (broken && broken.id != master.id))
      Master.create
      render json: {
                      success: true,
                      name: broken.name,
                      speech: "#{broken.name}! You broke the build. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #{Breaker::BURNS[Random.rand(0..1)]}"
                   }
    else
      render json: {success: false}
    end
  end

  private

  def broken_params
    params.require(:broken).permit(:name)
  end

end