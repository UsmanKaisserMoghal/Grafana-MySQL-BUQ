SELECT  
    DATE(sub.meeting_start) as Date,
    COUNT(sub.id) as Total,
    SUM(CASE WHEN sub.cancelled = 0 THEN 1 ELSE 0 END) as Paid,
    SUM(CASE WHEN sub.cancelled = 0 AND (sub.attendance IS NULL OR sub.attendance = 'not-attended' OR sub.attendance = '') THEN 1 ELSE 0 END) as "No Shows",
    SUM(CASE WHEN sub.cancelled = 1 THEN 1 ELSE 0 END) as Canceled,
    COUNT(sub.waitlisted) as Waitlisted,
    (SUM(CASE WHEN sub.cancelled = 0 THEN 1 ELSE 0 END) / COUNT(sub.id)) * 100 as Paying
FROM
    (
        SELECT 
            reservations.id,
            reservations.meeting_start,
            reservations.cancelled,
            reservations.attendance,
            waitlist.meetings_id as waitlisted
        FROM
            dev.reservations as reservations LEFT OUTER JOIN dev.waitlist as waitlist ON reservations.meetings_id = waitlist.meetings_id
        WHERE
            reservations.deleted_at IS NULL AND
            reservations.meeting_start BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                                        AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')
    ) sub
GROUP BY
    DATE(sub.meeting_start);
