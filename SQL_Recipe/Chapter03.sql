/*
SQL ������ 3�� ������ ������ ���� SQL
*/

-- 01. �ڵ尪�� ���̺�� ����
-- ���̺� �����
CREATE TABLE ch03.mst_users(
    user_id         string
  , register_date   string
  , register_device int64
);

INSERT INTO ch03.mst_users
VALUES
    ('U001', '2016-08-26', 1)
  , ('U002', '2016-08-26', 2)
  , ('U003', '2016-08-27', 3)
;
-- �ڵ带 ���̺�� ����
select user_id,
        case 
        when register_device = 1 then '����ũ��'
        when register_device = 2 then '����Ʈ��'
        when register_device = 3 then '���ø����̼�'
        end device_name
from ch03.mst_users
;

-- 02. URL���� ��� ����
-- ������ ����
CREATE TABLE ch03.access_log (
    stamp    string
  , referrer string
  , url      string
);
INSERT INTO ch03.access_log 
VALUES
    ('2016-08-26 12:02:00', 'http://www.other.com/path1/index.php?k1=v1&k2=v2#Ref1', 'http://www.example.com/video/detail?id=001')
  , ('2016-08-26 12:02:01', 'http://www.other.net/path1/index.php?k1=v1&k2=v2#Ref1', 'http://www.example.com/video#ref'          )
  , ('2016-08-26 12:02:01', 'https://www.other.com/'                               , 'http://www.example.com/book/detail?id=002' )
;
-- ���۷� �������� �����ϴ� ����
select stamp
       , format("%T", net.host(referrer)) as referrer_host -- host�Լ��� legacy, net.host�� ǥ��
from `sqlrecipe-335314.ch03.access_log`
;
-- URL���� ��ο� ��û �Ű����� �� �����ϱ�
-- ������ǥ����
select stamp
        , url
        , regexp_extract(url, '//[^/]+([^?#]+)') path 
        , regexp_extract(url, 'id=([^&]*)') id
from `sqlrecipe-335314.ch03.access_log`
;

--03. ���ڿ��� �迭�� �����ϱ�
-- URL ��θ� �����÷� �����ؼ� ������ �����ϴ� ����
select stamp, url
        , split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[safe_ordinal(2)] as path1
        , split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[safe_ordinal(3)] as path2
from `sqlrecipe-335314.ch03.access_log`
;

--04. ��¥�� Ÿ�ӽ����� �ٷ��
--���� ��¥�� Ÿ�ӽ������� �����ϴ� ����
select 
    current_date() as dt
    , current_timestamp() as stamp
;
--���ڿ��� ��¥/Ÿ�ӽ����� �ڷ������� ��ȯ�ϴ� ����
select 
---- cast() <- ���� ������
    cast('2021-12-22' as date) as dt
    , cast('2021-12-22 12:38:00' as timestamp) as stamp
---- type(value)
    , date('2021-12-22') as dt
    , timestamp('2021-12-22 12:38:00') as stamp
---- type value
    , date '2021-12-22' as dt
    , timestamp '2021-12-22 12:38:00' as stamp
;
-- ��¥/�ð����� Ư�� �ʵ� �����ϱ�
-- Ÿ�ӽ����� �ڷ����� �����Ϳ��� ��, ��, �� �����ϴ� ����
select stamp
    , extract(YEAR from stamp) as year
    , extract(month from stamp) as month
    , extract(day from stamp) as day
    , extract(hour from stamp) as hour
from (select current_timestamp() as stamp) as t
;
-- Ÿ�ӽ������� ��Ÿ���� "���ڿ�"���� ��, ��, �� ���� �����ϴ� ����
-- ���� �̵��� ���������� ��밡��
select stamp
    , substr(stamp, 1, 4) as year
    , substr(stamp, 6, 2) as month
    , substr(stamp, 9, 2) as day
    , substr(stamp, 12, 2) as hour
    , substr(stamp, 1, 7) as year_month
from (select cast('2021-12-22 12:59:00' as string) as stamp) as t
;

-- 05. ��հ��� ����Ʈ������ ��ġ�ϱ�
-- ������ ����
CREATE TABLE ch03.purchase_log_with_coupon (
    purchase_id string
  , amount      int64
  , coupon      int64
);
INSERT INTO ch03.purchase_log_with_coupon
VALUES
    ('10001', 3280, NULL)
  , ('10002', 4650,  500)
  , ('10003', 3870, NULL)
;
-- ���ž׿��� ���� ���� ���� ������ ���� �ݾ� ���ϴ� ����
select purchase_id, amount, coupon
        , amount - coupon as discount_amount1
        , amount - coalesce(coupon, 0) as discount_amount2
from `sqlrecipe-335314.ch03.purchase_log_with_coupon`
;