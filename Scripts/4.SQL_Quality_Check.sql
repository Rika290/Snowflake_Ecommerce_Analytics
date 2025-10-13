-- Checks for invalid records in processed tables

-- 1️. Check invalid orders
SELECT 
  COUNT(*) AS invalid_orders 
FROM processed.orders_clean 
WHERE order_flag <> 'Valid';

-- 2️. Check invalid payments
SELECT 
  COUNT(*) AS invalid_payments 
FROM processed.payments_clean 
WHERE payment_flag <> 'Valid';

-- 3️. Check late shipments
SELECT 
  COUNT(*) AS late_shipments 
FROM processed.order_items_clean 
WHERE item_flag <> 'Valid';
