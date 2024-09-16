SELECT  pitems.purchases_id as "Purchase ID",
        CASE
            WHEN pitems.admin_profiles_id IS NULL THEN 'WEBSITE'
            ELSE pitems.admin_profiles_id
        END AS "Admin ID",
        CASE
                WHEN pitems.buyed_type LIKE '%Combos%' THEN 'Combo'
                WHEN pitems.buyed_type LIKE '%Membership%' THEN 'Membership'
                WHEN pitems.buyed_type LIKE '%Product%' THEN 'Product'
                ELSE 'Other'
        END AS "Type",
        CASE
                WHEN pitems.buyed_type LIKE '%Combos%' THEN combos.name
                WHEN pitems.buyed_type LIKE '%Membership%' THEN memberships.name
                WHEN pitems.buyed_type LIKE '%Product%' THEN products.name
                ELSE 'Other'
        END AS "Sub-Type",
        uprofiles.first_name as User,
        uprofiles.email as Email,
        memberships.name as Membership,
        CASE
            WHEN reservations.attendance IS NULL THEN 'not-attended'
            ELSE reservations.attendance
        END AS Attendance,
        locations.name as Location,
        reservations.meetings_id as Meeting_ID,
        staff.name as Staff,
        services.name as Service,
        reservations.cancelled as Cancelled,
        reservations.meeting_start Meeting_Date
FROM
    user_profiles as uprofiles
JOIN
    users_memberships as umemberships ON umemberships.user_profiles_id = uprofiles.id
JOIN
    memberships as memberships ON umemberships.memberships_id = memberships.id
JOIN
    reservations as reservations ON reservations.user_profiles_id = uprofiles.users_id
JOIN
    services as services ON reservations.services_id = services.id
JOIN
    staff as staff ON reservations.staff_id = staff.id
JOIN
    locations as locations ON locations.id = reservations.locations_id
JOIN
    purchase_items as pitems ON umemberships.purchase_items_id = pitems.id
LEFT JOIN
    products on pitems.buyed_id = products.id
LEFT JOIN
    combos as combos ON pitems.buyed_id = combos.id
WHERE
    reservations.brands_id = $brand_id AND
    reservations.cancelled IN ($cancel) AND
    locations.name IN ($location) AND
    reservations.meeting_start BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                      AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00');