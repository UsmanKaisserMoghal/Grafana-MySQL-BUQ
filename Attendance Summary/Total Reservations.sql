SELECT uprofiles.first_name as User, uprofiles.email as Email, locations.name as Location, reservations.meetings_id as Meeting_ID, staff.name as Staff, reservations.cancelled as Cancelled, reservations.meeting_start Meeting_Date
FROM
    dev.user_profiles as uprofiles
JOIN
    dev.reservations as reservations ON reservations.user_profiles_id = uprofiles.users_id
JOIN
    dev.staff as staff ON reservations.staff_id = staff.id
JOIN
    dev.locations as locations ON locations.id = reservations.locations_id
WHERE
    reservations.brands_id = $brand_id AND
    locations.name IN ($location) AND
    reservations.meeting_start BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                      AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00');