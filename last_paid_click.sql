with tab as (
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
        l.status_id,
        last_value(s.visit_date)
            over (
                partition by l.lead_id
                order by
                    s.visit_date
                range between current row and unbounded following
            )
        as lv
    from sessions as s
    full join leads as l
        on s.visitor_id = l.visitor_id
    where s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
)

select
    visitor_id,
    visit_date,
    source as utm_source,
    medium as utm_medium,
    campaign as utm_campaign,
    lead_id,
    created_at,
    amount,
    closing_reason,
    status_id
from tab
where visit_date = lv
order by
    amount desc nulls last,
    visit_date asc,
    source asc,
    medium asc,
    campaign asc
