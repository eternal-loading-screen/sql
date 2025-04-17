SELECT 
market_date
, vendor_inventory.vendor_id
,vendor_name
, product_id
, max( quantity ) as Max_Quantity_per_day
, avg ( original_price ) as Avg_Price
, 
FROM
vendor_inventory

LEFT JOIN 
vendor 
ON
vendor.vendor_id =
vendor_inventory.vendor_id

WHERE
vendor_inventory.vendor_id
 in ( 7,8 )


GROUP BY market_date
, vendor_inventory.vendor_id
, product_id