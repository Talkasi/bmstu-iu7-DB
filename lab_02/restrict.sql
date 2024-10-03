-- 1. Инструкция SELECT, использующая предикат сравнения.
-- Найти имена всех участников мужского пола возраста меньше 30 лет.
SELECT id, name
FROM participant
WHERE sex = 'm' AND age < 30;

-- 2. Инструкция SELECT, использующая предикат BETWEEN.
-- Найти имена всех участников женского пола возраста от 20 до 30 лет.
SELECT id, name
FROM participant
WHERE sex = 'w' AND age BETWEEN 20 AND 30;

-- 3. Инструкция SELECT, использующая предикат LIKE.
-- Получить список компаний-организаторов, почта которых заканчивается на ".com".
SELECT id, company_name
FROM organizer
WHERE email LIKE '%.com';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Получить названия всех турниров, проводимых с '2000-01-01', приз за первое место в которых больше 1000
SELECT id, name
FROM chess_tournament
WHERE id_prizes IN (SELECT id
                    FROM prize_info
                    WHERE first_place > 1000)
                AND date > '2000-01-01';

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- Найти все турниры, у которых за третье место нет денежного приза.
SELECT id_prizes, name
FROM chess_tournament
WHERE EXISTS (SELECT id
              FROM prize_info
              WHERE third_place = 0);

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > ALL ( SELECT UnitPrice
 FROM Products
 WHERE CategoryID = 2 )

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
SELECT AVG(TotalPrice) AS 'Actual AVG',
 SUM(TotalPrice) / COUNT(OrderID) AS 'Calc AVG'
FROM ( SELECT OrderID, SUM(UnitPrice*Quantity*(1-Discount)) AS TotalPrice
 FROM [Order Details]
 GROUP BY OrderID
) AS TotOrders 

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
SELECT ProductID, UnitPrice,
 ( SELECT AVG(UnitPrice)
 FROM [Order Details]
 WHERE [Order Details].ProductID = Products.ProductID) AS AvgPrice,
 ( SELECT MIN(UnitPrice)
 FROM [Order Details]
 WHERE [Order Details].ProductID = Products.ProductID ) AS MaxPrice,
 ProductName
FROM Products
WHERE CategoryID = 1

-- 9. Инструкция SELECT, использующая простое выражение CASE.
SELECT CompanyName, OrderID,
 CASE YEAR(OrderDate)
 WHEN YEAR(Getdate()) THEN 'This Year'
 WHEN YEAR(GetDate()) - 1 THEN 'Last year'
 ELSE CAST(DATEDIFF(year, OrderDate, Getdate()) AS varchar(5)) + ' years ago'
 END AS 'When'
FROM Orders JOIN Customers ON Orders.CustomerID = Customers.CustomerID 

-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
SELECT ProductName,
 CASE
 WHEN UnitPrice < 10 THEN 'Inexpensive'
 WHEN UnitPrice < 50 THEN 'Fair'
 WHEN UNitPrice < 100 THEN 'Expensive'
 ELSE 'Very Expensive'
 END AS Price
FROM products 

-- 11. Создание новой временной локальной таблицы из результирующего набора 
-- данных инструкции SELECT.
SELECT ProductID, SUM(Quantity) AS SQ,
 CAST(SUM(UnitPrice*Quantity*(1.0-Discount))AS money) AS SR
INTO #BestSelling
FROM [Order Details]
WHERE ProductID IS NOT NULL
GROUP BY productID

-- 12. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM.
SELECT 'By units' AS Criteria, ProductName as 'Best Selling'
FROM Products P JOIN ( SELECT TOP 1 ProductID, SUM(Quantity) AS SQ
 FROM [Order Details]
 GROUP BY productID
 ORDER BY SQ DESC ) AS OD ON OD.ProductID = P.ProductID
UNION
SELECT 'By revenue' AS Criteria, ProductName as 'Best Selling'
FROM Products P JOIN ( SELECT TOP 1 ProductID,
 SUM(UnitPrice*Quantity*(1-Discount)) AS SR
 FROM [Order Details]
 GROUP BY ProductID
 ORDER BY SR DESC) AS OD ON OD.ProductID = P.ProductID 

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем
-- вложенности 3.
SELECT 'By units' AS Criteria, ProductName as 'Best Selling'
FROM Products
WHERE ProductID = ( SELECT ProductID
 FROM [Order Details]
 GROUP BY ProductID
 HAVING SUM(Quantity) = ( SELECT MAX(SQ)
 FROM ( SELECT SUM(Quantity) as SQ
 FROM [Order Details]
 GROUP BY ProductID
 ) AS OD
 )
 )

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING.
-- Для каждого заказанного продукта категории 1 получить его цену, среднюю цену,
-- минимальную цену и название продукта
SELECT P.ProductID, P.UnitPrice, P.ProductName
 AVG(OD.UnitPrice) AS AvgPrice,
 MIN(OD.UnitPrice) AS MinPrice,
FROM Products P LEFT OUTER JOIN [Order Details] OD ON OD.ProductID = P.ProductID
WHERE CategoryID = 1
GROUP BY P.productID, P.UnitPrice, P.ProductName

