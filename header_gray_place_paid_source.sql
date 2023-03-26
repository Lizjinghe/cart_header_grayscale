------place order---------------
with
checkout_source as 
(
    select  distinct session_id
            ,civ_id
            ,date_userid
            ,grass_region
            ,checkout_session_id
            ,case   when pre_page_type = 'shopping_cart' then 'shopping_cart'
                    when pre_target_type = 'buy_now_button' then 'buy_now_button'
                    else 'others'
             end as source
    from    (
        select  session_id
                ,civ_id
                ,grass_region
                ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
                ,cast(json_extract(data, '$.checkout_session_id')as varchar) as checkout_session_id
                ,pre_source.page_type as pre_page_type
                ,pre_source.target_type as pre_target_type
        from    mp_pa.dwd_eventid_view_order_business_di__reg_live
        where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
          ---  grass_region in  ('ID')
          and   grass_date between date '2023-02-22'
          and   date'2023-02-28'
          and   page_type = 'checkout_page'
          and   operation = 'view'
          and   tz_type = 'local'
          and   platform in ('ios_app', 'android_app')
    )
)
,place_order as 
(
    select  session_id
            ,civ_id
            ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
            ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
            ,grass_region
            ,last_view_civ_id
            ,cast(json_extract(data, '$.checkoutid') as BIGINT) as checkout_id
            ,cast(json_extract(data, '$.checkout_session_id') as varchar) as checkout_session_id
    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
      ---  grass_region in  ('ID')
      and   grass_date between date '2023-02-22'
      and   date'2023-02-28'
      and   page_type = 'checkout_page'
      and   operation = 'action_place_order_success'
      and   tz_type = 'local'
      and   user_id > 0
      and   platform in ('ios_app', 'android_app')
)
select  a.grass_region
        ,a.exp_group
        ,count(distinct a.civ_id) view_cnt
        ,count(distinct a.date_userid) user_cnt
        ,count(distinct a.session_id) session_cnt
from    place_order a
left join checkout_source b
on      a.checkout_session_id = b.checkout_session_id
where   b.source in ('shopping_cart')
group by 1, 2
;

-------paid order----
with
checkout_source as 
(
    select  distinct session_id
            ,civ_id
            ,date_userid
            ,grass_region
            ,checkout_session_id
            ,case   when pre_page_type = 'shopping_cart' then 'shopping_cart'
                    when pre_target_type = 'buy_now_button' then 'buy_now_button'
                    else 'others'
             end as source
    from    (
        select  session_id
                ,civ_id
                ,grass_region
                ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
                ,cast(json_extract(data, '$.checkout_session_id')as varchar) as checkout_session_id
                ,pre_source.page_type as pre_page_type
                ,pre_source.target_type as pre_target_type
        from    mp_pa.dwd_eventid_view_order_business_di__reg_live
        where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
          ---  grass_region in  ('ID')
          and   grass_date between date '2023-02-22'
          and   date'2023-02-28'
          and   page_type = 'checkout_page'
          and   operation = 'view'
          and   tz_type = 'local'
          and   platform in ('ios_app', 'android_app')
    )
)
,place_order as 
(
    select  session_id
            ,civ_id
            ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
            ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
            ,grass_region
            ,last_view_civ_id
            ,cast(json_extract(data, '$.checkoutid') as BIGINT) as checkout_id
            ,cast(json_extract(data, '$.checkout_session_id') as varchar) as checkout_session_id
    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
      ---  grass_region in  ('ID')
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
            ,case   when substr(cast(buyer_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
    from    mp_order.dwd_order_item_all_ent_df__reg_s0_live
    where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
      --- grass_region in  ('ID')
      and   cast(create_datetime as date) between  date '2023-02-22'
      and   date'2023-02-28'
      and   grass_date >= date'2023-02-22'
      and   pay_timestamp is not null
      and   item_id > 0
      and   shop_id > 0
)
select  a.grass_region
        ,a.exp_group
        ,count(distinct a.base_checkout_id) view_cnt
        ,count(distinct a.date_userid) user_cnt
from    paid_order a
left join place_order b
on      a.base_checkout_id = b.checkout_id
left join checkout_source c
on      b.checkout_session_id = c.checkout_session_id
where   source in ('shopping_cart')
group by 1, 2
;

---------一张表----------------
with
checkout_source as 
(
    select  distinct session_id
            ,civ_id
            ,date_userid
            ,grass_region
            ,checkout_session_id
            ,case   when pre_page_type = 'shopping_cart' then 'shopping_cart'
                    when pre_target_type = 'buy_now_button' then 'buy_now_button'
                    else 'others'
             end as source
    from    (
        select  session_id
                ,civ_id
                ,grass_region
                ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
                ,cast(json_extract(data, '$.checkout_session_id')as varchar) as checkout_session_id
                ,pre_source.page_type as pre_page_type
                ,pre_source.target_type as pre_target_type
        from    mp_pa.dwd_eventid_view_order_business_di__reg_live
        where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
          ---  grass_region in  ('ID')
        --   and   grass_date between date '2023-02-22'
        --   and   date'2023-02-28'
        and   grass_date between date '2023-01-12'
          and   date'2023-01-18'
          and   page_type = 'checkout_page'
          and   operation = 'view'
          and   tz_type = 'local'
          and   platform in ('ios_app', 'android_app')
    )
)
,place_order as 
(
    select  session_id
            ,civ_id
            ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
            ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
            ,grass_region
            ,last_view_civ_id
            ,cast(json_extract(data, '$.checkoutid') as BIGINT) as checkout_id
            ,cast(json_extract(data, '$.checkout_session_id') as varchar) as checkout_session_id
    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
      ---  grass_region in  ('ID')
    --   and   grass_date between date '2023-02-22'
    --   and   date'2023-02-28'
            and   grass_date between date '2023-01-12'
          and   date'2023-01-18'
      and   page_type = 'checkout_page'
      and   operation = 'action_place_order_success'
      and   tz_type = 'local'
      and   user_id > 0
      and   platform in ('ios_app', 'android_app')
)
,paid_order as 
(
    select  base_checkout_id
            ,concat(cast(cast(create_datetime as date) as varchar), cast(buyer_id as varchar)) date_userid
            ,grass_region
            ,case   when substr(cast(buyer_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
    from    mp_order.dwd_order_item_all_ent_df__reg_s0_live
    where   grass_region in ('ID', 'SG', 'TH', 'BR', 'MY', 'TW', 'VN', 'PH')
      --- grass_region in  ('ID')
    --   and   cast(create_datetime as date) between  date '2023-02-22'
    --   and   date'2023-02-28'
          and   cast(create_datetime as date) between  date '2023-01-12'
      and   date'2023-01-18'
      and   grass_date >= date'2023-01-12'
      and   pay_timestamp is not null
      and   item_id > 0
      and   shop_id > 0
)
select 
 a.grass_region
       ,a.exp_group
        ,count(distinct a.checkout_id) place_view_cnt
       ,count(distinct a.date_userid) place_user_cnt
       ,count(distinct b.base_checkout_id) paid_view_cnt
       ,count(distinct b.date_userid) paid_user_cnt
from    place_order a
left join paid_order b
on      a.checkout_id = b.base_checkout_id
left join checkout_source c
on      a.checkout_session_id = c.checkout_session_id
where   source in ('shopping_cart')
group by 1, 2

;
