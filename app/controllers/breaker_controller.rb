class BreakerController < ApplicationController
  before_filter :authenticate_user!, except: [:create, :show, :update]
  def index
    @last = Breaker.where(fixed_at: nil).last rescue nil
    @last = @last ? @last.name : "No One"
  end

  def show
    if params[:token] == 'helloGazelleWorld'
      breaker = Breaker.where(fixed_at: nil).last rescue nil
      payload = breaker ? {success: true, breaker: breaker} : {success: false}
      render json: payload
    else
      render json: {success: false}
    end
  end

  def create
    if params[:token] == 'helloGazelleWorld'
      Breaker.find_or_create_by(name: params[:name], broken_at: Time.parse(params[:broken_at]).utc, repo_key: params[:key])
    end
    render json: {}
  end

  def update
    if params[:token] == 'helloGazelleWorld'
      breaker = Breaker.where(repo_key: params[:key])
      breaker.update_all(fixed_by: params[:name], fixed_at: Time.parse(params[:fixed_at]).utc) if breaker.present? && breaker.last.fixed_at.nil?
    end
    render json: {}
  end

  def ping
    breaker = Breaker.where(fixed_at: nil).last rescue nil
    master = Master.find(breaker.id) if breaker rescue nil
    if (breaker.present? && master.nil?)
      Master.create
      name = (breaker.repo_key =~ /zambezi-templates/).present? ? "Big Commerce" : breaker.name
      render json: {
                      success: true,
                      name: name,
                      speech: "#{name}! You broke the build. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #{Saying::BURNS[Random.rand(0..Saying::BURNS.length - 1)]}"
                   }
    elsif (breaker.present? && breaker.id == master.id)
      name = (breaker.repo_key =~ /zambezi-templates/).present? ? "Big Commerce" : breaker.name
      render json: {
                      success: true,
                      name: name
                   }
    else
      breaker = Breaker.order('fixed_at desc').first rescue nil
      if breaker
        render json: {
                        success: true,
                        name: breaker.fixed_by,
                        fixed: true
                      }
      else
        render json: {success: false}
      end
    end
  end

  private

  def broken_params
    params.require(:broken).permit(:name)
  end

end