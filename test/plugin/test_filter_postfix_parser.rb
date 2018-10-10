require "helper"
require "fluent/plugin/filter_postfix_parser.rb"

class PostfixParserFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::PostfixParserFilter).configure(conf)
  end
end
