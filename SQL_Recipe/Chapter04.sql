/*
4장 매출을 파악하기 위한 데이터 추출
*/

-- ■ 샘플 데이터 purchase_log
DROP TABLE IF EXISTS ch04.purchase_log;
CREATE TABLE ch04.purchase_log(
    dt              string
  , order_id        int64
  , user_id         string
  , purchase_amount int64
);

INSERT INTO ch04.purchase_log
VALUES
    ('2014-01-01',  1, 'rhwpvvitou', 13900)
  , ('2014-01-01',  2, 'hqnwoamzic', 10616)
  , ('2014-01-02',  3, 'tzlmqryunr', 21156)
  , ('2014-01-02',  4, 'wkmqqwbyai', 14893)
  , ('2014-01-03',  5, 'ciecbedwbq', 13054)
  , ('2014-01-03',  6, 'svgnbqsagx', 24384)
  , ('2014-01-03',  7, 'dfgqftdocu', 15591)
  , ('2014-01-04',  8, 'sbgqlzkvyn',  3025)
  , ('2014-01-04',  9, 'lbedmngbol', 24215)
  , ('2014-01-04', 10, 'itlvssbsgx',  2059)
  , ('2014-01-05', 11, 'jqcmmguhik',  4235)
  , ('2014-01-05', 12, 'jgotcrfeyn', 28013)
  , ('2014-01-05', 13, 'pgeojzoshx', 16008)
  , ('2014-01-06', 14, 'msjberhxnx',  1980)
  , ('2014-01-06', 15, 'tlhbolohte', 23494)
  , ('2014-01-06', 16, 'gbchhkcotf',  3966)
  , ('2014-01-07', 17, 'zfmbpvpzvu', 28159)
  , ('2014-01-07', 18, 'yauwzpaxtx',  8715)
  , ('2014-01-07', 19, 'uyqboqfgex', 10805)
  , ('2014-01-08', 20, 'hiqdkrzcpq',  3462)
  , ('2014-01-08', 21, 'zosbvlylpv', 13999)
  , ('2014-01-08', 22, 'bwfbchzgnl',  2299)
  , ('2014-01-09', 23, 'zzgauelgrt', 16475)
  , ('2014-01-09', 24, 'qrzfcwecge',  6469)
  , ('2014-01-10', 25, 'njbpsrvvcq', 16584)
  , ('2014-01-10', 26, 'cyxfgumkst', 11339)
;

-- ■ 1. 날짜별 매출 집계하기
-- 날짜별 매출과 평균 구매액을 집계하는 쿼리
select dt
    , count(*) as purchase_count
    , sum(purchase_amount) as total_amount
    , avg(purchase_amount) as avg_amount
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
order by dt
;

-- ■ 2. 이동평균을 사용한 날짜별 추이 보기
-- 날짜별 매출과 7일 이동평균을 집계하는 쿼리
select dt
    , sum(purchase_amount) as total_amount
    
    -- 최근 "최대" 7일 동안의 평균 (current data 1~7일 전까지의 이동평균을 구함)
    , avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
        as seven_day_avg
    
    -- 최근 "정확히" 7일 동안의 평균 (current data 딱 7일 전까지의 이동평균)
    , case
        when 7 = count(*) over(order by dt rows between 6 preceding and current row)
        then avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
        end
        as seven_day_avg_strict
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
order by dt
;

-- ■ 3. 당월 매출 누계 구하기
-- 날짜별 매출과 당월 누계 매출을 집계하는 쿼리
select dt
    , substr(dt, 1, 7) as year_month
    , sum(purchase_amount) as total_amount
    , sum(sum(purchase_amount)) over(partition by substr(dt, 1, 7) order by dt rows unbounded preceding) as agg_amount
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
order by dt
;
-- 날짜별 매출을 일시 레이블로 만드는 쿼리
with 
daily_purchase as
(
    select 
        dt
        , substr(dt, 1, 4) as year
        , substr(dt, 6, 2) as month
        , substr(dt, 9, 2) as date
        , sum(purchase_amount) as purchase_amount
        , count(order_id) as orders
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
)
select * from daily_purchase order by dt 
;
-- daily_purchase 테이블에 대해 당월 누계 매출을 집계하는 쿼리
with 
daily_purchase as
(
    select 
        dt
        , substr(dt, 1, 4) as year
        , substr(dt, 6, 2) as month
        , substr(dt, 9, 2) as date
        , sum(purchase_amount) as purchase_amount
        , count(order_id) as orders
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
)

select dt
    , concat(year, '-', month) as year_month
    , purchase_amount
    , sum(purchase_amount) over(partition by year, month order by dt rows unbounded preceding) as agg_amount
from daily_purchase 
order by dt 
;
-- 월별 매출과 작대비를 계산하는 쿼리
with 
daily_purchase as
(
    select 
        dt
        , substr(dt, 1, 4) as year
        , substr(dt, 6, 2) as month
        , substr(dt, 9, 2) as date
        , sum(purchase_amount) as purchase_amount
        , count(order_id) as orders
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
)

select month
    , sum(case year when '2014' then purchase_amount end) as amount_2014
    , sum(case year when '2015' then purchase_amount end) as amount_2015
    , 100.0 
        * sum(case year when '2015' then purchase_amount end) 
        / sum(case year when '2014' then purchase_amount end) as rate
from daily_purchase 
group by month 
order by month 
;

-- ■ 4. 월별 매출의 작년 대비 비율 구하기
-- 월별 매출의 작년 대비 비율을 계산하는 쿼리
with 
daily_purchase as
(
    select 
        dt
        , substr(dt, 1, 4) as year
        , substr(dt, 6, 2) as month
        , substr(dt, 9, 2) as date
        , sum(purchase_amount) as purchase_amount
        , count(order_id) as orders
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
)

select month
    , sum(case year when '2014' then purchase_amount end) as amount_2014
    , sum(case year when '2015' then purchase_amount end) as amount_2015
    , 100.0 
        * sum(case year when '2015' then purchase_amount end) 
        / sum(case year when '2014' then purchase_amount end) as rate
from daily_purchase 
group by month 
order by month 
;

-- ■ 5. Z차트로 업적의 추이 확인하기
-- 2015년 매출에 대한 Z차트를 작성하는 쿼리
with 
daily_purchase as (
    select 
        dt
        , substr(dt, 1, 4) as year
        , substr(dt, 6, 2) as month
        , substr(dt, 9, 2) as date
        , sum(purchase_amount) as purchase_amount --날짜별(dt) 매출 합계
        , count(order_id) as orders --날짜별(dt) 주문수
    from `sqlrecipe-335314.ch04.purchase_log`
    group by dt
)
, monthly_amount as (
    select 
        year
        , month
        , sum(purchase_amount) as amount --월별 매출 합계
    from daily_purchase 
    group by daily_purchase.year, daily_purchase.month 
)
, calc_index as (
    select 
        year
        , month
        , amount --월별매출
        , sum(case when year = '2015' then amount end) 
            over(order by year, month rows unbounded preceding)
            as agg_amount --2015년 매출
        , sum(amount)
            over(order by year, month rows between 11 preceding and current row)
            as year_avg_amount --이동년계 매출
    from monthly_amount 
    order by year, month
)

select 
    concat(year, '-', month) as year_month
    , amount 
    , agg_amount
    , year_avg_amount
from calc_index 
where year = '2015'
order by year_month
;