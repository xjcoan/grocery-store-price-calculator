# Grocery Store Checkout Calculator
Usage - `ruby price_calculator.rb`
Built using ruby 2.6.6, but should work with all modern supported ruby versions.

The script will prompt you for the items the customer is purchasing in a comma-separated
list. It will then calculate the grand total based based on current sale prices and
display a receipt with the item names, their quanities, and total charged for
each item type, followed by the amount due and how much was saved from sales.

## Example
```
$ ruby price_calculator.rb
Enter items purchased by the customer, separated by comma
bread,bread, milk,milk, apple,banana
Item	Quantity	Price
--------------------------------------
Bread	2		$4.34
Milk	2		$5.00
Apple	1		$0.89
Banana	1		$0.99

Total price : $11.22
You saved $2.94 today.
```


Completed by X Coan - Github [@xjcoan](https://github.com/xjcoan)
