# Swee

Swee 是一个轻量级的 ruby web 框架, 包含一个http服务器。
目前还是demo阶段, 供学习和参考使用

## 特性 和 实现方式

1. 底层接受http请求 基于 EventMachine 的 event loop
2. 内部一些特性都是基于 event loop 如: 服务器重启, 以及代码reload等特性
3. 处理请求并包装为 request 结构暂时使用的是 Thin 的 http_parser
4. 应用层轻量级包装 实现 route 和 controller 目前支持 rails 的一些特性
5. 使用部分 rack 的 middlewaves 和 一些自己实现的 middlewaves

## 安装

请使用ruby2.1.0或以上版本, 然后安装 swee 的Gem

```console
gem install swee
```

bundler 安装方式
添加以下代码到 Gemfile

```console
gem 'swee',  '~> 0.0.2'
```

## 使用方法

生成项目
生成以后会创建一个项目目录和一些项目必须的文件
随后会贴心的自动开启一个服务器
打开您最喜欢的浏览器输入 http://localhost:3000
可以看到一个 hello 的欢迎页面

```console
swee new myproj
```

运行swee命令行

```console
swee c
```

启动服务器

```console
swee s
```

端口和环境参数

```console
swee s -p 8080 -e production
```

## 配置服务器

打开项目下的 config.rb 并配置它

先配置 server_config 部分

配置日志文件格式: [日志文件位置,文件保留数量,每个文件的大小]
```ruby
  cfg.log_file     = [ "./logs/development.log", 10, 10240000 ]
```

配置日志等级
```ruby
  cfg.logger_level = :debug
```

配置重启模式
:touch => 请配置 touch_file, 并指定 restart.txt 文件位置
:pid   => 请配置 pid_file, 并制定 pid 文件位置
```ruby
  cfg.restart_mode = :touch
  cfg.touch_file   = "./tmp/restart.txt"
  cfg.pid_file     = "./tmp/pid"
```

是否改变代码立刻reload(重载)
```ruby
  cfg.code_reload  = true
```

最大连接数
```ruby
  cfg.max_connections = 1024
```

是否后台运行(守护进程模式)
```ruby
  cfg.run_background = false
```

重启服务器
仅支持后台运行的服务器

touch 方式
```console
  touch tmp/restart.txt
```

pid 方式
```console
  kill -USR2 `cat tmp/pid`
```

## 配置路由
暂时支持 rails 方式的路由 path_info 映射为 controller#action

打开项目下的 routes.rb 并配置它

get 请求路径为/, 对应 controllers 目录下的 HomeController 已经 index 方法 (rails里的action)

```ruby
  get "/", "home#index"
```

post 请求路径为/items/buy, 对应 controllers 目录下的 ItemsController 已经 buy 方法 (rails里的action)

```ruby
  post "/items/buy", "items#buy"
```

match 请求路径为/items, 对应 controllers 目录下的 ItemsController 已经 new 方法 (rails里的action)
via 配置为 请求方法, 目前可用 :get, :post 两种
```ruby
  match "/items", "items#new", via: [:get, :post]
```

## controller 特性

过滤器
支持 rails 方式的过滤器
before_filter, after_filter 和 round_filter
接受参数类型  :only 和 :except

```ruby
  before_filter :set_variable, :only => [:index]
  before_filter :set_variable, :except => [:index,:create]
  round_filter  :set_variable, :only => [:index]
```

request 方法
会获取一个 对浏览器请求的request包装对象
```ruby
  request.url
  request.method
  ....
```
params 方法
得到一个 Hash 对象,包含请求的参数以 和 controller , action 参数
```ruby
  params[:controller]
  params[:action]
  ....
```

render 方法
支持 rails 的 render 方式

render方法(可省略)
默认会寻找当前 controller#action 所对应寻找好 views目录下 controller 目录 action 的erb文件

渲染一个text文本
```ruby
  render :text => "foobar"
```

渲染一个json
```ruby
  render :json => { foo: "bar" }
```

## 关于 Gemfile

关于 Gemfile

用户可以自行安装所需的gem

先安装 bundler

```ruby
  gem install bundler
```
然后在项目目录下创建一个 Gemfile

添加您所需要的 gem 然后执行

```ruby
  bundle install
```

## 关于model 和 数据库

当前版本还未完成 model 的封装
暂时推荐用户自己选择, 推荐使用 active_record 或者 mongoid
自行添加对应的gem 到 Gemfile 中

## 测试

执行 rspec 测试
暂时测试覆盖不全

```ruby
  rspec spec/*
```

## 贡献代码

1. Fork 分支 ( https://github.com/yoshikizh/swee/fork )
2. 创建你自己的分支 (`git checkout -b my-new-feature`)
3. 并提交 (`git commit -am 'Add some feature'`)
4. 推送到新分支 (`git push origin my-new-feature`)
5. github上请求一个 pull request
