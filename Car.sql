# load The Data

SELECT * FROM card.`cars datasets 2025`;

# Remove Leading

UPDATE card.`cars datasets 2025`
SET `Company Names` = TRIM(`Company Names`),	
    `Cars Names` = TRIM(`Cars Names`),
    `Fuel Types` = TRIM(`Fuel Types`);

# Handle Missing Values

UPDATE card.`cars datasets 2025`
SET `Fuel Types` = COALESCE(`Fuel Types`, 'Unknown'),
    `Seats` = COALESCE(`Seats`, 0);

# Remove Duplicates (Keep Latest by Car Name)

USE card;
SET SQL_SAFE_UPDATES = 0;

UPDATE `cars datasets 2025`
SET 
    `Company Names` = TRIM(`Company Names`),
    `Cars Names` = TRIM(`Cars Names`),
    `Fuel Types` = TRIM(`Fuel Types`);

SET SQL_SAFE_UPDATES = 1;

-- 1️⃣ Select the database
USE card;

-- 2️⃣ Disable safe update mode for bulk updates
SET SQL_SAFE_UPDATES = 0;

-- 3️⃣ Data Cleaning Section --------------------

-- Trim spaces from important text columns
UPDATE `cars datasets 2025`
SET 
    `Company Names` = TRIM(`Company Names`),
    `Cars Names` = TRIM(`Cars Names`),
    `Fuel Types` = TRIM(`Fuel Types`),
    `Engines` = TRIM(`Engines`),
    `CC/Battery Capacity` = TRIM(`CC/Battery Capacity`),
    `HorsePower` = TRIM(`HorsePower`),
    `Total Speed` = TRIM(`Total Speed`),
    `Performance(0 - 100 )KM/H` = TRIM(`Performance(0 - 100 )KM/H`),
    `Cars Prices` = TRIM(`Cars Prices`),
    `Torque` = TRIM(`Torque`);

-- Standardize Fuel Types to lowercase
UPDATE `cars datasets 2025`
SET `Fuel Types` = LOWER(`Fuel Types`);

-- Add numeric columns for price and speed

ALTER TABLE `cars datasets 2025`
ADD COLUMN Price_Num DECIMAL(12,2),
ADD COLUMN Speed_Num INT;


SELECT * FROM card.`cars datasets 2025`;

-- Fill numeric columns

UPDATE `cars datasets 2025`
SET Price_Num = CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2))
WHERE `Cars Prices` NOT LIKE '%-%'  -- ignore ranges
  AND `Cars Prices` REGEXP '^[0-9\\$,]+$';  -- allow only numbers, commas, dollar signs

-- 4️⃣ Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;


-- Car names and companies
SELECT `Company Names`, `Cars Names`
FROM `cars datasets 2025`;

-- Petrol cars
SELECT `Cars Names`, `Fuel Types`   FROM `cars datasets 2025`
WHERE `Fuel Types` = 'petrol';

-- Cars with speed above 300 km/h

SELECT * FROM `cars datasets 2025`
WHERE Speed_Num > 300;

-- Sort cars by price (highest first)

SELECT `Company Names`, `Cars Names`, Price_Num
FROM `cars datasets 2025`
ORDER BY Price_Num DESC;

-- Count cars per company

SELECT `Company Names`, COUNT(*) AS total_cars
FROM `cars datasets 2025`
GROUP BY `Company Names`
ORDER BY total_cars DESC;

--  Average 0-100 acceleration time by fuel type

SELECT `Fuel Types`,
       AVG(CAST(REPLACE(`Performance(0 - 100 )KM/H`, ' sec', '') AS DECIMAL(4,2))) AS avg_accel
FROM `cars datasets 2025`
GROUP BY `Fuel Types`
ORDER BY avg_accel;

-- Maximum horsepower per fuel type
SELECT `Fuel Types`,
       MAX(CAST(REPLACE(`HorsePower`, ' hp', '') AS UNSIGNED)) AS max_hp
FROM `cars datasets 2025`
GROUP BY `Fuel Types`;

-- Cars with "GT" in the name

SELECT * FROM `cars datasets 2025`
WHERE `Cars Names` LIKE '%GT%';

--  Hybrid cars

SELECT * FROM `cars datasets 2025`
WHERE `Fuel Types` LIKE '%hybrid%';

-- Cars more expensive than average

SELECT *
FROM `cars datasets 2025`
WHERE Price_Num > (SELECT AVG(Price_Num) FROM `cars datasets 2025`);

-- Fastest car per fuel type

SELECT *
FROM `cars datasets 2025` c
WHERE Speed_Num = (
    SELECT MAX(Speed_Num)
    FROM `cars datasets 2025`
    WHERE `Fuel Types` = c.`Fuel Types`
);

