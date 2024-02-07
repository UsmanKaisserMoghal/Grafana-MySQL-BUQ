SELECT
    loc.name as Location,
    staff.name as Coach,
    COUNT(DISTINCT meetings.id) as Classes,
    COUNT(DISTINCT rez.users_id) as Attendance,
    COUNT(DISTINCT rez.id) as Reservations,
    CASE
        WHEN "$cfrate" < 0 OR "$ccom" < 0 THEN 'ERR'
        WHEN "$cfrate" IS NULL OR "$ccom" IS NULL THEN 0
        WHEN "$cfrate" > 0 AND "$ccom" = 0 THEN "$cfrate" * COUNT(DISTINCT meetings.id)
        WHEN "$cfrate" REGEXP '^[0-9]+$' = 0 OR "$ccom" REGEXP '^[0-9]+$' = 0 OR "$ccomthresh" REGEXP '^[0-9]+$' = 0 THEN 'ERR'
        WHEN "$ccom" > 0 THEN
            CASE
                WHEN "$ccomthresh" = 0 THEN ("$ccom" * COUNT(DISTINCT rez.id)) + ("$cfrate" * COUNT(DISTINCT meetings.id))
                WHEN ("$ccomthresh" > 0 AND COUNT(DISTINCT rez.id) = "$ccomthresh") THEN "$cfrate" * COUNT(DISTINCT meetings.id)
                WHEN ("$ccomthresh" > 0 AND COUNT(DISTINCT rez.id) > "$ccomthresh") THEN ((COUNT(DISTINCT rez.id) - "$ccomthresh") * "$ccom") + ("$cfrate" * COUNT(DISTINCT meetings.id))
                WHEN ("$ccomthresh" > 0 AND COUNT(DISTINCT rez.id) < "$ccomthresh") THEN "$cfrate" * COUNT(DISTINCT meetings.id)
                ELSE
                    'ERR'
            END
        ELSE NULL
    END as Payment
FROM
    dev.meetings as meetings
JOIN
    dev.reservations as rez ON meetings.id = rez.meetings_id
JOIN
    dev.staff as staff ON meetings.staff_id = staff.id
JOIN
    dev.locations as loc ON meetings.locations_id = loc.id
WHERE
    rez.created_at BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                      AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')
    AND meetings.brands_id = $brand_id 
    AND (
        "$ccheck" = "Yes"
        OR ("$ccheck" = "No" AND rez.cancelled = 0)
    )
GROUP BY
    meetings.staff_id,
    loc.id
LIMIT 10;
