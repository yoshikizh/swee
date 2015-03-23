class Swee::Routes
  # 参考 rails 设计的 3种方式
  # get,post,match 分别对应 controller 中的 action

  get "/", "home#index"

  # post "/items/buy", "items#buy"

  # match "/items", "items#new", via: [:get, :post]

end