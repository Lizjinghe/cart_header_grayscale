--------2.22-2.28---
with checkout as 
(
select distinct 
        grass_region 
        ,grass_date
        ,event_id
        ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                else 'control group'
         end exp_group       
        ,case when grass_region = 'ID' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.000065
              when grass_region = 'SG' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.74
              when grass_region = 'TH' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.029
              when grass_region = 'VN' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.000042
              when grass_region = 'PH' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.018
              when grass_region = 'BR' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.19
              when grass_region = 'MY' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.22
              when grass_region = 'TW' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.033
        end price_usd 

    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where    grass_region in ('ID', 'SG','TH','BR','MY', 'TW', 'VN', 'PH')
      and   grass_date between date '2023-02-22'
      and   date'2023-02-28'
      and   page_type = 'shopping_cart'
      and   operation = 'action_checkout_success'
      and   platform in ('ios_app', 'android_app')
)
select grass_region
,exp_group  
,count(distinct event_id) checkout_cnt
---,approx_percentile(price_usd,0.5) mid_price
,sum(price_usd) total_price_usd
from checkout
where price_usd between 0 and 100000000
group by 1,2


;

--------1.12-1.18------
with checkout as 
(
select distinct 
        grass_region 
        ,grass_date
        ,event_id
        ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                else 'control group'
         end exp_group       
        ,case when grass_region = 'ID' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.000065
              when grass_region = 'SG' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.74
              when grass_region = 'TH' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.029
              when grass_region = 'VN' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.000042
              when grass_region = 'PH' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.018
              when grass_region = 'BR' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.19
              when grass_region = 'MY' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.22
              when grass_region = 'TW' then (cast(json_extract(data, '$.total_price')as decimal)/100000)*0.033
        end price_usd 

    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where    grass_region in ('ID', 'SG','TH','BR','MY', 'TW', 'VN', 'PH')
      and   grass_date between date '2023-01-12'
      and   date'2023-01-18'
      and   page_type = 'shopping_cart'
      and   operation = 'action_checkout_success'
      and   platform in ('ios_app', 'android_app')
)
select grass_region
,exp_group  
,count(distinct event_id) checkout_cnt
---,approx_percentile(price_usd,0.5) mid_price
,sum(price_usd) total_price_usd
from checkout
where price_usd between 0 and 100000000
group by 1,2

