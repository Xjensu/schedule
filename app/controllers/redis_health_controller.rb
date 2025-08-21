class RedisHealthController < ApplicationController
  def up
    if $redis.ping == 'PONG'
      render json: { status: 'OK' }, status: :ok
    else
      render json: { status: 'ERROR' }, status: :service_unavailable
    end
  rescue => e
    render json: { status: 'ERROR', error: e.message }, status: :service_unavailable
  end
end