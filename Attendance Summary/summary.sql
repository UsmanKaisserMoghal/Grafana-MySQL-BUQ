SELECT  
    SUBSTRING(reservations.meeting_start, 1, 10) as Date,
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
    SUM(
        CASE 
            WHEN reservations.cancelled = 0 AND paytypes.name NOT LIKE "%comp%" AND pitems.buyed_type LIKE "%Combos%" THEN pitems.item_price_final 
            WHEN reservations.cancelled = 0 AND paytypes.name NOT LIKE "%comp%" AND pitems.buyed_type LIKE "%Membership%" THEN memberships.estimated_value_class
            ELSE 0
        END
    ) as Revenue
FROM
    reservations as reservations LEFT JOIN reservation_credits as rescredits ON reservations.id=rescredits.reservations_id
    LEFT JOIN meetings as meetings ON reservations.meetings_id=meetings.id
    LEFT JOIN users_credits as ucredits ON rescredits.users_credits_id=ucredits.id
    LEFT JOIN purchases as purchases ON ucredits.purchases_id = purchases.id
    LEFT JOIN purchase_items as pitems ON pitems.purchases_id = ucredits.purchases_id
    LEFT JOIN payment_types as paytypes ON purchases.payment_types_id=paytypes.id
    LEFT OUTER JOIN waitlist as waitlist ON reservations.id = waitlist.reservations_id
    LEFT JOIN staff as staff ON staff.id = reservations.staff_id
    LEFT JOIN locations as locations ON locations.id = reservations.locations_id
    LEFT JOIN users as users ON users.id = reservations.users_id
    LEFT JOIN users_memberships as umemberships ON umemberships.purchase_items_id = reservations.memberships_id
    LEFT JOIN memberships as memberships ON memberships.id = umemberships.memberships_id
WHERE
    reservations.brands_id = $brand_id AND
    reservations.meeting_start BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                                AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')
GROUP BY
    SUBSTRING(reservations.meeting_start, 1, 10);