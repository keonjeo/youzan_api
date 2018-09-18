Gem::Specification.new do |s|
  s.name        = 'youzan_api'
  s.version     = '0.0.1'
  s.date        = '2010-09-18'
  s.summary     = "Youzan API"
  s.description = "An easy way to call the youzan API's gem"
  s.authors     = ["Keon Ye"]
  s.email       = 'staven.vanderbilt@gmail.com'
  s.files       = ["lib/youzan_api.rb"]
  s.homepage    = 'https://github.com/keonjeo/youzan_api'
  s.license     = 'MIT'
  s.add_development_dependency 'dotenv', '~> 2.3', '>= 2.3.0'
  s.add_development_dependency 'redis', '~> 4.0', '>= 4.0.2'
  s.add_development_dependency 'faraday', '~> 0.15.2'
end
