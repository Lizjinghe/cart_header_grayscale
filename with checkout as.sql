with checkout as 
(
  select   session_id
                ,civ_id
                ,date_userid
            ,exp_group
            ,grass_region
            ,event_id
            ,total_price_usd 
            ,count(distinct cast(json_extract(a.item_detail, '$.itemid')as varchar )) as item_cnt 
             
from    (
    select  date_userid
            ,grass_region
                ,session_id
                ,civ_id
            ,exp_group
            ,event_timestamp
            ,event_id
            ,total_price_usd
            ,cast(json_extract(a.checkout_detail, '$.item_detail')as array(json)) as item_detail
    from    (
        select  session_id
        ,civ_id
        ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
        ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                else 'control group'
         end exp_group
        ,grass_region
        ,event_timestamp
        ,event_id
        ,(cast(json_extract(data, '$.total_price')as bigint)/10000)*0.000066  total_price_usd
        ,cast(json_extract(data, '$.checkout_detail') as array(json))as checkout_detail
        from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
        where  
       --- grass_region in ('ID','SG', 'MY', 'BR', 'TH', 'VN', 'PH')
         grass_region in  ('ID')
          and   grass_date between date '2023-01-12'
          and   date'2023-01-18'
          and   page_type = 'shopping_cart'
          and   operation = 'action_checkout_success'
    )
    cross join unnest (checkout_detail) as a(checkout_detail)
)
cross join unnest (item_detail) as a(item_detail)
group by 1, 2, 3, 4, 5,6,7
)
select  grass_region
        ,exp_group
        ,count(distinct date_userid) user_cnt
        ,count(distinct session_id) session_cnt
        ,count(distinct civ_id) view_cnt
        ,count(distinct event_id) checkout_cnt
        ,sum(item_cnt) item_cnt
        ,sum(total_price_usd ) total_price_usd 
from    checkout
group by 1, 2

