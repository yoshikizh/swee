require 'swee/routes'
describe "Swee::Routes" do
  before(:each) do
    kls = Swee::Routes
    kls.get "/test/test_get", "test#text_get"
    kls.post "/test/test_post", "test#test_post"
    kls.match "/test/test_match", "test#test_match", via: [:get, :post]
    @tables = kls.tables
  end

  it "测试 path_info" do
    key = "/test/test_get"
    expect(@tables.key?(key)).to eq(true)
  end

  it "测试 get" do
    key = "/test/test_get"
    result = @tables[key].request_methods == [:get] &&
    @tables[key].controller == "test" &&
    @tables[key].action == "text_get"

    expect(result).to eq(true)
  end

  it "测试 post" do
    key = "/test/test_post"
    result = @tables[key].request_methods == [:post] &&
    @tables[key].controller == "test" &&
    @tables[key].action == "test_post"

    expect(result).to eq(true)
  end

  it "测试 match" do
    key = "/test/test_match"
    result = @tables[key].request_methods == [:get, :post] &&
    @tables[key].controller == "test" &&
    @tables[key].action == "test_match"

    expect(result).to eq(true)
  end
end