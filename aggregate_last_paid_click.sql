with t_ads as (
select	
	date(campaign_date) as campaign_date,
	utm_source,
	utm_medium,
	utm_campaign,
	sum(daily_spent) as total_cost
from
	vk_ads va
group by
	date(campaign_date),
	utm_source,
	utm_medium,
	utm_campaign
union all
select
	date(campaign_date),
	utm_source,
	utm_medium,
	utm_campaign,
	sum(daily_spent) as total_cost
from
	ya_ads
group by
	date(campaign_date),
	utm_source,
	utm_medium,
	utm_campaign
),
t_sessions as (
select 	
		s.visitor_id,
		s.visit_date,
		s."source",
		s.medium,
		s.campaign,
		case 
			when l.created_at is not null then 1
		else 0
	end as leads_count_c ,		
		l.created_at,
		l.amount,
		l.closing_reason,
		case  
			when l.status_id = 142 then 1
		else 0
	end as status_id,
		case 
			when s.visit_date <= l.created_at then 1
		else 0
	end as cv ,
		row_number() over (partition by s.visitor_id
order by
	s.visit_date desc) as rn
from 
		sessions s
left join
		leads l
	on
		l.visitor_id = s.visitor_id
where 
		s.medium != 'organic'
),
t_leads as (
select	
	date(ts.visit_date) as visit_date,
	ts."source" as utm_source,
	ts.medium as utm_medium,
	ts.campaign as utm_campaign,
	count(ts.cv) as visitors_count, 
	sum(ts.cv) as leads_count ,
	sum(ts.status_id) as purchases_count,
	sum(ts.amount) as revenue
from 
	t_sessions as ts
where 
	ts.rn = 1
group by
	date(ts.visit_date),
	ts."source",
	ts.medium,
	ts.campaign
)
select 
	tl.visit_date,
	tl.visitors_count,
	tl.utm_source,
	tl.utm_medium,
	tl.utm_campaign,
	ta.total_cost,
	tl.leads_count,
	tl.purchases_count,
	tl.revenue
from
	t_leads tl
left join
	t_ads ta
on 
	(ta.campaign_date,
	ta.utm_source,
	ta.utm_medium,
	ta.utm_campaign) = (tl.visit_date,
	tl.utm_source,
	tl.utm_medium,
	tl.utm_campaign)
where 
	tl.utm_source <> 'admitad'
order by
	tl.revenue desc nulls last,
	tl.visit_date,
	tl.visitors_count,
	tl.utm_source,
	tl.utm_medium,
	tl.utm_campaign;
