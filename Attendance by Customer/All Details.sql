SELECT uprofiles.first_name as User, uprofiles.email as Email, purchases.subtotal as Total_Price, purchases.status as Status, locations.name as Location, purchases.created_at as Purchase_Date, reservations.meetings_id as Meeting_ID, reservations.meeting_start Meeting_Date
FROM
    dev.user_profiles as uprofiles
JOIN
    dev.purchases as purchases ON purchases.user_profiles_id = uprofiles.users_id
JOIN
    dev.reservations as reservations ON reservations.user_profiles_id = uprofiles.users_id
JOIN
    dev.locations as locations ON locations.id = purchases.locations_id
WHERE
    purchases.brands_id = $brand_id AND
    purchases.status IN ($paymentstatus) AND 
    locations.name IN ($location) AND
    purchases.created_at BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                      AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00');