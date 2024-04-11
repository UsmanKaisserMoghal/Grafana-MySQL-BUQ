SELECT 
    Package2,
    COUNT(*) AS Total_Purchases,
    AVG(Total_Price) AS Avg_Price,
    SUM(Package_Credits) AS Total_Credits,
    SUM(CASE WHEN Package_Used = 0 THEN Credits_Price ELSE 0 END) AS Unused_Credits_Price,
    SUM(Credits_Price) AS Total_Credits_Price,
    SUM(CASE WHEN Package_Used = 0 THEN Purchased_Credits ELSE 0 END) AS Unused_Credits
FROM (
    SELECT 
        uprofiles.first_name AS User,
        uprofiles.email AS Email,
        combos.name AS Package2,
        ucredits.used AS Package_Used,
        IF(DATE(ucredits.expiration_date) < CURDATE(), 'Expired', IF(ucredits.deleted_at IS NOT NULL, 'Canceled', 'Active')) AS Package_Status,
        combos.credits AS Package_Credits,
        combos.price AS Package_Price,
        (pitems.item_price_final / (pitems.quantity * combos.credits)) AS Credits_Price,
        pitems.quantity AS Quantity,
        purchases.subtotal AS Total_Price,
        pitems.item_credits AS Purchased_Credits,
        locations.name AS Location,
        ucredits.created_at AS Date,
        ucredits.expiration_date AS Expiry
    FROM
        dev.credits AS credits
    JOIN
        dev.users_credits AS ucredits ON credits.id = ucredits.credits_id
    JOIN
        dev.combos AS combos ON combos.credits_id = credits.id
    JOIN
        dev.user_profiles AS uprofiles ON ucredits.user_profiles_id = uprofiles.id
    JOIN
        dev.purchase_items AS pitems ON pitems.credits_id = credits.id
    JOIN
        dev.purchases AS purchases ON purchases.id = pitems.purchases_id
    JOIN
        dev.locations AS locations ON locations.id = pitems.locations_id
    WHERE
        purchases.brands_id IN ($brands) AND
        combos.status IN ($packagestatus) AND
        ucredits.created_at BETWEEN CONVERT_TZ(FROM_UNIXTIME($__unixEpochFrom()), '+00:00', '-05:00')
                                AND CONVERT_TZ(FROM_UNIXTIME($__unixEpochTo()), '+00:00', '-05:00')
    LIMIT $limit
) AS subquery
GROUP BY
    Package2;
