class Admin::BaseAdminController < ApplicationController

  before_action :authenticate_user!
  before_action :verify_admin

  private

  def verify_admin
    authorize :admin
  end
end