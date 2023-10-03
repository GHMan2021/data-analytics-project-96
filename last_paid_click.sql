select
    s.visitor_id,
    s.visit_date,
    s.source,
    s.medium,
    s.campaign,
    l.lead_id,
    l.created_at,
    l.amount,
    l.closing_reason,
    l.status_id
from sessions as s
full join leads as l
    on s.visitor_id = l.visitor_id
where s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
order by
    l.amount desc nulls last,
    s.visit_date asc,
    s.source asc,
    s.medium asc,
    s.campaign asc
limit 10
