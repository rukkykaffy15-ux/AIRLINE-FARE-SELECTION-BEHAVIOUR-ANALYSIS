SELECT TOP (1000) [Month_of_date]
      ,[Day_of_date]
      ,[channelGrouping]
      ,[TripType]
      ,[deviceCategory]
      ,[Avg_Price_OPTION1]
      ,[Avg_Price_OPTION2]
      ,[Avg_Price_OPTION3]
      ,[Avg_Price_Clean_First_Fare]
      ,[Avg_Price_Clean_FareSelected]
      ,[Travellers]
  FROM [car sales].[dbo].[Airline Fare]


  use [car sales]

  --Data Cleaning
  --CHECKING AND HANDLING DUPLICATE VALUES

  SELECT *
  FROM AIRLINE_FARE
  WHERE Month_of_date IS NULL
  AND Day_of_date IS NULL
  AND channelGrouping IS NULL
  AND TripType IS NULL
  AND deviceCategory IS NULL
  AND Avg_Price_OPTION1 IS NULL
  AND Avg_Price_OPTION2	IS NULL
  AND Avg_Price_OPTION3	IS NULL
  AND Avg_Price_Clean_First_Fare IS NULL
  AND Avg_Price_Clean_FareSelected IS NULL
  AND Travellers IS NULL

  --DELETING DUPLICATED NULL VALUES

   DELETE FROM AIRLINE_FARE
  WHERE Month_of_date IS NULL
  AND Day_of_date IS NULL
  AND channelGrouping IS NULL
  AND TripType IS NULL
  AND deviceCategory IS NULL
  AND Avg_Price_OPTION1 IS NULL
  AND Avg_Price_OPTION2	IS NULL
  AND Avg_Price_OPTION3	IS NULL
  AND Avg_Price_Clean_First_Fare IS NULL
  AND Avg_Price_Clean_FareSelected IS NULL
  AND Travellers IS NULL


--CHECKING FOR DUPLICATE NON-NULL VALUES
  SELECT Month_of_date ,count (*) as duplicateno                           
 , cast (Day_of_date as nvarchar) Day_of_date
  ,channelGrouping 
  , TripType 
  , deviceCategory 
  , Avg_Price_OPTION1 
  , Avg_Price_OPTION2	
  , Avg_Price_OPTION3	
 , Avg_Price_Clean_First_Fare 
  , Avg_Price_Clean_FareSelected 
  , Travellers 
  FROM Airline_Fare 
  group by Month_of_date                             
 ,  cast (Day_of_date as nvarchar)  
  ,channelGrouping 
  , TripType 
  , deviceCategory 
  , Avg_Price_OPTION1 
  , Avg_Price_OPTION2	
  , Avg_Price_OPTION3	
 , Avg_Price_Clean_First_Fare 
  , Avg_Price_Clean_FareSelected 
  , Travellers 
  having COUNT(*) >1

  ---DELETING DUPLICATE VALUES  

  WITH CTE AS (SELECT 
  ROW_NUMBER() OVER( PARTITION BY Month_of_date  ,  cast (Day_of_date as nvarchar) ,channelGrouping , TripType , deviceCategory ,
  Avg_Price_OPTION1  , Avg_Price_OPTION2	
  , Avg_Price_OPTION3	
 , Avg_Price_Clean_First_Fare 
  , Avg_Price_Clean_FareSelected 
  , Travellers ORDER BY Month_of_date) AS RWN,*
  FROM Airline_Fare)
DELETE
  FROM CTE
  WHERE RWN > 1

  --CHECKING FOR NULL VALUES IN OPTIONS COLUMMS 
  SELECT*
  FROM Airline_Fare
  WHERE  Avg_Price_OPTION1 IS NULL--NONE

  SELECT*
  FROM Airline_Fare
  WHERE  Avg_Price_OPTION2 IS NULL --64 

  
 --CHECKING FOR NULL VALUES IN COLUMMS (299 ROWS)
  SELECT*
  FROM Airline_Fare
  WHERE  Avg_Price_OPTION3 IS NULL

--USING THE MEDIAN VALUE TO CALCULATE OPTION 3 THAT ARE NULL

WITH MEDIANCTE AS (SELECT PERCENTILE_CONT(0.5)WITHIN GROUP (ORDER BY AVG_PRICE_OPTION3 )OVER () AS MEDIAN
 FROM Airline_Fare
 )
UPDATE A 
SET A.Avg_Price_OPTION3 = m.Median
FROM Airline_Fare AS A
CROSS JOIN MedianCTE m
WHERE A.Avg_Price_OPTION3 IS NULL;
 

 --USING THE MEDIAN VALUE TO CALCULATE OPTION 2 NULL

