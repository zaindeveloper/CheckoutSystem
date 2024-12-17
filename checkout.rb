class Checkout

  attr_reader :pricing_rules, :cart

  def initialize(pricing_rules)
    @pricing_rules = pricing_rules
    @cart = Hash.new(0)
  end

  def scan(item)
    @cart[item] += 1
  end

  def total
    total_price = 0.0
    @cart.each do |product_code, quantity|
      price_rule = @pricing_rules[product_code]
      if price_rule
        total_price += price_rule[:calculate_price].call(quantity)  
      end
    end
    total_price.round(2)
  end

end

product_pricing = {"GR1" => 3.11 , "SR1" => 5.00 ,"CF1" => 11.23 }

pricing_rules = {
  "GR1" => {
    calculate_price: lambda do |quantity|
      (quantity / 2 + quantity % 2) * product_pricing["GR1"] 
    end
  },
  "SR1" => {
    calculate_price: lambda do |quantity|
      if quantity >= 3
        quantity * 4.50 
      else
        quantity * product_pricing["SR1"] 
      end
    end
  },
  "CF1" => {
    calculate_price: lambda do |quantity|
      if quantity >= 3
        quantity * (product_pricing["CF1"]  * 2 / 3.0) 
      else
        quantity * product_pricing["CF1"] 
      end
    end
  }
}

main_basket = [["GR1", "SR1", "GR1", "GR1", "CF1"],
               ["GR1","GR1"],
               ["SR1","SR1","GR1","SR1"],
               ["GR1","CF1","SR1","CF1","CF1"]] 
main_basket.each do |basket|
  checkout = Checkout.new(pricing_rules)
  basket.each do |item|
    if pricing_rules.keys.include?(item)
      checkout.scan(item)
    else
      puts "#{item} is invalid item"
    end  
  end  
  puts "Total price: £#{checkout.total}"
end