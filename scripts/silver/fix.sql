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
