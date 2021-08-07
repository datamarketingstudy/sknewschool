
	-- 여러분이 실제로 데이터 분석 업무를 한다고 가정하겠습니다.

	-- 1. 카테고리(대-소)별 구매 고객수, 구매건수, 매출액, 평균 구매수량, 1인당 구매건수 및 구매일수, 객단가, 상품 전환율을 파악해보겠습니다.

	SELECT	a.prod_cat
		,	a.prod_sub_cat
		,	count(DISTINCT	a.customer_id)			AS cnt_cust
		,	count(DISTINCT a.transaction_id)		AS cnt_order
		,	count(DISTINCT a.tran_date)				AS cnt_buyday
		,	avg(a.qty)								AS avg_qty
		,	sum(a.total_amt)						AS sum_amt
		,	CAST(count(DISTINCT a.transaction_id) AS NUMERIC)/count(DISTINCT	a.customer_id)	AS avg_order
		,	CAST(count(DISTINCT a.tran_date) AS NUMERIC)/count(DISTINCT	a.customer_id)	AS avg_buyday
		,	sum(a.total_amt)/count(DISTINCT	a.customer_id)	AS arpu
		,	sum(CASE WHEN a.tran_status = '정상' THEN 1 end)	AS order_cnt
		,	sum(CASE WHEN a.tran_status = '취소' THEN 1 end)	AS cancel_cnt
		,	(sum(CASE WHEN a.tran_status = '정상' THEN 1 end)-sum(CASE WHEN a.tran_status = '취소' THEN 1 end))
			/CAST(sum(CASE WHEN a.tran_status = '정상' THEN 1 end) AS NUMERIC)		AS cvr
		-- 전환율 = 완료 / 정상 = 상품 전환율
	FROM	(
				SELECT	t.customer_id
					,	t.transaction_id
					,	t.tran_date
					,	t.prod_cat_code
					,	t.prod_sub_cat_code
					,	p.prod_cat
					,	p.prod_sub_cat
					,	t.qty
					,	t.total_amt
					,	CASE WHEN t.total_amt < 0 THEN '취소'
							 ELSE '정상' END						AS tran_status
				FROM	transactions t
				JOIN
						prod_cat_info p
				ON		t.prod_cat_code = p.prod_cat_code
				AND		t.prod_sub_cat_code = p.prod_sub_cat_code
					)	a
	GROUP BY	1, 2
	ORDER BY	cvr desc
					;

	SELECT	*
	FROM	transactions;
				
				
				
	-- 2. 각 카테고리(대-소)별 어떤 연령, 성별에서 구매가 많았는지 파악해보겠습니다.

 WITH	tbl	as(
	SELECT	t.customer_id
		,	EXTRACT(YEAR FROM age(date '2021-07-15', c.dob))	AS age	-- extract(year from age(기준일, 대상일))
		,	c.gender
		,	t.transaction_id
		,	t.tran_date
		,	t.prod_cat_code
		,	t.prod_sub_cat_code
		,	p.prod_cat
		,	p.prod_sub_cat
		,	t.total_amt
	FROM	transactions t
	JOIN	prod_cat_info p
	ON		t.prod_cat_code = p.prod_cat_code
	and		t.prod_sub_cat_code = p.prod_sub_cat_code
	JOIN	customer c
	ON		t.customer_id = c.customer_id
			)
	SELECT	a.prod_cat
		,	a.prod_sub_cat
		,	CASE WHEN a.age	< 30	THEN '20under'
				 WHEN a.age < 40	THEN '30'
				 WHEN a.age < 50	THEN '40'
				 WHEN a.age < 60	THEN '50'
				 ELSE '60over' END				AS age_grp
		,	a.gender
		,	count(DISTINCT a.customer_id)		AS cnt_cust
		,	sum(a.total_amt)					AS sum_amt
	FROM	tbl	a
	GROUP BY	1, 2, 3, 4
	ORDER BY	prod_cat,	prod_sub_cat, sum_amt desc
	;

	SELECT	*
	FROM	customer;

	SELECT	*
	FROM	prod_cat_info;
	
	

	-- 3. 지역별로 구매율은 어떤가요?
	WITH	area_tbl AS (
		SELECT	c.customer_id
			,	c.city_code
			,	ct.city_name
			,	tt.customer_id		AS customer_buy
			,	tt.cnt_order
		FROM	customer c
		JOIN	city ct
		ON		c.city_code = ct.city_code
		LEFT OUTER JOIN
				(	SELECT	t.customer_id
						,	count(DISTINCT t.transaction_id)	AS cnt_order
					FROM	transactions t
					GROUP BY t.customer_id
					) tt
		ON		c.customer_id = tt.customer_id
			)
	SELECT	a.city_name
		,	count(DISTINCT a.customer_id)	AS master_cnt
		,	count(DISTINCT a.customer_buy)	AS buy_cnt
		,	count(DISTINCT a.customer_buy)/CAST(count(DISTINCT a.customer_id) AS NUMERIC)	AS buy_rate
	FROM	area_tbl a
	GROUP BY
			1
	ORDER BY
			4 desc
		;
	
	-- 구매율 = 구매한 고객수 transaction / 등록된 고객수 customer
	

	SELECT	*
	FROM	city;

	SELECT	*
	FROM	customer
	ORDER BY	customer_id
	;

	SELECT	*
	FROM	transactions
	WHERE	customer_id = '266784';



	-- 4. 각 채널별로는 어떤 고객 층이 주로 구매를 하는 지 파악해볼까요? 연령, 성별

 WITH	tbl	AS (
	SELECT	t.customer_id
		,	EXTRACT(YEAR FROM age(date '2021-07-15', c.dob))	AS age
		,	c.gender
		,	t.transaction_id
		,	t.tran_date
		,	t.store_type
		,	t.total_amt
	FROM	transactions t
	JOIN	customer c
	ON		t.customer_id = c.customer_id
			)
	SELECT	a.store_type
		,	CASE WHEN a.age < 30	THEN '20under'
				 WHEN a.age < 40	THEN '30'
				 WHEN a.age < 50	THEN '40'
				 WHEN a.age < 60	THEN '50'
				 ELSE '60over' END					AS age_grp
		,	a.gender
		,	count(DISTINCT a.customer_id)			AS cnt_cust
		,	sum(a.total_amt)						AS sum_amt
	FROM	tbl a
	WHERE	a.gender IS NOT null
	GROUP BY
			1, 2, 3
	ORDER BY
			1, 5 desc
	;

	-- 5. 카테고리별로 특정 채널에서 판매가 많이 이루어지나요?
 WITH	tbl	AS (
	SELECT	t.customer_id
		,	EXTRACT(YEAR FROM age(date '2021-07-15', c.dob))	AS age
		,	c.gender
		,	t.transaction_id
		,	t.prod_cat_code
		,	t.prod_sub_cat_code
		,	p.prod_cat
		,	p.prod_sub_cat
		,	t.tran_date
		,	t.store_type
		,	t.total_amt
	FROM	transactions t
	JOIN	customer c
	ON		t.customer_id = c.customer_id
	JOIN	prod_cat_info p
	ON		t.prod_cat_code = p.prod_cat_code
	AND		t.prod_sub_cat_code = p.prod_sub_cat_code
			)
	SELECT	a.store_type
		,	a.prod_cat
		,	a.prod_sub_cat
		,	count(DISTINCT a.customer_id)			AS cnt_cust
		,	sum(a.total_amt)						AS sum_amt
	FROM	tbl a
	GROUP BY
			1, 2, 3
	ORDER BY	1,	5 desc
	;


	-- 6. 각 카테고리의 재구매는 어떤가요?

	-- 재구매율 = 1회 구매고객 70, 2회이상 구매한 고객 30
	--		  = 2회이상 구매한 고객수 30 / 전체 구매 고객 100
	--		  = 0.3 (재구매율 30%)

 SELECT	a.prod_cat
 	,	a.prod_sub_cat
 	,	count(DISTINCT a.customer_id)	AS tot_cnt_cust
 	,	count(DISTINCT CASE WHEN a.cust_status = '재구매' THEN a.customer_id end)		AS re_cnt_cust
 	,	count(DISTINCT CASE WHEN a.cust_status = '재구매' THEN a.customer_id end)
 		/cast(count(DISTINCT a.customer_id) AS numeric)	AS re_rate
 FROM	(
 	SELECT	t.customer_id
 		,	t.prod_cat_code
 		,	t.prod_sub_cat_code
 		,	p.prod_cat
 		,	p.prod_sub_cat
		,	count(DISTINCT t.transaction_id)		AS cnt_order
		,	CASE WHEN count(DISTINCT t.transaction_id) > 1 THEN '재구매'
				 ELSE '일회구매' END					AS cust_status
	FROM	transactions t
	JOIN
			prod_cat_info p
	ON		t.prod_cat_code = p.prod_cat_code
	AND		t.prod_sub_cat_code = p.prod_sub_cat_code
	GROUP BY	1, 2, 3, 4, 5
		)	a
  GROUP BY	
  			a.prod_cat
  		,	a.prod_sub_cat
  ORDER BY	5 desc
		;


	-- 7.매월 우리 서비스에서는 생일인 고객 전체에게 쿠폰을 발급한다고 가정하겠습니다.
    --	 월별로 쿠폰 발급 수와 실제 구매 수를 가지고 구매 반응률을 살펴보겠습니다.

	SELECT	a.mob
		,	count(DISTINCT a.customer_id)		AS 쿠폰발급대상수
	FROM (
	SELECT	c.customer_id
		,	c.dob
		,	to_char(c.dob, 'mm')	AS mob
	FROM	customer c
			) a
	GROUP BY	a.mob
		;
	
 WITH	tbl	AS (	
	SELECT	t.customer_id
		,	c.dob
		,	to_char(c.dob, 'mm')	AS mob
		,	t.transaction_id
		,	t.tran_date
		,	to_char(t.tran_date, 'yyyy-mm')	AS ym
		,	to_char(t.tran_date, 'mm')		AS mm
	FROM	transactions t
	JOIN	customer c
	ON		t.customer_id = c.customer_id
	WHERE	to_char(c.dob, 'mm') = to_char(t.tran_date, 'mm')
		),
	coupon_tbl	AS (
					SELECT	a.mob
						,	count(DISTINCT a.customer_id)		AS 쿠폰발급대상수
					FROM (
					SELECT	c.customer_id
						,	c.dob
						,	to_char(c.dob, 'mm')	AS mob
					FROM	customer c
							) a
					GROUP BY	a.mob
					)		
	SELECT	a.ym
		,	a.mm
		,	count(DISTINCT a.customer_id)	AS cnt_cust
		,	b.쿠폰발급대상수
	FROM	tbl a
	JOIN	coupon_tbl b
	ON		a.mm = b.mob
	GROUP BY
			1, 2, 4
	;


