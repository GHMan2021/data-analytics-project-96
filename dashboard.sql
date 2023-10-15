select
    visitor_id,
    visit_date,
    landing_page,
    "source",
    medium,
    campaign,
    "content"
from
    sessions
limit 100