WITH MEDIANCTE AS (SELECT PERCENTILE_CONT(0.5)WITHIN GROUP (ORDER BY AVG_PRICE_OPTION2 )OVER () AS MEDIAN
 FROM Airline_Fare
 )
UPDATE A 
SET A.Avg_Price_OPTION2 = m.Median
FROM Airline_Fare AS A
CROSS JOIN MedianCTE m
WHERE A.Avg_Price_OPTION2 IS NULL;



  
  --changing month date to date
 alter table Airline_Fare
  add Date_M DATE

  UPDATE Airline_Fare
  SET Date_M = CONVERT(DATE,CONCAT('2024',' ',month_of_date ,' ', day_of_date))

  select DATE_M
  from airline_fare

  ---grouping travellers
  select min(travellers)
  from Airline_Fare

  select max(travellers)
  from Airline_Fare

 ALTER TABLE Airline_fare
ADD Traveller_Group VARCHAR(50)

UPDATE Airline_fare
SET  =
   Traveller_Group CASE 
        WHEN Travellers = 1 THEN 'Solo'
        WHEN Travellers = 2 THEN 'Couple'
        WHEN Travellers BETWEEN 3 AND 5 THEN 'Small Group'
        ELSE 'Large Group'
    END

SELECT Traveller_Group
FROM Airline_fare

SELECT *
FROM Airline_fare


  ---ANALYSIS
  ---MONTHLYTREND
SELECT MONTH(DATE_M)AS MONTH,SUM(Avg_Price_Clean_FareSelected) AS PRICESELECTED
FROM Airline_Fare
GROUP BY MONTH(DATE_M)
ORDER BY PRICESELECTED DESC

SELECT MONTH(DATE_M)AS MONTH,COUNT(*) AS PRICESELECTED
FROM Airline_Fare
GROUP BY MONTH(DATE_M)
ORDER BY PRICESELECTED DESC

--price changes per month
SELECT
MONTH(DATE_M)AS MONTH,
avg(Avg_Price_Clean_First_Fare) AS firstfare
,avg(Avg_Price_OPTION1) AS firstoption,avg(Avg_Price_OPTION2) AS secondoption,avg(Avg_Price_OPTION3) AS thirdoption
FROM Airline_Fare
GROUP BY MONTH(DATE_M)


--PRICE ANALYSIS(DEFAULT FARE AND OPTION 1 ARE SIMILAR)
SELECT COUNT(*) TOTALBOOKINGS, AVG(Avg_Price_OPTION3) EXPENSIVE
,AVG(Avg_Price_OPTION2) MID
,AVG(Avg_Price_OPTION1)CHEAPEST
,AVG(Avg_Price_Clean_FareSelected) AS SELECTEDFARE
,AVG(Avg_Price_Clean_First_Fare) DEFAULTFARE
FROM Airline_Fare


----COUNT OF MOST SELECTED OPTION FARE ON THE WEBSITE
SELECT count(*) countofselection,
CASE WHEN
 Avg_Price_Clean_First_Fare= Avg_Price_Clean_FareSelected THEN 'default fare selected'
 when Avg_Price_Clean_FareSelected = Avg_Price_OPTION2 THEN 'middle-tier fare selected'
when Avg_Price_Clean_FareSelected = Avg_Price_OPTION3 THEN'expensive fare selected'
ELSE 'no fare on option list'
END fareselection
from Airline_Fare
group by CASE WHEN
 Avg_Price_Clean_First_Fare= Avg_Price_Clean_FareSelected THEN 'default fare selected'
 when Avg_Price_Clean_FareSelected = Avg_Price_OPTION2 THEN 'middle-tier fare selected'
when Avg_Price_Clean_FareSelected = Avg_Price_OPTION3 THEN'expensive fare selected'
ELSE 'no fare on option list'
END 
order by count(*)



  ---- PERCENTAGE OF SELECTED OPTION FARE ON THE WEBSITE
with selectioncte as(SELECT count(*) countofselection,
CASE WHEN
 Avg_Price_Clean_First_Fare= Avg_Price_Clean_FareSelected THEN 'default fare selected'
 when Avg_Price_Clean_FareSelected = Avg_Price_OPTION2 THEN 'middle-tier fare selected'
when Avg_Price_Clean_FareSelected = Avg_Price_OPTION3 THEN'expensive fare selected'
ELSE 'no fare on option list'
END fareselection
from Airline_Fare
group by CASE WHEN
 Avg_Price_Clean_First_Fare= Avg_Price_Clean_FareSelected THEN 'default fare selected'
 when Avg_Price_Clean_FareSelected = Avg_Price_OPTION2 THEN 'middle-tier fare selected'
when Avg_Price_Clean_FareSelected = Avg_Price_OPTION3 THEN'expensive fare selected'
ELSE 'no fare on option list'
END 
)
SELECT fareselection, countofselection,
  CONVERT(DECIMAL(10, 2),countofselection * 100.0 / SUM(countofselection) OVER ()) AS Percentage
  FROM selectioncte ---44% picked first option given


  --DEVICE CATEGORY ANALYSIS
