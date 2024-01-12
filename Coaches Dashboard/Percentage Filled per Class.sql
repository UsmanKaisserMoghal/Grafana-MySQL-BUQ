SELECT
    staff.name as Coach,
    services.name as Service,
    loc.name as Location,
    COUNT(DISTINCT rez.users_id) as UserCount,
    meetings.capacity as Capacity,
    (COUNT(DISTINCT rez.users_id) / meetings.capacity) * 100 as PercentageUsers
FROM
    dev.meetings as meetings
JOIN
    dev.reservations as rez ON meetings.id = rez.meetings_id
JOIN
    dev.staff as staff ON meetings.staff_id = staff.id
JOIN
    dev.services as services ON meetings.services_id = services.id
JOIN
    dev.locations as loc ON meetings.locations_id = loc.id
WHERE
    rez.created_at BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                      AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')
    AND staff.job = "Coach"
GROUP BY
    meetings.id,
    meetings.capacity,
    staff.name,
    services.name,
    loc.name
