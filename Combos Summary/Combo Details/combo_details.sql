SELECT 
    CASE
        WHEN $month = '00' THEN $year
        ELSE "${month:text} - $year"
    END as Date,
    combos.name as Combo,
    pitems.purchases_id as "Purchase ID",
    pitems.item_credits as "Credits",
    (pitems.item_price * pitems.item_credits) as "Value"
FROM 
    combos as combos
    JOIN purchase_items as pitems ON pitems.buyed_id = combos.id
    LEFT JOIN users_credits as ucredits ON ucredits.purchase_items_id = pitems.id
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
    combos.name = "$combo_name"