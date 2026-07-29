use warehouse_project;

-- Star schema
----> create one fact table and multiple dimension table, connected to fact table
--fact and dimension table

--dimension -We store text related data
-- description infromation that gives context to your data

--fact - we store numerical data

create schema gold;
create view gold.dim_customers as 
select
	ROW_NUMBER()over (order by cst_id) as customer_key,
	ci.cst_id	as customer_id,
	ci.cst_key	as customer_number,
	ci.cst_firstname	as first_name,
	ci.cst_lastname	 as last_name,
	la.cntry	 as country,
	ci.cst_marital_status	 as marital_status,
	case
		when ci.cst_gndr !='n/a' then ci.cst_gndr
		else coalesce (ca.gen,'n/a')
	end		as gender,
	ca.bdate	 as birthdate,
	
	ci.cst_create_date		as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
	on ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
	on ci.cst_key = la.cid;

select * from gold.dim_customers;




CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    pn.prd_id           AS product_id,
    pn.prd_key          AS product_number,
    pn.prd_nm           AS product_name,
    pn.cat_id           AS category_id,
    pc.cat              AS category,
    pc.subcat           AS subcategory,
    pc.maintenance      AS maintenance,
    pn.prd_cost         AS cost,
    pn.prd_line         AS product_line,
    pn.prd_start_dt     AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;

select * from gold.dim_products


create view gold.fact_sales as
select
	sd.sls_ord_num		as order_number,
	pr.product_key		as product_key,
	cu.customer_key		as customer_key,
	sd.sls_order_dt		as order_date,
	sd.sls_ship_dt		as shipping_date,
	sd.sls_due_dt		as due_date,
	sd.sls_sales		as sales_amount,
	sd.sls_quantity		as quantity,
	sd.sls_price		as price
from silver.crm_sales_details sd
left join gold.dim_products pr
	on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
	on sd.sls_cust_id = cu.customer_id;

select * from gold.fact_sales;


