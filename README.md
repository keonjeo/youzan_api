# 有赞API集成Gem包（`youzan_api gem`）

# 获取`access_token`

```ruby
YouZan::TokenClient.new.access_token
```


# 获取单笔交易的信息(`API name: youzan.trade.get`)

```ruby
YouZan::Api.new.get_youzan_trade(tid)
```



# 使用购买虚拟商品获得的码 (`API name: youzan.trade.virtualcode.apply`)

```ruby
YouZan::Api.new.apply_virtual_code(code)
```