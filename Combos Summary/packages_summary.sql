SELECT 
    CASE
        WHEN $month = '00' THEN $year
        ELSE "${month:text} - $year"
    END as Date,
    combos.name as Combo,
    COUNT(pitems.item_credits) as "Starting Count",
    SUM(pitems.item_price) as "Starting Value",
    SUM(ucredits.used) as "Remaining Count",
    SUM(CASE WHEN ucredits.used = 1 THEN pitems.item_price ELSE 0 END) as "Remaining Value"
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
    END
GROUP BY
    combos.name;