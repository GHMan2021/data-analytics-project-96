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
	date(s.visit_date) as visit_date,
	s."source",
	s.medium,
	s.campaign,
	count(*) as visitors_count
from
	sessions s
group by
	date(s.visit_date),
	s."source",
	s.medium,
	s.campaign
),
t_sessions_cost as (
select
	ts.*,
	ta.total_cost
from
	t_sessions as ts
left join t_ads as ta
on
	(ta.campaign_date,
	ta.utm_source,
	ta.utm_medium,
	ta.utm_campaign) = (ts.visit_date,
	ts."source",
	ts.medium,
	ts.campaign)
order by
	ts.visit_date
),
--- main table --- select * from t_sessions_cost
t_leads as (
select
	date(tmp.visit_date) as visit_date,
	tmp."source",
	tmp.medium,
	tmp.campaign,
	tmp.lead_id,
	case  
		when tmp.status_id = 142 then 1
		else 0
	end as status_id,	
	tmp.amount
from
	(
	select
		l.visitor_id ,
		l.lead_id ,
		l.amount ,
		l.status_id ,
		l.created_at ,
		s.visit_date,
		s."source" ,
		s.medium ,
		s.campaign ,
		row_number() over (partition by l.lead_id
	order by
		s.visit_date desc) as rn
	from
		leads l
	inner join sessions s 
on
		s.visitor_id = l.visitor_id
	where
		date_part('millisecond',
		l.created_at - s.visit_date) >= 0
	order by
		s.visitor_id,
		s.visit_date desc) as tmp
where
	tmp.rn = 1
order by 
	visit_date,
	tmp."source",
	tmp.medium
),
t_leads_formatted as (
select
	tl.visit_date,
	tl."source",
	tl.medium,
	tl.campaign,
	count(tl.lead_id) as leads_count,
	sum(tl.status_id) as purchases_count,
	sum(tl.amount) as revenue
from
	t_leads tl
group by  
	tl.visit_date,
	tl."source",
	tl.medium,
	tl.campaign
)
select
	tsc.*,
	tlf.leads_count,
	tlf.purchases_count,
	tlf.revenue
from
	t_sessions_cost as tsc
left join t_leads_formatted as tlf
on
	(tlf.visit_date,
	tlf."source",
	tlf.medium,
	tlf.campaign) = (tsc.visit_date,
	tsc."source",
	tsc.medium,
	tsc.campaign)
order by 
	tlf.revenue desc nulls last,
	tsc.visit_date,
	tsc.visitors_count desc,
	tsc."source",
	tsc.medium,
	tsc.campaign
limit 15;