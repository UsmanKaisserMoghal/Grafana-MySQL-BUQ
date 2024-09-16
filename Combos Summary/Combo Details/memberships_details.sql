SELECT 
    CASE
        WHEN $month = '00' THEN $year
        ELSE "${month:text} - $year"
    END as Date,
    memberships.name as Membership,
    pitems.purchases_id as "Purchase ID",
    pitems.item_credits as "Credits",
    (pitems.item_price * pitems.item_credits) as "Value"
FROM 
    memberships as memberships
    JOIN users_memberships as umembers ON umembers.memberships_id = memberships.id
    LEFT JOIN purchase_items as pitems ON pitems.id = umembers.purchase_items_id
    LEFT JOIN users_credits as ucredits ON pitems.id = ucredits.purchase_items_id
WHERE
    SUBSTRING(pitems.created_at, 
        1, 
        CASE 
            WHEN $month = '00' THEN 4
            ELSE 7
        END
    ) = 
    CASE 
        WHEN $month = '00' THEN "$year"
        ELSE "$year-$month"
    END AND
    memberships.name = "$membership_name"