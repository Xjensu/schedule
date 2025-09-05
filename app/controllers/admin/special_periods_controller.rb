class Admin::SpecialPeriodsController < ApplicationController
  def index
  end

  def new
  end

  def create
    base_date = Date.parse create_params[:start_date]
    (0..5).each do |offset|
      special_period = SpecialPeriod.new( create_params.merge(start_date: base_date + offset.days, name: :test) ).save
    end
    if request.referer.present? && URI(request.referer).host == request.host
      redirect_to request.referer
    else
      redirect_to root_path
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @special_period = SpecialPeriod.find(params[:id])
    @special_period.destroy
    if request.referer.present? && URI(request.referer).host == request.host
      redirect_to request.referer
    else
      redirect_to root_path
    end
  end

  private 

  def create_params
    params.require(:special_period).permit(:academic_period_id, :course, :student_group_id, :start_date)
  end
end
