module RedisHelper
  module_function
  
  def cache_fetch(key, expires_in: 1.hour, &block)
    $redis_read_pool.with do |redis|
      cached = redis.get(key)
      return JSON.parse(cached) if cached
    end
    
    result = block.call
    
    $redis_write_pool.with do |redis|
      redis.setex(key, expires_in.to_i, result.to_json)
    end
    
    result
  rescue => e
    Rails.logger.error "Redis cache error: #{e.message}"
    block.call # Fallback to block execution
  end
  
  def cache_delete(pattern)
    $redis_write_pool.with do |redis|
      keys = redis.keys(pattern)
      redis.del(*keys) if keys.any?
    end
  end
end