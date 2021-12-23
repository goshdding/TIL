/*
4�� ������ �ľ��ϱ� ���� ������ ����
*/

-- �� ���� ������ purchase_log
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

-- �� 1. ��¥�� ���� �����ϱ�
-- ��¥�� ����� ��� ���ž��� �����ϴ� ����
select dt
    , count(*) as purchase_count
    , sum(purchase_amount) as total_amount
    , avg(purchase_amount) as avg_amount
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
order by dt
;

-- �� 2. �̵������ ����� ��¥�� ���� ����
-- ��¥�� ����� 7�� �̵������ �����ϴ� ����
select dt
    , sum(purchase_amount) as total_amount
    
    -- �ֱ� "�ִ�" 7�� ������ ��� (current data 1~7�� �������� �̵������ ����)
    , avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
        as seven_day_avg
    
    -- �ֱ� "��Ȯ��" 7�� ������ ��� (current data �� 7�� �������� �̵����)
    , case
        when 7 = count(*) over(order by dt rows between 6 preceding and current row)
        then avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
        end
        as seven_day_avg_strict
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
order by dt
;

-- �� 3. ��� ���� ���� ���ϱ�
-- ��¥�� ����� ��� ���� ������ �����ϴ� ����
select dt
    , substr(dt, 1, 7) as year_month
    , sum(purchase_amount) as total_amount
    , sum(sum(purchase_amount)) over(partition by substr(dt, 1, 7) order by dt rows unbounded preceding) as agg_amount
from `sqlrecipe-335314.ch04.purchase_log`
group by dt
order by dt
;
-- ��¥�� ������ �Ͻ� ���̺�� ����� ����
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
-- daily_purchase ���̺� ���� ��� ���� ������ �����ϴ� ����
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
-- ���� ����� �۴�� ����ϴ� ����
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

-- �� 4. ���� ������ �۳� ��� ���� ���ϱ�
-- ���� ������ �۳� ��� ������ ����ϴ� ����
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

-- �� 5. Z��Ʈ�� ������ ���� Ȯ���ϱ�
-- 2015�� ���⿡ ���� Z��Ʈ�� �ۼ��ϴ� ����
with 
daily_purchase as (
    select 
        dt
        , substr(dt, 1, 4) as year
        , substr(dt, 6, 2) as month
        , substr(dt, 9, 2) as date
        , sum(purchase_amount) as purchase_amount --��¥��(dt) ���� �հ�
        , count(order_id) as orders --��¥��(dt) �ֹ���
    from `sqlrecipe-335314.ch04.purchase_log`
    group by dt
)
, monthly_amount as (
    select 
        year
        , month
        , sum(purchase_amount) as amount --���� ���� �հ�
    from daily_purchase 
    group by daily_purchase.year, daily_purchase.month 
)
, calc_index as (
    select 
        year
        , month
        , amount --��������
        , sum(case when year = '2015' then amount end) 
            over(order by year, month rows unbounded preceding)
            as agg_amount --2015�� ����
        , sum(amount)
            over(order by year, month rows between 11 preceding and current row)
            as year_avg_amount --�̵���� ����
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