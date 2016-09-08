Redis::Client::DEFAULTS[:host] = 'localhost'
Redis::Client::DEFAULTS[:port] = '3000'

if ENV["REDISCLOUD_URL"]
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  $redis = Redis.new(host: uri.host, port: uri.port)
end