-- Rank cars by speed

SELECT `Company Names`, `Cars Names`, Speed_Num,
       RANK() OVER (ORDER BY Speed_Num DESC) AS speed_rank
FROM `cars datasets 2025`;

-- Rank cars by price within each company

SELECT `Company Names`, `Cars Names`, Price_Num,
       DENSE_RANK() OVER (PARTITION BY `Company Names` ORDER BY Price_Num DESC) AS price_rank
FROM `cars datasets 2025`;

-- Cars with engine size > 4000 cc

SELECT *
FROM `cars datasets 2025`
WHERE CAST(REPLACE(REPLACE(`CC/Battery Capacity`, ' cc', ''), ',', '') AS UNSIGNED) > 4000;

-- Top 3 horsepower cars per fuel type

SELECT *
FROM (
    SELECT `Company Names`, `Cars Names`, `Fuel Types`, `HorsePower`,
           ROW_NUMBER() OVER (PARTITION BY `Fuel Types` ORDER BY CAST(REPLACE(`HorsePower`, ' hp', '') AS UNSIGNED) DESC) AS rn
    FROM `cars datasets 2025`
) ranked
WHERE rn <= 3;



-- Rank cars by price within each company (Dense Rank)
SELECT `Company Names`, `Cars Names`, `Cars Prices`,
       DENSE_RANK() OVER (
           PARTITION BY `Company Names`
           ORDER BY CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2)) DESC
       ) AS price_rank
FROM `cars datasets 2025`;

-- Top 3 fastest cars per fuel type
SELECT *
FROM (
    SELECT `Company Names`, `Cars Names`, `Fuel Types`, `Total Speed`,
           ROW_NUMBER() OVER (
               PARTITION BY `Fuel Types`
               ORDER BY CAST(REPLACE(`Total Speed`, ' km/h', '') AS UNSIGNED) DESC
           ) AS rn
    FROM `cars datasets 2025`
) ranked
WHERE rn <= 3;

--  Cars more expensive than their company’s average price

SELECT *
FROM `cars datasets 2025` c
WHERE CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2)) >
      (
          SELECT AVG(CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2)))
          FROM `cars datasets 2025`
          WHERE `Company Names` = c.`Company Names`
      );

--  Price gap (max - min) per fuel type

SELECT `Fuel Types`,
       MAX(CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2))) -
       MIN(CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2))) AS price_gap
FROM `cars datasets 2025`
GROUP BY `Fuel Types`;

-- Cars with above average horsepower and below average price

SELECT *
FROM `cars datasets 2025`
WHERE CAST(REPLACE(`HorsePower`, ' hp', '') AS UNSIGNED) >
      (SELECT AVG(CAST(REPLACE(`HorsePower`, ' hp', '') AS UNSIGNED)) FROM `cars datasets 2025`)
  AND CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2)) <
      (SELECT AVG(CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2))) FROM `cars datasets 2025`);

-- Cumulative price value (sorted by price)
SELECT `Company Names`, `Cars Names`, Price_Num,
       SUM(Price_Num) OVER (ORDER BY Price_Num DESC) AS cumulative_value
FROM (
    SELECT `Company Names`, `Cars Names`,
           CAST(REPLACE(REPLACE(`Cars Prices`, '$', ''), ',', '') AS DECIMAL(12,2)) AS Price_Num
    FROM `cars datasets 2025`
) t;

-- Fastest car per fuel type

SELECT *
FROM `cars datasets 2025` c
WHERE CAST(REPLACE(`Total Speed`, ' km/h', '') AS UNSIGNED) =
      (SELECT MAX(CAST(REPLACE(`Total Speed`, ' km/h', '') AS UNSIGNED))
       FROM `cars datasets 2025`
       WHERE `Fuel Types` = c.`Fuel Types`);

-- Rank cars by speed (with ties)
SELECT `Company Names`, `Cars Names`, `Total Speed`,
       RANK() OVER (ORDER BY CAST(REPLACE(`Total Speed`, ' km/h', '') AS UNSIGNED) DESC) AS speed_rank
FROM `cars datasets 2025`;

-- Top 3 horsepower cars per fuel type
SELECT *
FROM (
    SELECT `Company Names`, `Cars Names`, `Fuel Types`, `HorsePower`,
           ROW_NUMBER() OVER (
               PARTITION BY `Fuel Types`
               ORDER BY CAST(REPLACE(`HorsePower`, ' hp', '') AS UNSIGNED) DESC
           ) AS rn
    FROM `cars datasets 2025`
) ranked
WHERE rn <= 3;

# download out put

SELECT CAST(123.45 AS DECIMAL(10,2)) AS value
INTO OUTFILE '/var/lib/mysql-files/output.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


