SELECT
    reservations.meeting_start,
    purchases.id as "Purchase ID",
    users.name as User,
    staff.name as Staff,
    locations.name as Location,
    reservations.cancelled,
    paytypes.name,
    reservations.attendance
FROM
    reservations as reservations 
    JOIN reservation_credits as rescredits ON reservations.id=rescredits.reservations_id
    JOIN meetings as meetings ON reservations.meetings_id=meetings.id
    JOIN users_credits as ucredits ON rescredits.users_credits_id=ucredits.id
    JOIN purchases as purchases ON ucredits.purchases_id=purchases.id
    JOIN purchase_items as pitems ON pitems.purchases_id = purchases.id
    JOIN payment_types as paytypes ON purchases.payment_types_id=paytypes.id
    LEFT OUTER JOIN dev.waitlist as waitlist ON reservations.id = waitlist.reservations_id
    JOIN dev.staff as staff ON staff.id = reservations.staff_id
    JOIN dev.locations as locations ON locations.id = reservations.locations_id
    JOIN dev.users as users ON users.id = reservations.users_id
WHERE
    reservations.deleted_at IS NULL AND
    pitems.buyed_type LIKE "%Combos%"
GROUP BY
    SUBSTRING(reservations.meeting_start, 1, 10),
    reservations.meeting_start,
    users.name,
    staff.name,
    locations.name,
    reservations.cancelled,
    paytypes.name,
    reservations.attendance,
    purchases.id
HAVING
    SUBSTRING(reservations.meeting_start, 1, 10) = "$date";
