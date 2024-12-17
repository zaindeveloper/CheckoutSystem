require 'minitest/autorun'

class CheckoutTest < Minitest::Test

  def setup
    @pricing_rules = {
      "GR1" => ->(quantity) { quantity / 2 * 3.11 + quantity % 2 * 3.11 },
      "SR1" => ->(quantity) { quantity >= 3 ? quantity * 4.50 : quantity * 5.00 },
      "CF1" => ->(quantity) { quantity >= 3 ? quantity * (11.23 * 2 / 3.0) : quantity * 11.23 }
    }
  end

  def test_basket1
    checkout = Checkout.new(@pricing_rules)
    checkout.scan("GR1")
    checkout.scan("SR1")
    checkout.scan("GR1")
    checkout.scan("GR1")
    checkout.scan("CF1")
    assert_equal 22.45, checkout.total
  end

  def test_basket2
    checkout = Checkout.new(@pricing_rules)
    checkout.scan("GR1")
    checkout.scan("GR1")
    assert_equal 3.11, checkout.total
  end

  def test_basket3
    checkout = Checkout.new(@pricing_rules)
    checkout.scan("SR1")
    checkout.scan("SR1")
    checkout.scan("GR1")
    checkout.scan("SR1")
    assert_equal 16.61, checkout.total
  end

  def test_basket4
    checkout = Checkout.new(@pricing_rules)
    checkout.scan("GR1")
    checkout.scan("CF1")
    checkout.scan("SR1")
    checkout.scan("CF1")
    checkout.scan("CF1")
    assert_equal 30.57, checkout.total
  end

   def test_basket5
    checkout = Checkout.new(@pricing_rules)
    checkout.scan("GR1")
    checkout.scan("CF")
    checkout.scan("SR")
    checkout.scan("CF")
    checkout.scan("CF")
    assert_equal 3.11, checkout.total
  end

end

class Checkout
  def initialize(pricing_rules)
    @pricing_rules = pricing_rules
    @cart = Hash.new(0)
  end

  def scan(item)
    if @pricing_rules.keys.include?(item)
      @cart[item] += 1
    end
  end

  def total
    @cart.sum do |item, quantity|
      @pricing_rules[item].call(quantity)
    end.round(2)
  end
end