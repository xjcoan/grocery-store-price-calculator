# preserve string keys to match input histrogram
# other options would be `map(&:to_sym)` to keys or
# use `with_indifferent_access` if this were in Rails
# Using a constant mimics the ability for prices to be read from
# a database or updated week-to-week as stock and sales may change
BASE_ITEM_PRICES = {
  'milk' => 3.97,
  'bread' => 2.17,
  'banana' => 0.99,
  'apple' => 0.89,
}.freeze

# Could also structure the data with strings:
# 'milk' => '2 for 5.00'
# then split the value & parse the count and sale price, but this mimics
# what would likely be in whatever data store these prices would draw from
SALE_PRICES = {
  'milk' => {
    'sale_count' => 2,
    'sale_price' => 5.00,
  },
  'bread' => {
    'sale_count' => 3,
    'sale_price' => 6.00,
  },
}.freeze

# Get the input of items purchased
# Returns a histogram (Hash) of the item number purchased
# ex: { 'apple' => 1, 'bread' => 2 }
def get_purchased_items
  puts 'Enter items purchased by the customer, separated by comma'

  # Assemble occurances of each purchased item
  input = gets.chomp.split(',').map(&:strip).map(&:downcase)

  # We could use Enumarable#tally for this, but I won't assume we're running 2.7 yet
  purchased_items = Hash.new(0)
  input.each { |item| purchased_items[item] += 1 }
  validate_items(purchased_items)
  purchased_items
end

# Check that everything entired item is valid against the store's stock
def validate_items(entered_items)
  wrong_items = entered_items.keys - BASE_ITEM_PRICES.keys
  raise "Item(s) #{wrong_items} are invalid. Please try again." unless wrong_items.empty?
end

# Find the sale price applicable for each item on sale
# Returns a Hash of item and the applied sale price based on the number of times
# the sale requirement has been reached
# ex: { 'milk' => 10.00 } if 2 milk cartons were purchased
def calculate_discounts(items)
  sale_totals = Hash.new(0.0)
  items.each do |item, count|
    next unless SALE_PRICES.key?(item)

    # determine the amount of times the sale count has been reached
    qualified_for_sale = count / SALE_PRICES[item]['sale_count']
    sale_totals[item] += qualified_for_sale * SALE_PRICES[item]['sale_price']
  end

  sale_totals
end

# Total without discounts
# Returns a hash of item and the subtotal, based on it's base item price and
# the quantity purchased
# ex: { 'bread' => 6.51 } if 3 loaves were purchased
def calculate_subtotals(items)
  subtotals = Hash.new(0.0)
  items.each { |item, count| subtotals[item] += (BASE_ITEM_PRICES[item] * count) }
  subtotals
end

def calculate_and_display_receipt(items, subtotals, discounts)
  subtotal = 0.0
  grand_total = 0.0
  item_totals = Hash.new(0.0)

  # Calculate everything in one loop for speed
  # Another approach (more readable?) would be to use multiple loops
  # ex: subtotal = substotals.sum { |item,value| value }
  items.each do |item, count|
    subtotal += subtotals[item]

    discounted = discounts.key?(item)
    item_total_amount = 0.0
    if discounted
      unqualified_for_sale = count % SALE_PRICES[item]['sale_count']
      full_price_amount = unqualified_for_sale * BASE_ITEM_PRICES[item]
      item_total_amount = discounts[item] + full_price_amount
    else
      item_total_amount = subtotals[item]
    end
    item_totals[item] = item_total_amount

    grand_total += item_total_amount
  end

  print_receipt(items, item_totals, subtotal, grand_total)
end

def print_receipt(items, item_totals, subtotal, grand_total)
  # loop through items and display a tabular receipt
  puts "Item\tQuantity\tPrice"
  puts '--------------------------------------'
  items.each do |item, quantity|
    puts "#{item.capitalize}\t#{quantity}\t$#{item_totals[item]}"
  end

  puts "Total price: $#{grand_total}"
  puts "You saved: $#{(subtotal - grand_total).round(2)}"
end

def main
  items = get_purchased_items
  subtotals = calculate_subtotals(items)
  discounts = calculate_discounts(items)
  calculate_and_display_receipt(items, subtotals, discounts)
rescue StandardError => e
  puts e.message
end

main
