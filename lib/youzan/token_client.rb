require 'byebug'
require 'json'
require 'faraday'
require 'redis'
require 'dotenv/load'

module Youzan

  CLIENT_ID = ENV['YOUZAN_CLIENT_ID']
  CLIENT_SECRET = ENV['YOUZAN_CLIENT_SECRET']
  KDT_ID = ENV['KDT_ID']
  GRANT_TYPE = 'silent'

  class InvalidTokenParameter < RuntimeError; end

  def self.redis
    # You can reuse existing redis connection and remove this method if require
    $redis = Redis.new(host: ENV['REDIS_HOST'], port: 6379, db: 2) # use global redis
  end

  class TokenClient

    attr_reader :client, :token_life_in_seconds, :got_token_at

    def initialize
      @random_generator = Random.new
    end

    def access_token
      read_token_from_store
      refresh if remain_life_seconds < @random_generator.rand(60..5 * 60)
      @access_token
    end

    private

    def connection
      @client ||= Faraday.new
    end

    def read_token_from_store
      td = read_token
      @token_life_in_seconds = td.fetch('expires_in').to_i
      @got_token_at = td.fetch('got_token_at').to_i
      @access_token = td.fetch('access_token') # return access_token same time
    rescue JSON::ParserError, Errno::ENOENT, KeyError, TypeError
      refresh
    end

    def read_token
      JSON.parse(Youzan.redis.get(youzan_token_key)) || {}
    end

    def remain_life_seconds
      token_life_in_seconds - (Time.now.to_i - got_token_at)
    end

    def refresh
      data = fetch_access_token
      write_token_to_store(data)
      read_token_from_store
    end

    def fetch_access_token
      res = generate_oauth_token
      JSON.parse(res.body)
    end

    def generate_oauth_token
      connection.post do |req|
        req.url oauth_token_url
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = {
          'client_id' => CLIENT_ID, 'client_secret' => CLIENT_SECRET,
          'grant_type' => GRANT_TYPE, 'kdt_id' => KDT_ID
        }
      end
    end

    def oauth_token_url
      Youzan::Api::BASE_API_URL + '/oauth/token'
    end

    def write_token_to_store(token_hash)
      raise InvalidTokenParameter unless token_hash.is_a?(Hash) && token_hash['access_token']

      token_hash['got_token_at'.freeze] = Time.now.to_i
      token_hash['expires_in'.freeze] = token_hash.delete('expires_in')
      write_token(token_hash)
    end

    def write_token(token_hash)
      Youzan.redis.set youzan_token_key, token_hash.to_json
    end

    def youzan_token_key
      "youzan_token_#{CLIENT_ID}"
    end


  end
end
