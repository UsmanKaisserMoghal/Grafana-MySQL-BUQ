SELECT  
    DATE(reservations.meeting_start) as Date,
    COUNT(reservations.id) as Total,
    SUM(CASE WHEN reservations.cancelled = 0 AND paytypes.name NOT LIKE "%comp%" THEN 1 ELSE 0 END) as Paid,
    SUM(CASE WHEN reservations.cancelled = 0 AND paytypes.name LIKE "%comp%" THEN 1 ELSE 0 END) as Comped,
    SUM(CASE WHEN reservations.cancelled = 0 AND reservations.attendance = 'first-time' THEN 1 ELSE 0 END) as "First Time",
    SUM(CASE WHEN reservations.cancelled = 0 AND (reservations.attendance IS NULL OR reservations.attendance = 'not-attended' OR reservations.attendance = '') THEN 1 ELSE 0 END) as "No Shows",
    SUM(CASE WHEN reservations.cancelled = 1 THEN 1 ELSE 0 END) as Cancelled,
    COUNT(waitlist.reservations_id) as Waitlisted,
    SUM(CASE WHEN reservations.cancelled = 0 AND reservations.attendance != 'first-time' THEN 1 ELSE 0 END) as "Repeat",
    ROUND(COUNT(reservations.id) / COUNT(DISTINCT reservations.meetings_id)) as AVG,
    COUNT(DISTINCT reservations.meetings_id) as "Number Classes",
    LEAST((COUNT(reservations.id) / (COUNT(DISTINCT reservations.meetings_id) * 29)) * 100,100) as Capacity,
    (SUM(CASE WHEN reservations.cancelled = 0 AND paytypes.name NOT LIKE "%comp%" THEN 1 ELSE 0 END) / COUNT(reservations.id)) * 100 as Paying,
    SUM(purchases.total) as Revenue
FROM
    dev.reservations as reservations JOIN reservation_credits as rescredits ON reservations.id=rescredits.reservations_id
    JOIN meetings as meetings ON reservations.meetings_id=meetings.id
    JOIN users_credits as ucredits ON rescredits.users_credits_id=ucredits.id
    JOIN purchases as purchases ON ucredits.purchases_id=purchases.id
    JOIN payment_types as paytypes ON purchases.payment_types_id=paytypes.id
    LEFT OUTER JOIN dev.waitlist as waitlist ON reservations.id = waitlist.reservations_id
WHERE
    reservations.deleted_at IS NULL AND
    reservations.meeting_start BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                                AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')
GROUP BY
    DATE(reservations.meeting_start);