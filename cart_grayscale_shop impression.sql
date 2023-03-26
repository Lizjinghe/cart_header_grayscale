---shop impression
with
impression as 
(
    select  session_id
            ,civ_id
            ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
            ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
            ,grass_region
            ,count(distinct event_id)as impression_cnt
    from    mp_pa.dwd_eventid_impression_order_business_di__reg_live
    where   grass_region in  
  --- ('SG', 'MY', 'BR')
   ( 'PH','ID')
       ---('TH', 'VN')
      and   target_type in('shop')
      and   page_type = 'shopping_cart'
      and   operation = 'impression'
      and   grass_date between date'2023-02-15'
      and   date'2023-02-21'
      and   tz_type = 'local'
      and   user_id > 0
     and platform in ('ios_app','android_app')
    group by 1, 2, 3, 4, 5
)

select  grass_region
        ,exp_group
        ,count(distinct date_userid) user_cnt
        ,count(distinct session_id) session_cnt
        ,count(distinct civ_id) view_cnt
        ,sum(impression_cnt) impression_cnt
from    impression
group by 1, 2
;



-------------- click--------------
with
click as 
(
    select  session_id
            ,civ_id
            ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
            ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
            ,grass_region
            ,count(distinct event_id)as click_cnt
    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where  grass_region in  ('ID', 'SG', 'MY', 'BR', 'TH', 'VN', 'PH')
      and   grass_date between date '2023-02-15'
      and   date'2023-02-21'
      and   target_type in('shop')
      and   page_type = 'shopping_cart'
      and   operation = 'click'
     and platform in ('ios_app','android_app')
      group by 1,2,3,4,5
)

select  grass_region
        ,exp_group
        ,count(distinct date_userid) user_cnt
        ,count(distinct session_id) session_cnt
        ,count(distinct civ_id) view_cnt
        ,sum(click_cnt) click_cnt
from    click
group by 1, 2



----------------checkout -------------

with
checkout as 
(
    select  session_id
            ,civ_id
            ,concat(cast(grass_date as varchar), cast(user_id as varchar)) date_userid
            ,case   when substr(cast(user_id as varchar), -1, 1) in ('1', '3', '5', '7', '9') then 'treatment group'
                    else 'control group'
             end exp_group
            ,grass_region
            ,count(distinct event_id)as checkout_cnt
    from    mp_pa.dwd_eventid_itemid_click_order_business_di__reg_live
    where   grass_region in ('ID','SG', 'MY', 'BR', 'TH', 'VN', 'PH')
      and   grass_date between date '2023-02-15'
      and   date'2023-02-21'
      and   page_type = 'shopping_cart'
      and   operation = 'action_checkout_success'
      and   platform in ('ios_app', 'android_app')
    group by 1, 2, 3, 4, 5
)
select  grass_region
        ,exp_group
        ,count(distinct date_userid) user_cnt
        ,count(distinct session_id) session_cnt
        ,count(distinct civ_id) view_cnt
        ,sum(checkout_cnt) checkout_cnt
from    checkout
group by 1, 2

