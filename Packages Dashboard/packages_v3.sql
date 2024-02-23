SELECT uprofiles.first_name as User, uprofiles.email as Email, combos.name as Package2, ucredits.used as Package_Used, IF(DATE(ucredits.expiration_date) < CURDATE(), 'Expired', IF( ucredits.deleted_at is not null, 'Canceled' ,'Active')) as Package_Status, combos.credits as Package_Credits, combos.price as Package_Price, (pitems.item_price_final / (pitems.quantity * combos.credits)) as Credits_Price, pitems.quantity as Quantity, purchases.subtotal as Total_Price, pitems.item_credits as Purchased_Credits, locations.name as Location, ucredits.created_at as Date, ucredits.expiration_date as Expiry
FROM
    dev.credits as credits
JOIN
    dev.users_credits as ucredits ON credits.id = ucredits.credits_id
JOIN
    dev.combos as combos ON combos.credits_id = credits.id
JOIN
    dev.user_profiles as uprofiles ON ucredits.user_profiles_id = uprofiles.id
JOIN
    dev.purchase_items as pitems ON pitems.credits_id = credits.id
JOIN
    dev.purchases as purchases ON purchases.id = pitems.purchases_id
JOIN
    dev.locations as locations ON locations.id = pitems.locations_id
WHERE
    ucredits.created_at BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                      AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')
LIMIT 500