# 有赞API集成Gem包（`youzan_api gem`）


# 用`redis`作为缓存，需要先启动`redis-server`

```
redis-server
```

# 配置环境变量

```
YOUZAN_CLIENT_ID="67cf2d831381d67ab8"
YOUZAN_CLIENT_SECRET="13172520585f3341c857ffb52e99b71a"
KDT_ID="41442241"
REDIS_HOST="127.0.0.1"
```

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
