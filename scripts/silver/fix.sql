-- fix crm_cus_info

insert into silver.crm_cust_info(
    cst_id            ,
    cst_key            ,
    cst_firstname      ,
    cst_lastname      ,
    cst_marital_status ,
    cst_gndr           ,
    cst_create_date)
select cst_id,
cst_key,
trim(cst_firstname)as cst_firstname,
trim(cst_lastname) as cst_lastname,

case 
    when trim(upper(cst_marital_status)) = 's' then 'Single'
    when trim(upper(cst_marital_status)) = 'm' then 'Married'
else 'n/a'
end as cst_marital_status,
case 
    when trim(upper(cst_gndr)) = 'm' then 'Male'
    when trim(upper(cst_gndr)) = 'f' then 'Female'
else 'n/a'
end as cst_gndr,
cst_create_date
from(
select *,ROW_NUMBER() over(partition by cst_id
order by cst_create_date desc) as flag_last
from bronze.crm_cust_info) as t
where flag_last = 1 and cst_id is not null;





INSERT INTO silver.crm_prd_info(
cat_id,
prd_key,
prd_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
PRD_END_dt
)
SELECT 
REPLACE( SUBSTRING(prd_key,1,5),'-','_') as cat_id,
SUBSTRING(prd_key,7,len(prd_key)) as prd_key,
prd_id,
prd_nm,
ISNULL(prd_cost,0 ) as prd_cost,
CASE
 when UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
 when UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
 when UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
 when UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
 else 'n/a'
END AS prd_line,
cast(prd_start_dt as date) as prd_start_dt,
CAST(lead(prd_start_dt) OVER(PARTITION BY prd_key order by prd_start_dt) - 1 as DATE)
AS PRD_END_dt
FROM bronze.crm_prd_info;
