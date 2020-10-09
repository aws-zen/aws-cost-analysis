-- Identify the baseline usage for validating Savings Plan recommendations
-- product_operating_system field helpful if using Reserved Instances

-- Depends on hourly detailed billing

SELECT   product_instance_type_family AS family,
         product_location AS location,
         --product_operating_system AS operating_system,
         product_tenancy AS tenancy,
         round(min(line_item_unblended_cost), 3) AS hourly_cost_min,
         round(approx_percentile(line_item_unblended_cost, .05), 3) AS hourly_cost_5_ptile,
         round(approx_percentile(line_item_unblended_cost,  .1), 3) AS hourly_cost_10_ptile,
         round(approx_percentile(line_item_unblended_cost,  .5), 3) AS hourly_cost_50_ptile,
         round(approx_percentile(line_item_unblended_cost,  .9), 3) AS hourly_cost_90_ptile
FROM 
    (SELECT line_item_usage_start_date,
         product_instance_type_family,
         product_location,
         --product_operating_system,
         product_tenancy,
         SUM(line_item_usage_amount) line_item_usage_amount,
         SUM(line_item_unblended_cost) line_item_unblended_cost
    FROM "athenacurcfn_athena_hourly_usage_reports"."athenahourlyusagereports"
    WHERE line_item_product_code='AmazonEC2'
            AND line_item_operation LIKE 'RunInstances%'
            AND year='2020'
            AND month='10'
            AND line_item_line_item_type='Usage'
            AND line_item_usage_type LIKE '%BoxUsage%'
    GROUP BY  line_item_usage_start_date,product_instance_type_family, product_location, product_operating_system, product_tenancy )
GROUP BY  product_instance_type_family, product_location, product_operating_system, product_tenancy