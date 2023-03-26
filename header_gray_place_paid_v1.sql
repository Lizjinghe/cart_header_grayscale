with cartview as 
(   
    select  session_id
         ,civ_id
        ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
        ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                else 'control group'
         end exp_group
        ,grass_region
        ,last_view_civ_id
    from    mp_pa.dwd_eventid_view_order_business_di__reg_live
    where   
           ---grass_region in ('ID', 'SG','TH','BR','MY', 'TW', 'VN', 'PH')
         grass_region in  ('ID')
      and   grass_date between date '2023-02-22'
      and   date'2023-02-28'
      and   user_id > 0
      and   page_type = 'shopping_cart'
      and   operation = 'view'
      and   platform in('ios_app', 'android_app')
)

,checkout as 
(
    select   session_id
         ,civ_id
        ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
        ,grass_region
    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
        where  
       ---grass_region in ('ID', 'SG','TH','BR','MY', 'TW', 'VN', 'PH')
       grass_region in  ('ID')
          and   grass_date between date '2023-02-22'
          and   date'2023-02-28'
          and   page_type = 'shopping_cart'
                and   user_id > 0
          and   operation = 'action_checkout_success'
 )
,opc_view as 
(
    select  session_id
         ,civ_id
        ,last_view_civ_id
        ,grass_region
        ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
            ,cast(json_extract(data, '$.checkout_session_id')as varchar) as checkout_session_id
    from    mp_pa.dwd_eventid_view_order_business_di__reg_live
    where   
             ---  grass_region in ('ID', 'SG','TH','BR','MY', 'TW', 'VN', 'PH')
         grass_region in  ('ID')
      and   grass_date between date '2023-02-22'
      and   date'2023-02-28'
      and   page_type = 'checkout_page'
      and   operation = 'view'
      and   tz_type = 'local'
      and   user_id > 0
      and   platform in ('ios_app', 'android_app')
)

,place_order as 
(
    select  session_id
         ,civ_id
        ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
        ,grass_region
            ,last_view_civ_id
            ,cast(json_extract(data, '$.checkoutid') as BIGINT) as checkout_id
    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where   
          --- grass_region in ('ID', 'SG','TH','BR','MY', 'TW', 'VN', 'PH')
      grass_region in  ('ID')
      and   grass_date between date '2023-02-22'
      and   date'2023-02-28'
      and   page_type = 'checkout_page'
      and   operation = 'action_place_order_success'
      and   tz_type = 'local'
      and   user_id > 0
      and   platform in ('ios_app', 'android_app')
)

,paid_order as 
(
    select  base_checkout_id
            ,concat(cast(grass_date as varchar), cast(buyer_id as varchar)) date_userid
        ,grass_region
    from    mp_order.dwd_order_item_all_ent_df__reg_s0_live
    where            
    ---  grass_region in ('ID', 'SG','TH','BR','MY', 'TW', 'VN', 'PH')
      grass_region in  ('ID')
      and   cast(create_datetime as date) between  date '2023-02-22'
      and   date'2023-02-28'
      and   grass_date >= date'2023-02-22'
      and   pay_timestamp is not null
      and   item_id > 0
      and   shop_id > 0
)
,all_data as
(
    select  distinct
    a.grass_region
    ,a.session_id
         ,a.civ_id
        , a.date_userid
        ,exp_group
        ,case   when b.civ_id is not null then 'checkout'
                    else 'not_checkout'
             end if_checkout
        ,case   when d.civ_id is not null then 'place_order'
                    else 'not_place_order'
             end if_place_order
        ,case when e.base_checkout_id is not null then 'paid'
                    else 'not_paid'
              end if_paid
    from    cartview a
    left join checkout b
    on      a.date_userid = b.date_userid
      and   a.civ_id = b.civ_id
    left join opc_view c
    on     a.date_userid = c.date_userid
    and     a.civ_id = c.last_view_civ_id
    left join place_order d
    on      a.date_userid = d.date_userid
      and   c.civ_id = d.civ_id
    left join paid_order e
    on d.checkout_id = e.base_checkout_id
)
select grass_region
       ,exp_group
       ,if_checkout
       ,if_place_order
       ,if_paid
       ,count(distinct civ_id)       view_cnt
       ,count(distinct date_userid ) user_cnt
       ,count(distinct session_id)   session_cnt
from all_data
group by 1,2,3,4,5