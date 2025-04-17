SELECT 
-- Specifying the fields that are from the table
market_date
, vendor_inventory.vendor_id
,vendor_name
, product_id
-- Adding some aggregations so the GROUP BY Makes sense
, max( quantity ) as Max_Quantity_per_day
, avg ( original_price ) as Avg_Price
, 
FROM
vendor_inventory

-- table used for a join
LEFT JOIN 
vendor 
-- Conditions for join
ON
vendor.vendor_id =
vendor_inventory.vendor_id
-- Adding a filter, and has an "IN"
WHERE
vendor_inventory.vendor_id
 in ( 7,8 )

-- The group by portion
GROUP BY market_date
, vendor_inventory.vendor_id
, product_id