/*
SQL 레시피 3장 데이터 가공을 위한 SQL
*/

-- 01. 코드값을 레이블로 변경
-- 테이블 만들기
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
-- 코드를 레이블로 변경
select user_id,
        case 
        when register_device = 1 then '데스크톱'
        when register_device = 2 then '스마트폰'
        when register_device = 3 then '애플리케이션'
        end device_name
from ch03.mst_users
;

-- 02. URL에서 요소 추출
-- 데이터 열기
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
-- 레퍼러 도메인을 추출하는 쿼리
select stamp
       , format("%T", net.host(referrer)) as referrer_host -- host함수는 legacy, net.host가 표준
from `sqlrecipe-335314.ch03.access_log`
;
-- URL에서 경로와 요청 매개변수 값 추출하기
-- ★정규표현식
select stamp
        , url
        , regexp_extract(url, '//[^/]+([^?#]+)') path 
        , regexp_extract(url, 'id=([^&]*)') id
from `sqlrecipe-335314.ch03.access_log`
;

--03. 문자열을 배열로 분해하기
-- URL 경로를 슬래시로 분할해서 계층을 추출하는 쿼리
select stamp, url
        , split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[safe_ordinal(2)] as path1
        , split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[safe_ordinal(3)] as path2
from `sqlrecipe-335314.ch03.access_log`
;

--04. 날짜와 타임스탬프 다루기
--현재 날짜와 타임스탬프를 추출하는 쿼리
select 
    current_date() as dt
    , current_timestamp() as stamp
;
--문자열을 날짜/타임스탬프 자료형으로 변환하는 쿼리
select 
---- cast() <- 가장 범용적
    cast('2021-12-22' as date) as dt
    , cast('2021-12-22 12:38:00' as timestamp) as stamp
---- type(value)
    , date('2021-12-22') as dt
    , timestamp('2021-12-22 12:38:00') as stamp
---- type value
    , date '2021-12-22' as dt
    , timestamp '2021-12-22 12:38:00' as stamp
;
-- 날짜/시각에서 특정 필드 추출하기
-- 타임스탬프 자료형의 데이터에서 연, 월, 일 추출하는 쿼리
select stamp
    , extract(YEAR from stamp) as year
    , extract(month from stamp) as month
    , extract(day from stamp) as day
    , extract(hour from stamp) as hour
from (select current_timestamp() as stamp) as t
;
-- 타임스탬프를 나타내는 "문자열"에서 연, 월, 일 등을 추출하는 쿼리
-- 많은 미들웨어에 범용적으로 사용가능
select stamp
    , substr(stamp, 1, 4) as year
    , substr(stamp, 6, 2) as month
    , substr(stamp, 9, 2) as day
    , substr(stamp, 12, 2) as hour
    , substr(stamp, 1, 7) as year_month
from (select cast('2021-12-22 12:59:00' as string) as stamp) as t
;

-- 05. 결손값을 디폴트값으로 대치하기
-- 데이터 생성
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
-- 구매액에서 할인 쿠폰 값을 제외한 매출 금액 구하는 쿼리
select purchase_id, amount, coupon
        , amount - coupon as discount_amount1
        , amount - coalesce(coupon, 0) as discount_amount2
from `sqlrecipe-335314.ch03.purchase_log_with_coupon`
;