SELECT memberships.name as Membership, uprofiles.first_name as Profile, users.name as User_Name, uprofiles.email as Email, IF(DATE(umemberships.expiration_date) < CURDATE(), 'Expired', IF( umemberships.deleted_at is not null, 'Canceled' ,'Active')) as Status, memberships.price as Original_Price, (pitems.item_price_final / pitems.quantity) as Item_Price, pitems.quantity as Quantity, purchases.subtotal as Total_Price, memberships.created_at as Creation_Date, umemberships.expiration_date as Expiration_Date
FROM
    dev.memberships as memberships
JOIN
    dev.users_memberships as umemberships ON memberships.id = umemberships.memberships_id
JOIN
    dev.user_profiles as uprofiles ON umemberships.user_profiles_id = uprofiles.id
JOIN
    dev.users as users ON users.id = uprofiles.users_id
JOIN
    dev.purchases as purchases ON purchases.users_id = users.id
JOIN
    dev.purchase_items as pitems ON pitems.id = umemberships.purchase_items_id
WHERE
    umemberships.created_at BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                      AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')