---WHAT DEVICE CATEGORY HAS HIGHER PRICES

SELECT DEVICECATEGORY,AVG(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY DEVICECATEGORY
ORDER BY PRICEFARE DESC
---DEVICE CATEGORY BOOKINGS
SELECT DEVICECATEGORY,SUM(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY DEVICECATEGORY
ORDER BY PRICEFARE DESC
---CHECKING FOR MOST SELECTED OPTIONS PER DIVICECATEGORY
SELECT 
DEVICECATEGORY,
SUM(CASE WHEN Avg_Price_Clean_First_Fare =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) AS DEFAULTFARE,
SUM(CASE WHEN Avg_Price_OPTION1 =Avg_Price_Clean_FareSelected AND Avg_Price_Clean_FareSelected <> Avg_Price_Clean_First_Fare THEN 1
            ELSE 0  END) AS CHEAPFARE,
SUM(CASE WHEN Avg_Price_OPTION2 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) MIDDLETIERFARE,
SUM(CASE WHEN Avg_Price_OPTION3 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END)EXPENSIVEFARE

,SUM(CASE WHEN Avg_Price_Clean_FareSelected NOT IN (Avg_Price_OPTION1,Avg_Price_OPTION2,Avg_Price_OPTION3,Avg_Price_Clean_First_Fare)
 THEN 1 ELSE 0 END) AS NONEOFTHEOPTIONS
FROM AIRLINE_FARE
GROUP BY DEVICECATEGORY

--TRIPTYPE ANNALYSIS
---WHAT TRIPTYPE HAS HIGHER PRICES

SELECT TRIPTYPE,AVG(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY TRIPTYPE
ORDER BY PRICEFARE DESC
-- TRIPTYPE CATEGORY BOOKINGS
SELECT TRIPTYPE,SUM(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY TRIPTYPE
ORDER BY PRICEFARE DESC
---CHECKING FOR MOST SELECTED OPTIONS PER TRIPTYPE 
SELECT TRIPTYPE,
SUM(CASE WHEN Avg_Price_Clean_First_Fare =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) AS DEFAULTFARE,
SUM(CASE WHEN Avg_Price_OPTION1 =Avg_Price_Clean_FareSelected AND Avg_Price_Clean_FareSelected <> Avg_Price_Clean_First_Fare THEN 1
            ELSE 0  END) AS CHEAPFARE,
SUM(CASE WHEN Avg_Price_OPTION2 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) MIDDLETIERFARE,
SUM(CASE WHEN Avg_Price_OPTION3 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END)EXPENSIVEFARE

,SUM(CASE WHEN Avg_Price_Clean_FareSelected NOT IN (Avg_Price_OPTION1,Avg_Price_OPTION2,Avg_Price_OPTION3,Avg_Price_Clean_First_Fare)
 THEN 1 ELSE 0 END) AS NONEOFTHEOPTIONS
FROM AIRLINE_FARE
GROUP BY TripType
 
 

 --CHANNELGROUPING ANNALYSIS
---WHAT CHANNELGROUPING HAS HIGHER PRICES
SELECT CHANNELGROUPING,AVG(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY CHANNELGROUPING
ORDER BY PRICEFARE DESC
--- CHANNELGROUPING CATEGORY BOOKINGS
SELECT CHANNELGROUPING,SUM(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY CHANNELGROUPING
ORDER BY PRICEFARE DESC
---CHECKING FOR MOST SELECTED OPTIONS PER  CHANNELGROUPING 
SELECT CHANNELGROUPING,
SUM(CASE WHEN Avg_Price_Clean_First_Fare =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) AS DEFAULTOPTION,
SUM(CASE WHEN Avg_Price_OPTION1 =Avg_Price_Clean_FareSelected AND Avg_Price_Clean_FareSelected <> Avg_Price_Clean_First_Fare THEN 1
            ELSE 0  END) AS CHEAPFARE,
SUM(CASE WHEN Avg_Price_OPTION2 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) MIDDLETIERFARE,
SUM(CASE WHEN Avg_Price_OPTION3 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END)EXPENSIVEFARE
,SUM(CASE WHEN Avg_Price_Clean_FareSelected NOT IN (Avg_Price_OPTION1,Avg_Price_OPTION2,Avg_Price_OPTION3,Avg_Price_Clean_First_Fare)
 THEN 1 ELSE 0 END) AS NONEOFTHEOPTIONS
FROM AIRLINE_FARE
GROUP BY CHANNELGROUPING

 ---Traveller_Group ANNALYSIS
---WHAT Traveller_Group HAS HIGHER PRICES
SELECT Traveller_Group,AVG(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY Traveller_Group
ORDER BY PRICEFARE DESC
--- Traveller_Group CATEGORY BOOKINGS
SELECT Traveller_Group,SUM(Avg_Price_Clean_FareSelected)AS PRICEFARE
FROM AIRLINE_FARE
GROUP BY Traveller_Group
ORDER BY PRICEFARE DESC
---CHECKING FOR MOST SELECTED OPTIONS PER  Traveller_Group 
SELECT Traveller_Group,
SUM(CASE WHEN Avg_Price_Clean_First_Fare =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) AS DEFAULTFARE,
SUM(CASE WHEN Avg_Price_OPTION1 =Avg_Price_Clean_FareSelected AND Avg_Price_Clean_FareSelected <> Avg_Price_Clean_First_Fare THEN 1
            ELSE 0  END) AS CHEAPFARE,
SUM(CASE WHEN Avg_Price_OPTION2 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END) MIDDLETIERFARE,
SUM(CASE WHEN Avg_Price_OPTION3 =Avg_Price_Clean_FareSelected THEN 1 ELSE 0 END)EXPENSIVEFARE

,SUM(CASE WHEN Avg_Price_Clean_FareSelected NOT IN (Avg_Price_OPTION1,Avg_Price_OPTION2,Avg_Price_OPTION3,Avg_Price_Clean_First_Fare)
 THEN 1 ELSE 0 END) AS NONEOFTHEOPTIONS
FROM AIRLINE_FARE
GROUP BY Traveller_Group

  --PERCENTAGE INCREASE OF FARE CUSTUMER ARE WILLING TO PAY COMPARED TO THE FIRST FEE THEY WERE GIVEN
 SELECT 
  AVG(Avg_Price_Clean_First_Fare) AS Avg_First_Fare,
  AVG(Avg_Price_Clean_FareSelected) AS Avg_Selected_Fare,
  AVG(Avg_Price_Clean_FareSelected - Avg_Price_Clean_First_Fare) AS Fare_Uplift,
  ROUND(
    AVG((Avg_Price_Clean_FareSelected - Avg_Price_Clean_First_Fare) * 100.0 / NULLIF(Avg_Price_Clean_First_Fare, 0)), 
    2
  ) AS Fare_Uplift_Percent
FROM Airline_Fare

--NO OF PEOPLE THAT ARE WILLING TO UPLIFT THERE PAYMENT TO OPTION 2 AND 3 ---43% WERE WILLING TO UPLIFT
SELECT COUNT(*)TOTALBOOKINGS,SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END) AS UPLIFT,
SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END)*100/COUNT(*)  AS PERCENTAGEWILLINGTOUPLIFT
FROM Airline_Fare




----BY channel group

SELECT channelGrouping,
COUNT(*)TOTALBOOKINGS,SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END) AS UPLIFT,
SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END)*100/COUNT(*) AS PERCENTAGEWILLINGTOUPLIFT
FROM Airline_Fare
GROUP BY channelGrouping



----by triptype


--PERCENTAGE UPGRADE
SELECT TripType,
COUNT(*)TOTALBOOKINGS,SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END) AS UPLIFT,
SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END)*100/COUNT(*) AS PERCENTAGEWILLINGTOUPLIFT
FROM Airline_Fare
GROUP BY TripType

---by devicecategory

--PERCENTAGE UPGRADE
SELECT deviceCategory,
COUNT(*)TOTALBOOKINGS,SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END) AS UPLIFT,
SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END)*100/COUNT(*) AS PERCENTAGEWILLINGTOUPLIFT
FROM Airline_Fare
GROUP BY deviceCategory


---by TRAVELLERS
---UPGRADE PERCENTAGE
SELECT TRAVELLER_GROUP,
COUNT(*)TOTALBOOKINGS,SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END) AS UPLIFT,
SUM(CASE WHEN Avg_Price_Clean_FareSelected IN ( Avg_Price_OPTION2 , Avg_Price_OPTION3 )THEN 1 ELSE 0
END)*100/COUNT(*) AS PERCENTAGEWILLINGTOUPLIFT
FROM Airline_Fare
GROUP BY TRAVELLER_GROUP




