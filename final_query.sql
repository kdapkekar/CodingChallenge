# 1st Query: What are the top 5 brands by receipts scanned for most recent month?
SELECT 
    t1.dateScanned, t2.name
FROM
    (SELECT 
        dateScanned, i.barcode AS barcode, i.I_id, r.r_id
    FROM
        receipts r
    LEFT JOIN itemlist i ON r.r_id = i.I_id
    WHERE
        dateScanned IN (SELECT 
                MAX(r1.dateScanned)
            FROM
                receipts r1)) AS t1
        JOIN
    (SELECT 
        barcode, name, topbrand
    FROM
        brands) AS t2 ON t1.barcode = t2.barcode
WHERE
    topBrand = TRUE
GROUP BY t2.name
ORDER BY COUNT(t2.name) DESC
LIMIT 5;
# 2nd query: How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

# 3rd Query: When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT 
    MAX(t1.Average) AS averageSpend, rewardsReceiptStatus
FROM
    (SELECT 
        AVG(totalSpent) AS average, rewardsReceiptStatus
    FROM
        receipts
    WHERE
        rewardsReceiptStatus = 'FINISHED' UNION ALL SELECT 
        AVG(totalSpent) AS average, rewardsReceiptStatus
    FROM
        receipts
    WHERE
        rewardsReceiptStatus = 'REJECTED') AS t1;

# 4th Query: When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT 
    MAX(t1.totalItems) AS totalItems, rewardsReceiptStatus
FROM
    (SELECT 
        SUM(purchasedItemCount) AS totalItems, rewardsReceiptStatus
    FROM
        receipts
    WHERE
        rewardsReceiptStatus = 'FINISHED' UNION ALL SELECT 
        SUM(purchasedItemCount) AS totalItems, rewardsReceiptStatus
    FROM
        receipts
    WHERE
        rewardsReceiptStatus = 'REJECTED') AS t1;

#5th Query: Which brand has the most spend among users who were created within the past 6 months?
SELECT 
    b.name AS brandname, t1.totalspent
FROM
    (SELECT 
        SUM(totalSpent) AS totalspent, barcode, u.u_id
    FROM
        receipts r
    JOIN itemlist i
    JOIN users u ON r.r_id = i.I_id AND r.userId = u.u_id
    WHERE
        createdDate >= CURDATE() - INTERVAL 6 MONTH
    GROUP BY barcode) AS t1
        INNER JOIN
    brands b ON t1.barcode = b.barcode
ORDER BY 2 DESC
LIMIT 1;

#6th Query: Which brand has the most transactions among users who were created within the past 6 months?
SELECT 
    b.name AS brandname, t1.transaction
FROM
    (SELECT 
        COUNT(r.pointsAwardedDate) AS transaction, i.barcode, u.u_id
    FROM
        receipts r
    JOIN itemlist i
    JOIN users u ON r.r_id = i.I_id AND r.userId = u.u_id
    WHERE
        createdDate >= CURDATE() - INTERVAL 6 MONTH
    GROUP BY barcode) AS t1
        JOIN
    brands b ON t1.barcode = b.barcode order by 2 desc limit 1;
