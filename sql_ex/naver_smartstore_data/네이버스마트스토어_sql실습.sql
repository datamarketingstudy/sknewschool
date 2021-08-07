
		select *
		from	buy_complete bc;
		
		select *
		from	pay_detail pd;
		
		select	*
		from	prod_info;
	
		
	
	 --	 판매현황 집계 
	
		select	bc.prod_no
			,	bc.prod_nm
			,	bc.prod_price
			,	count(distinct bc.ord_no)		as cnt_order
			,	sum(bc.qty)						as qty
			,	sum(bc.prod_price)				as sum_prc
			,	sum(bc.prod_dc)					as dc_amt
			,	sum(bc.total_amt)				as tot_amt
		from	buy_complete bc
		group by
				1, 2, 3
		order by
				prod_no, tot_amt desc;
			
	--	카테고리별 현황 
			
	select	p.large_category
		,	p.medium_category 
		,	p.small_category 
		,	p.detail_category 
		,	p.prod_no 
		,	p.prod_nm 
		,	bc.prod_price
		,	count(distinct bc.ord_no)		as cnt_order
		,	sum(bc.qty)						as qty
		,	sum(bc.prod_price)				as sum_prc
		,	sum(bc.prod_dc)					as dc_amt
		,	sum(bc.total_amt)				as tot_amt
	from	prod_info p
	join	buy_complete bc 
	on		p.prod_no = bc.prod_no 
	group by
			1, 2, 3, 4, 5, 6, 7
	order by
			tot_amt desc;
				
			
	-- 거래일자별 현황 
		
	select to_char(bc.pay_dt, 'yyyy-mm-dd')		as pay_dt
		,  count(*)								as cnt_row
		,  count(distinct bc.cust_nm)				as cnt_Cust
		,  count(distinct bc.ord_no)			as cnt_order
		,  sum(bc.total_amt)					as amt
		,  sum(bc.nav_pay_fee)					as naver_pay_fee
		,  sum(bc.sales_fee)					as sales_fee
		,  sum(bc.deal_plan_amt)				as deal_plan_amt
	from	buy_complete bc 
	group by	1
	order by	1;

	-- 평균 구매확정일과 평균 배송기간 구하기

	with duration_tbl as(
		select	bc.pay_dt
			,	bc.deliv_fins_dt 
			,	bc.buy_fins_dt
			,	bc.deliv_fins_dt - bc.pay_dt as deliv_duration
			,	bc.buy_fins_dt - bc.pay_dt as buy_complete_duration
			,	extract(day from (bc.deliv_fins_dt - bc.pay_dt))	as deliv_duration_day
			,	extract(day from (bc.buy_fins_dt - bc.pay_dt))		as buy_complete_duration_day
		from	buy_complete bc
			)
	select	round(cast(avg(a.deliv_duration_day) as numeric), 1)		as mean_delive_duration
		,	round(cast(avg(a.buy_complete_duration_day) as numeric), 1)	as mean_buy_complete_duration
	from	duration_tbl a
	
	-- 배송업체별 평균 배송기간 및 구매확정 기간 구하기
	
	with duration_tbl as(
		select	bc.deliv_company
			,	bc.pay_dt
			,	bc.deliv_fins_dt 
			,	bc.buy_fins_dt
			,	bc.deliv_fins_dt - bc.pay_dt as deliv_duration
			,	bc.buy_fins_dt - bc.pay_dt as buy_complete_duration
			,	extract(day from (bc.deliv_fins_dt - bc.pay_dt))	as deliv_duration_day
			,	extract(day from (bc.buy_fins_dt - bc.pay_dt))		as buy_complete_duration_day
		from	buy_complete bc
			)
	select	a.deliv_company
		,	count(*)													as cnt_transaction
		,	round(cast(avg(a.deliv_duration_day) as numeric), 1)		as mean_delive_duration
		,	round(cast(avg(a.buy_complete_duration_day) as numeric), 1)	as mean_buy_complete_duration
	from	duration_tbl a
	group by
			1;

	-- 구매일수가 2일 이상인 고객 추출
		
	select	bc.cust_id
		,	count(distinct bc.pay_dt)		as cnt_days
	from	buy_complete bc
	group by
			1
	having	count(distinct bc.pay_dt) > 1
	;
	
	--재구매율

 select		count(distinct	a.cust_id)		as tot_cust
 	,		sum(case when a.cust_gb = '일회구매' then 1 end)	as one_cust
 	,		sum(case when a.cust_gb = '재구매' then 1 end)	as re_cust
 	,		cast(sum(case when a.cust_gb = '재구매' then 1 end) as numeric)/count(distinct	a.cust_id)	as retention_rate
 from (
	select	bc.cust_id
		,	count(distinct bc.pay_dt)		as cnt_days
		,	case when count(distinct bc.pay_dt) > 1 then '재구매'
				 else '일회구매'	end			as cust_gb
	from	buy_complete bc
	group by 1
		)	a
	;
	
	-- 구매 확정 전환 현황

	select	pd.cust_nm
		,	pd.ord_no
		,	count(distinct pd.prod_ord_no)		as cnt_prod
		,	bc.ord_no		as comp_ord_no
		,	bc.comp_cnt_prod
	from	pay_detail pd
	left outer join
			(	select	ord_no
					,	count(*)				as comp_cnt_prod
				from	buy_complete
				group by 1 ) bc
	on		pd.ord_no = bc.ord_no
	group by
			1, 2, 4, 5;
		
	
	-- 인입 경로별 주문건
			
		
	select	bc.in_source 
		,	count(distinct bc.ord_no)		as cnt_order
	from 	buy_complete bc
	group by 1
	order by 2 desc;
	
	-- 데이터베이스 조인

	select	pd.cust_nm
		,	pd.deal_gb
		,	substring(pd.ord_no, 1, 8)		as ord_dt
		,	pd.ord_no
		,	pd.prod_ord_no
		,	deliv.deal_gb
		,	pc.large_category
		,	pc.medium_category
		,	pc.small_category
		,	pc.detail_category
		,	bc.prod_no
		,	pd.prod_nm		
		,	deliv.deliv_cost
		,	pd.paid_amt
	from	pay_detail pd
	join
			( select	distinct prod_no
					,	prod_nm
			  from		buy_complete ) bc		-- PROD_NO 상품명
	on		pd.prod_nm = bc.prod_nm
	left outer join		
			( select	distinct ord_no
					,	deal_gb
					,	paid_amt 				as deliv_cost
			  from		pay_detail
			  where		deal_gb = '배송비'
			  	) deliv							-- 배송비 정보
	on		pd.ord_no = deliv.ord_no
	join	
			(	select	prod_no
					,	large_category
					,	medium_category
					,	small_category
					,	detail_category
				from	prod_info
				)	pc
	on		bc.prod_no = pc.prod_no 
	order by 1, 4
	;

	-- 구매건 카테고리 조합
 with ord_tbl as (
	select	pd.cust_nm
		,	pd.deal_gb
		,	substring(pd.ord_no, 1, 8)		as ord_dt
		,	pd.ord_no
		,	pd.prod_ord_no
		,	deliv.deal_gb
		,	pc.large_category
		,	pc.medium_category
		,	pc.small_category
		,	pc.detail_category
		,	bc.prod_no
		,	pd.prod_nm		
		,	deliv.deliv_cost
		,	pd.paid_amt
	from	pay_detail pd
	join
			( select	distinct prod_no
					,	prod_nm
			  from		buy_complete ) bc		-- PROD_NO ���ϱ�
	on		pd.prod_nm = bc.prod_nm
	left outer join		
			( select	distinct ord_no
					,	deal_gb
					,	paid_amt 				as deliv_cost
			  from		pay_detail
			  where		deal_gb = '배송비'
			  	) deliv							-- ��ۺ� �ֹ� ���̱�
	on		pd.ord_no = deliv.ord_no
	join	
			(	select	prod_no
					,	large_category
					,	medium_category
					,	small_category
					,	detail_category
				from	prod_info
				)	pc
	on		bc.prod_no = pc.prod_no 
	order by 1, 4
			)
	--, cate_tbl as (
	select	ord.ord_no
		,	string_agg(ord.small_category, ',')			as cate_nms
		,	sum(ord.paid_amt)							as paid_amt
	from	ord_tbl ord
	group by
			1	
	/*		)
	select	cate_nms
		,	count(distinct ord_no)			as cnt_ord
		,	sum(paid_amt)					as amt
	from	cate_tbl
	group by
			1
	order by 2 desc */
	;

	-- 상품별 판매 현황

	select	distinct p.prod_no
		,	p.prod_nm
		,	p.prod_price
		,	to_char(p.insert_dt, 'yyyy-mm-dd')		as insert_dt
		,	to_char(p.modify_dt, 'yyyy-mm-dd')		as modify_dt
		,	bc.cnt_prod
		,	bc.amt
	from	prod_info p
	left outer join
			(
				select	prod_no
					,	count(distinct prod_ord_no)		as cnt_prod
					,	sum(total_amt)					as amt
				from	buy_complete
				group by
						1
						)	bc
	on		p.prod_no = bc.prod_no
	order by	cnt_prod desc nulls last
	;

	-- 상품 판매율 현황 
 with prod_ord_tbl as (
	select	distinct p.prod_no
		,	p.prod_nm
		,	p.prod_price
		,	to_char(p.insert_dt, 'yyyy-mm-dd')		as insert_dt
		,	to_char(p.modify_dt, 'yyyy-mm-dd')		as modify_dt
		,	bc.cnt_prod
		,	bc.amt
	from	prod_info p
	left outer join
			(
				select	prod_no
					,	count(distinct prod_ord_no)		as cnt_prod
					,	sum(total_amt)					as amt
				from	buy_complete
				group by
						1
						)	bc
	on		p.prod_no = bc.prod_no
				)
	select	count(distinct a.prod_no)		as tot_prod_cnt
		,	count(distinct case when a.cnt_prod is not null then a.prod_no end)		as ord_prod_cnt
		,	count(distinct case when a.cnt_prod is not null then a.prod_no end)
			/cast(count(distinct a.prod_no) as numeric)								as prod_ord_rate
	from	prod_ord_tbl a;

	--	판매 순위 집계
	select	rank() over(order by a.qty desc)		as rnk
		,	a.large_category
		,	a.medium_category
		,	a.small_category
		,	a.prod_no
		,	a.prod_nm
		,	a.qty
		,	a.amt
	from (
			select	p.large_category
				,	p.medium_category
				,	p.small_category
				,	p.prod_no
				,	p.prod_nm
				,	sum(bc.qty)			as qty
				,	sum(bc.total_amt)	as amt
			from	prod_info p
			join
					buy_complete bc
			on		p.prod_no = bc.prod_no
			group by 
					1, 2, 3, 4, 5
						) a
					;

	--	이동평균선
				
	select	to_char(bc.pay_dt, 'yyyy-mm-dd')	as pay_dt
		,	sum(bc.total_amt)	as amt
		,	avg(sum(bc.total_amt))	over(order by to_char(bc.pay_dt, 'yyyy-mm-dd') rows between 6 preceding and current row)	as seven_day_avg
		,	case when 7 = count(*)	over(order by to_char(bc.pay_dt, 'yyyy-mm-dd') rows between 6 preceding and current row)
				 then avg(sum(bc.total_amt)) over(order by to_char(bc.pay_dt, 'yyyy-mm-dd') rows between 6 preceding and current row) end as seven_day_avg_strict
	from 	buy_complete bc
	group by 1
	order by 1
	;

	--	월별 누계 매출 파악하기

 with ord_tbl as(
	select	to_char(bc.pay_dt, 'yyyy-mm-dd')		as pay_dt
		,	to_char(bc.pay_dt, 'yyyy-mm')			as ym
		,	sum(bc.total_amt)						as amt
	from	buy_complete bc 
	group by
			1, 2
				)
  select	b.pay_dt
  		,	b.ym
  		,	b.amt
  		,	sum(b.amt) over(partition by b.ym order by b.pay_dt rows unbounded preceding)	as agg_amt
  from		ord_tbl b
  order by  1
  ;
 
 	--	Z차트를 통한 시계열 분석 
 
 	with	tbl as(
 		select	to_char(bc.pay_dt, 'yyyy-mm-dd')		as pay_dt
 			,	sum(bc.total_amt)						as amt
 			,	row_number() over(order by to_char(bc.pay_dt, 'yyyy-mm-dd'))	as dt_no
 		from	buy_complete bc
 		group by
 				1
 				)
 		, calc_tbl as (
 		select	a.dt_no
 			,	a.pay_dt
 			,	a.amt
 			,	sum(case when a.dt_no between 13 and 24 then a.amt end)	over(order by a.pay_dt rows unbounded preceding)	as agg_amt
 			,	sum(a.amt)	over(order by a.pay_dt rows between 11 preceding and current row)	as avg_amt
 		from	tbl a
 		group by	1, 2, 3
 		order by	1, 2
 					)
 		select	ct.*
 		from	calc_tbl ct
 		where	ct.dt_no between 13 and 24
 		;
 	
 	--	ABC	분석으로 잘 팔리는 상품, 카테고리 판별하기
 
 	with tbl as (
 		select	p.prod_no
 			,	p.prod_nm
 			,	p.small_category
 			,	sum(bc.total_amt)			as amt
 		from	prod_info p
 		join
 				buy_complete bc 
 		on		p.prod_no = bc.prod_no
 		group by
 				1, 2, 3
 				),
 		comp_tbl as	(
 		select	a.prod_no
 			,	a.prod_nm
 			,	a.small_category
 			,	a.amt
 			,	100*a.amt /sum(a.amt) over()		as comp_ratio	-- ������
 			,	100*sum(a.amt) over(order by	a.amt desc rows between unbounded preceding and current row)/sum(a.amt) over()	as cum_ratio -- ������ ����
 		from	tbl a )
 		select	c.*
 			,	case when c.cum_ratio between 0 and 70	then 'A'
 					 when c.cum_ratio between 70 and 90 then 'B'
 					 when c.cum_ratio between 90 and 100 then 'C'
 					 end	as abc_rnk
 		from	comp_tbl c
 		order by
 				c.amt desc;
 		
 	-- 팬 차트 
 	
 		with week_tbl as(	
		 	select	extract(week from bc.pay_dt)			as week_gb
		 		,	sum(bc.total_amt)						as amt
		 	from 	buy_complete bc
		 	group by 1
		 	order by 1
		 		)
		 select	a.week_gb
		 	,	a.amt
		 	,	first_value(a.amt)	over(order by	a.week_gb rows unbounded preceding)		as base_amt
		 	,	100*a.amt / first_value(a.amt)	over(order by a.week_gb rows unbounded preceding)	as rate
		 from	week_tbl a
		 	;
		 			
 		;
 	
	-- ���̺��� ���ܵ� ä �����͸� ������ ���
	
	--	truncate ���̺��;

	truncate buy_complete;
	




	select *
	from	pay_detail pd 
	where 	pd.ord_no = '2021052246327861';
