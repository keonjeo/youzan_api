require 'byebug'
require 'faraday'
require 'youzan/token_client'

module Youzan
  class Api

    BASE_API_URL = 'https://open.youzan.com'.freeze

    attr_reader :api_path, :api_version, :request_method, :token_client

    def initialize(api_path = nil, api_version = nil, request_method = nil)
      @api_path = api_path
      @api_version = api_version
      @request_method = request_method
    end

    # This is a common method to call the youzan's service API
    # But you need to initialize the `api_path`, `api_version` and `request_method`
    def call_api(options)
      res = call_youzan_api(options)
      parse_response_data(res)
    end

        # 获取单笔交易的信息
    # API name: youzan.trade.get
    def get_youzan_trade(tid)
      @api_path = 'youzan.trade.get'
      @api_version = '4.0.0'
      @request_method = 'GET'
      res = call_youzan_api(tid: tid)
      parse_response_data(res)
    end

    # 使用购买虚拟商品获得的码
    # API name: youzan.trade.virtualcode.apply
    #
    # Success Response
    #
    # { "response": { "is_success": true } }
    #
    # Error Response
    #
    # { "error_response": { "code": 101300000, "msg": "订单不存在" } }
    # { "error_response": { "code": 101600002, "msg": "订单已被关闭无法核销" } }
    # { "error_response": { "code": 101600002, "msg": "订单已被核销,重复核销无效" } }
    def apply_virtual_code(code)
      @api_path = 'youzan.trade.virtualcode.apply'
      @api_version = '3.0.0'
      @request_method = 'GET'
      res = call_youzan_api(code: code)
      parse_response_data(res)
    end

    private


    def access_token
      @token_client ||= Youzan::TokenClient.new
      @token_client.access_token
    end

    def connection
      @client ||= Faraday.new
    end

    def call_youzan_api(param_hash)
      raise InvalidRequestMethod unless %w[GET POST].include?(request_method)

      param_hash.merge!(access_token: access_token)

      case request_method
      when 'GET'
        api_via_get_method(param_hash)
      when 'POST'
        api_via_post_method(param_hash)
      end
    end

    def api_via_get_method(parameters)
      raise InvalidHashParameter unless parameters.is_a?(Hash)
      connection.get do |req|
        req.url api_oauthentry_url
        req.params.merge!(parameters)
      end
    end

    def api_via_post_method(parameters)
      raise InvalidHashParameter unless parameters.is_a?(Hash)
      connection.post do |req|
        req.url api_oauthentry_url
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = parameters
      end
    end

    def parse_response_data(response)
      JSON.parse(response.body)
    end

    def api_oauthentry_url
      raise InvokeApiError unless api_path_valid?
      result = /((?:\w+\.)+)(\w+)/.match(api_path).to_a
      api_action = result.last
      api_name = result[-2].chop
      Youzan::Api::BASE_API_URL + '/api/oauthentry/' + "#{api_name}/" + api_version + "/#{api_action}"
    end

    def api_path_valid?
      api_path =~ /((?:\w+\.)+)(\w+)/
    end
  end
end
