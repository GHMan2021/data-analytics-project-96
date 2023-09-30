/*
select 
	l.visitor_id,
	s.visit_date,
	s."source",
	s.medium,
	s.campaign,
	l.lead_id,
	l.created_at,
	l.amount ,
	l.closing_reason ,
	l.status_id 
from sessions as s
left join leads l  
	on s.visitor_id = l.visitor_id
--where l.amount >= 0
order by l.amount desc, s.visit_date */

/*
select 
	s.visitor_id,
	s.visit_date,
	
	l.lead_id,
	l.created_at
	--age(s.visitor_id, l.created_at) as delta
from sessions s
left join leads l 
on s.visitor_id = l.visitor_id
where l.lead_id is not null  
order by s.visitor_id , s.visit_date
limit 150;*/

select
    s.visitor_id,
    s.visit_date,
    s.source,
    s.medium,
    s.campaign,
    l.lead_id,
    l.created_at,
    l.amount ,
    l.closing_reason ,
    l.status_id 
from sessions as s
full join leads as l
    on s.visitor_id = l.visitor_id
order by l.amount desc nulls last , s.visit_date , s."source" , s.medium , s.campaign  
limit 10
 

