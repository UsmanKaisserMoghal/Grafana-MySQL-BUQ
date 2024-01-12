SELECT staff.name as Name, count(staff.id) as Sessions
FROM dev.staff as staff JOIN dev.meetings as meetings 
on staff.id=meetings.staff_id
where staff.job="Coach" AND meetings.created_at  and CONVERT(meetings.created_at, DATETIME) between CONVERT_TZ(from_unixtime($__unixEpochFrom()),'+00:00', '-05:00') and CONVERT_TZ(from_unixtime($__unixEpochTo()),'+00:00' , '-05:00')
group by staff.id
