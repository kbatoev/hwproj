$redis = Redis.new(:host => 'localhost', :port => 3000)

if defined?(Unicorn)
  Unicorn.on_event(:starting_worker_process) do |forked|
    if forked
      $redis.client.disconnect
      $redis = Redis.new(:host => 'localhost', :port => 3000)
      Rails.logger.info "Reconnecting to redis"
    else
      # We're in conservative spawning mode. We don't need to do anything.
    end
  end
end