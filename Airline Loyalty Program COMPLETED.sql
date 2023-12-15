# created schema
CREATE SCHEMA airline_loyalty;

# use of schema
USE airline_loyalty;

# I overviewed data in excel, data structure overall is fine
# IN EXCEL ALL COLUMN VALUES WHICH HAD SPACE in between of title was replaced by underscore

# using drop table function in any case
DROP TABLE IF EXISTS customer_flight_activity;

# created table 1
CREATE TABLE customer_flight_activity(
Loyalty_Number INT NOT NULL,# added underscore in order to not to have error
Year INT,
Month INT NOT NULL,
Flights_Booked INT NOT NULL,
Flights_with_Companions INT NOT NULL,
Total_Flights INT NOT NULL,
Distance INT NOT NULL,
Points_Accumulated INT NOT NULL,
Points_Redeemed INT NOT NULL,
Dollar_Cost_Points_Redeemed INT NOT NULL);

# check if table is created and data is well structured
SELECT * FROM customer_flight_activity;

# find variable for secure_file in order to import
show variables like'secure_file_priv';

# imported data from first table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Airline Loyalty Program/Customer Flight Activity.csv'
INTO TABLE customer_flight_activity
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# re-check data if it is imported
SELECT * FROM customer_flight_activity;
# everything seems okay so far, let's continue :)

# repeat the process for 2nd table

# using drop table function in any case
DROP TABLE IF EXISTS customer_loyalty_history;

# created table 2
CREATE TABLE customer_loyalty_history(
Loyalty_Number INT NOT NULL,
Country VARCHAR(60),
Province VARCHAR(60),
City VARCHAR(60),
Postal_Code VARCHAR(60),
Gender VARCHAR(10),
Education VARCHAR(60),
Salary INT NOT NULL,
Marital_Status VARCHAR(30),
Loyalty_Card VARCHAR(20),
CLV INT NOT NULL,
Enrollment_Type VARCHAR(60),
Enrollment_Year INT NOT NULL,
Enrollment_Month INT NOT NULL,
Cancellation_Year INT NOT NULL,
Cancellation_Month INT NOT NULL,
PRIMARY KEY(Loyalty_Number));

# check if table is created and data is well structured
SELECT * FROM customer_loyalty_history;

# find variable for secure_file in order to import
show variables like'secure_file_priv';

# imported data from first table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Airline Loyalty Program/Customer Loyalty History.csv'
INTO TABLE customer_loyalty_history
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

# re-check data if it is imported
SELECT * FROM customer_loyalty_history;


# TIME FOR ANALYSIS

# DEMOGRAPHIC ANALYSIS

# QUESTIONS WE WANT TO GET ANSWERS:

# 1. What is the distribution of customers by gender, education level, and marital status?
# 2. How does the distribution of loyalty card holders vary by country, province, or city?

# Total number of male/female with respective percentage
SELECT
	Gender,
    COUNT(*) as Total,
	ROUND((COUNT(*) * 100 / (SELECT COUNT(*) FROM Customer_Loyalty_History)),1) AS Percentage_Total
FROM
	customer_loyalty_history
GROUP BY Gender;
# LITTLE SUMMARY: Gender percentage are almost the same liek 50/50

# Education distribution with percentages
SELECT
	Education,
    COUNT(*) as Total,
	ROUND((COUNT(*) * 100 / (SELECT COUNT(*) FROM Customer_Loyalty_History)),1) AS Percentage_Total
FROM
	customer_loyalty_history
GROUP BY Education
ORDER BY  Total DESC, Percentage_Total DESC;
# LITTLE SUMMARY: Bachelor and College degrees are most spreaded education levels

# Marital Status distribution
SELECT
	Marital_Status,
    COUNT(*) as Total,
	ROUND((COUNT(*) * 100 / (SELECT COUNT(*) FROM Customer_Loyalty_History)),1) AS Percentage_Total
FROM
	customer_loyalty_history
GROUP BY Marital_Status;
# LITTLE SUMMARY: 58% of the members are Married, 26% Single and rest Divorced

# Distribution by location, including country province and city.
SELECT 
	Country,
	Province,
	City,
	COUNT(*) as Amount
FROM
	customer_loyalty_history
GROUP BY Country, Province, City
ORDER BY Amount DESC;
# LITTLE SUMMARY: provinces people are coming from mostly are following: Ontario, British Columbia, Quebe and cities respectively: Toronto, Vancouver, Montreal


# The percentage of these 3 Province/City compared to rest
WITH CTEb as (
WITH CTEa as (SELECT 
	Country,
	Province,
	City,
	COUNT(*) as Amount
FROM
	customer_loyalty_history
GROUP BY Country, Province, City
ORDER BY Amount DESC)
SELECT 
	*,
    ROW_NUMBER() OVER() as rw_nmb
FROM
	CTEa)
SELECT
	SUM(CASE WHEN rw_nmb <= 3 THEN Amount ELSE 0 END) as top_3,
    SUM(CASE WHEN rw_nmb > 3 THEN Amount ELSE 0 END) as rest,
    ROUND(SUM(CASE WHEN rw_nmb <= 3 THEN Amount ELSE 0 END) / (SUM(CASE WHEN rw_nmb <= 3 THEN Amount ELSE 0 END) + SUM(CASE WHEN rw_nmb > 3 THEN Amount ELSE 0 END)),2) AS prct_top3
FROM
	CTEb;
# LITTLE SUMMARY: 48 % of the loyal people are coming from Ontario, British Columbia / Toronto, Vancouver, Montreal


# Overall stats about membership days, type, points accumulated, redeemed and dolars redeemed
WITH CTE AS(
SELECT 
    Loyalty_Number,
    CONCAT(Enrollment_Year, '-', LPAD(Enrollment_Month, 2, '0'), '-01') AS Enrollment_Date,
    DATEDIFF(
        IFNULL(
            CONCAT(Cancellation_Year, '-', LPAD(Cancellation_Month, 2, '0'), '-01'), 
            CURDATE()
        ), 
        CONCAT(Enrollment_Year, '-', LPAD(Enrollment_Month, 2, '0'), '-01')
    ) AS Membership_Duration_days_cancelled,
    DATEDIFF(CURDATE(), CONCAT(Enrollment_Year, '-', LPAD(Enrollment_Month, 2, '0'), '-01')) as Membership_Duration_days_with_not_cancelled,
    Enrollment_Type as Membership_Type
FROM 
    customer_loyalty_history)
SELECT
	CTE.*,
    customer_flight_activity.Points_Accumulated,
    customer_flight_activity.Points_Redeemed,
    customer_flight_activity.Dollar_Cost_Points_Redeemed
FROM
	CTE
INNER JOIN customer_flight_activity on customer_flight_activity.Loyalty_Number = CTE.Loyalty_Number
GROUP BY 
	CTE.Loyalty_Number
ORDER BY 
	#CTE.Membership_Duration_days_with_not_cancelled DESC,
    customer_flight_activity.Points_Accumulated DESC,
    customer_flight_activity.points_Redeemed DESC,
    customer_flight_activity.Dollar_Cost_Points_Redeemed DESC;

# ENROLLMENT AND CANCELLATION TRENDS

# QUESTIONS WE WANT TO GET ANSWERS:
# 1.What are the enrollment trends over the years? 
# 2.Any noticeable patterns in enrollment or cancellations by month or year?
# 3.Are there specific regions or countries showing higher cancellation rates?

# 1. What are the enrollment trends over the years? Any noticeable patterns in enrollment or cancellations by month or year?
SELECT
	Enrollment_Year,
    COUNT(*) as Number_of_enroll
FROM
	customer_loyalty_history
GROUP BY
	Enrollment_Year
ORDER BY Enrollment_Year ASC;
# LITTLE SUMMARY: Enrollment numbers positively increase slowly. in 6 years period it almost doubled the amount of enrollments

# 2.Any noticeable patterns in enrollment or cancellations by month or year?
SELECT
	Cancellation_Year,
    Cancellation_Month,
    COUNT(*) as number_of_cancel
FROM
	customer_loyalty_history
GROUP BY
	Cancellation_Year,
    Cancellation_Month
ORDER BY Cancellation_Year ASC, Cancellation_Month ASC
LIMIT 999999999
OFFSET 1;
# LITTLE SUMMARY: The flight cancellation trend is rising. from 2014 to 2018 it tendency showed 6x times.

# 3.Are there specific regions or countries showing higher cancellation rates?
SELECT
	Province,
    City,
    COUNT(*) as number_of_cancel
FROM
	customer_loyalty_history
GROUP BY
	Province,
    City
ORDER BY number_of_cancel DESC;
# LITTLE SUMMARY: Provinces: Ontario, British Columbia, Quebec and Cities respectively Toronto, Vancouver and Montreal has the highest cancellation numbers. All of them above 2000 cancelattions, while first largest number after Montreal (2059) is Winnipeg (658).

# FLIGHT ACTIVITY ANALYSIS

# QUESTIONS WE WANT TO GET ANSWERS:
# 1. What is the average number of flights booked per loyalty number?
# 2. How do points accumulated and points redeemed vary with the number of flights booked or distance traveled?
# 3. Is there a correlation between the dollar cost of points redeemed and loyalty cardholder's CLV or salary?


# 1. What is the average number of flights booked per loyalty number?
SELECT
	Loyalty_Number,
    ROUND(AVG(FLights_Booked),0) as Avererage_flights_booked
FROM
	customer_flight_activity
GROUP BY Loyalty_Number
ORDER BY 2 DESC;
# LITTLE SUMMARY: Maximum Average flights booked happened 3 times

# 2. How do points accumulated and points redeemed vary with the number of flights booked or distance traveled?
SELECT
	Flights_Booked,
    Distance,
    Points_Accumulated,
    Points_Redeemed
FROM
	customer_flight_activity
ORDER BY 1 DESC, 2 DESC, 3 DESC, 4 DESC;


# 3. Is there a correlation between the dollar cost of points redeemed and loyalty cardholder's CLV or salary?
SELECT 
    (
        (COUNT(*) * SUM(CFA.Dollar_Cost_Points_Redeemed * CLH.CLV) - SUM(CFA.Dollar_Cost_Points_Redeemed) * SUM(CLH.CLV))
        /
        (SQRT((COUNT(*) * SUM(CFA.Dollar_Cost_Points_Redeemed * CFA.Dollar_Cost_Points_Redeemed) - POW(SUM(CFA.Dollar_Cost_Points_Redeemed), 2)) * 
              (COUNT(*) * SUM(CLH.CLV * CLH.CLV) - POW(SUM(CLH.CLV), 2))))
    ) AS Correlation_Dollar_Points_CLV,
    (
        (COUNT(*) * SUM(CFA.Dollar_Cost_Points_Redeemed * CLH.Salary) - SUM(CFA.Dollar_Cost_Points_Redeemed) * SUM(CLH.Salary))
        /
        (SQRT((COUNT(*) * SUM(CFA.Dollar_Cost_Points_Redeemed * CFA.Dollar_Cost_Points_Redeemed) - POW(SUM(CFA.Dollar_Cost_Points_Redeemed), 2)) * 
              (COUNT(*) * SUM(CLH.Salary * CLH.Salary) - POW(SUM(CLH.Salary), 2))))
    ) AS Correlation_Dollar_Points_Salary
FROM 
    customer_flight_activity CFA
JOIN 
    customer_loyalty_history CLH ON CFA.Loyalty_Number = CLH.Loyalty_Number;
# NOT LITTLE SUMMARY: When the correlation coefficient is near zero or close to zero, it indicates that there is almost no linear association between the variables. 
# CONTINUATION: These values suggest that changes in the dollar cost of points redeemed are not significantly related to changes in CLV or Salary among loyalty cardholders.
# CONTINUATION: Also suggesting an extremely weak or negligible linear relationship between the dollar cost of points redeemed and both CLV and Salary.


# ADDITIONAL METRICS

# QUESTIONS:
# 1. What are the demographic characteristics of customers who book the highest number of flights or have the highest CLV?
# 2.Can we identify patterns in flight bookings or loyalty card usage based on demographic information?

# 1. What are the demographic characteristics of customers who book the highest number of flights or have the highest CLV?
SELECT 
    CLH.Country,
    CLH.Gender,
    CLH.Education,
    COUNT(CFA.Flights_Booked) AS Total_Flights_Booked
FROM 
    customer_flight_activity CFA
JOIN 
    customer_loyalty_history CLH ON CFA.Loyalty_Number = CLH.Loyalty_Number
GROUP BY 
    CLH.Country, CLH.Gender, CLH.Education
ORDER BY 
    Total_Flights_Booked DESC
LIMIT 10;  -- Adjust the limit to get the top customers with the highest flights

# 2.Can we identify patterns in flight bookings or loyalty card usage based on demographic information?
SELECT 
    CLH.Country,
    CLH.Gender,
    CLH.Education,
    COUNT(CFA.Flights_Booked) AS Total_Flights_Booked,
    SUM(CFA.Points_Accumulated) AS Total_Points_Accumulated
FROM 
    customer_flight_activity CFA
JOIN 
    customer_loyalty_history CLH ON CFA.Loyalty_Number = CLH.Loyalty_Number
GROUP BY 
    CLH.Country, CLH.Gender, CLH.Education
ORDER BY 
    Total_Flights_Booked DESC, Total_Points_Accumulated DESC;
# LITTLE SUMMARY: Female with Bachelor, Male with Bachelor, Male with College this is the pattern of TOP 3 numbers about total flights and total points

# CUSTOMER SEGMENTATION

# QUESTIONS:
# 1. Can we segment customers based on their flight activity, loyalty program usage, and demographic data?
# 2. Are there specific customer segments that contribute significantly to the overall revenue or loyalty program success?

# 1. Can we segment customers based on their flight activity, loyalty program usage, and demographic data?
SELECT 
    CLH.Country,
    CLH.Gender,
    CLH.Education,
    SUM(CFA.Flights_Booked) AS Total_Flights_Booked,
    SUM(CFA.Points_Accumulated) AS Total_Points_Accumulated,
    COUNT(CFA.Loyalty_Number) AS Total_Customers
FROM 
    customer_flight_activity CFA
JOIN 
    customer_loyalty_history CLH ON CFA.Loyalty_Number = CLH.Loyalty_Number
GROUP BY 
    CLH.Country, CLH.Gender, CLH.Education
ORDER BY 
    Total_Flights_Booked DESC, Total_Points_Accumulated DESC, Total_Customers DESC;
# LITTLE SUMMARY: FEMALE/MALE with bachelor's both are over 100 000 customers

# 2. Are there specific customer segments that contribute significantly to the overall revenue or loyalty program success?
SELECT 
    CLH.Country,
    CLH.Gender,
    CLH.Education,
    SUM(CFA.Dollar_Cost_Points_Redeemed) AS Total_Dollar_Cost_Redeemed,
    SUM(CFA.Dollar_Cost_Points_Redeemed* CFA.Flights_Booked) AS Total_Revenue_Contribution,
    SUM(CFA.Points_Accumulated) AS Total_Points_Accumulated
FROM 
    customer_flight_activity CFA
JOIN 
    customer_loyalty_history CLH ON CFA.Loyalty_Number = CLH.Loyalty_Number
GROUP BY 
    CLH.Country, CLH.Gender, CLH.Education
ORDER BY 
    Total_Revenue_Contribution DESC, Total_Points_Accumulated DESC;
# LITTLE SUMMARY FEMALE/MALE with bachelor's degree are again highest 'contributors' for dolar redeemed, revenue contirbution, points accumulated

# LAST BUT NOT LEAST, TOP 3 QUESTIONS:

# 1. What impact did the campaign have on loyalty program memberships (gross / net)?
# 2. Was the campaign adoption more successful for certain demographics of loyalty members?
# 3. What impact did the campaign have on booked flights during summer 2018?

# 1 What impact did the campaign have on loyalty program memberships (gross / net)?
WITH CTEA AS(
WITH CTE AS(
SELECT 
    Loyalty_Number,
    CONCAT(Enrollment_Year, '-', LPAD(Enrollment_Month, 2, '0'), '-01') AS Enrollment_Date,
    DATEDIFF(
        IFNULL(
            CONCAT(Cancellation_Year, '-', LPAD(Cancellation_Month, 2, '0'), '-01'), 
            CURDATE()
        ), 
        CONCAT(Enrollment_Year, '-', LPAD(Enrollment_Month, 2, '0'), '-01')
    ) AS Membership_Duration_days_cancelled,
    DATEDIFF(CURDATE(), CONCAT(Enrollment_Year, '-', LPAD(Enrollment_Month, 2, '0'), '-01')) as Membership_Duration_days_with_not_cancelled,
    Enrollment_Type as Membership_Type
FROM 
    customer_loyalty_history)
SELECT
	CTE.*,
    customer_flight_activity.Points_Accumulated,
    customer_flight_activity.Points_Redeemed,
    customer_flight_activity.Dollar_Cost_Points_Redeemed
FROM
	CTE
INNER JOIN customer_flight_activity on customer_flight_activity.Loyalty_Number = CTE.Loyalty_Number
GROUP BY 
	CTE.Loyalty_Number
ORDER BY 
	#CTE.Membership_Duration_days_with_not_cancelled DESC,
    customer_flight_activity.Points_Accumulated DESC,
    customer_flight_activity.points_Redeemed DESC,
    customer_flight_activity.Dollar_Cost_Points_Redeemed DESC)
SELECT
	Membership_Type,
	SUM(Points_accumulated) as Total_Points_Accumulated,
    SUM(Points_Redeemed) as Total_Points_Redeemed,
    ROUND(SUM(Points_Redeemed)/SUM(Points_accumulated)*100,2) as Redeemed_prct,
    SUM(Dollar_Cost_Points_Redeemed) as Total_Dollar_Redeemed,
    ROUND(SUM(Points_accumulated) *(1+(1-0.1327)),0) as Pending_For_Redeem
FROM
	CTEA
GROUP BY Membership_Type;
# LITTLE SUMMARY: Total Dollars redeemed is around 16 000 (net), and remaining is around 352 000 (gross). in Total Loyalty program 'costs' around 368 000 for the company


# 2. Was the campaign adoption more successful for certain demographics of loyalty members?
WITH CTEA AS (
WITH CTE AS(
SELECT 
    Loyalty_Number,
    Province,
    City
FROM 
    customer_loyalty_history)
SELECT
	CTE.*,
    customer_flight_activity.Points_Accumulated,
    customer_flight_activity.Points_Redeemed,
    customer_flight_activity.Dollar_Cost_Points_Redeemed
FROM
	CTE
INNER JOIN customer_flight_activity on customer_flight_activity.Loyalty_Number = CTE.Loyalty_Number)
SELECT
	Province,
    City,
    SUM(Points_Accumulated) as Total_Points,
    SUM(Points_redeemed) as Total_Points_Redeemed,
    SUM(Dollar_Cost_Points_Redeemed) as Total_Dollars_Redeemed
FROM
	CTEA
GROUP BY
	Province, City
ORDER BY Total_Points DESC, Total_Points_Redeemed DESC, Total_Dollars_Redeemed DESC;
# LITTLE SUMMARY: the campaign waas more successful for 3 certaing locations. Ontario - Toronto, British Columbia - Vancouver, Quebec - Montreal.
# CONTINUATION: Each of them reached above 500 000 total points, above 1 000 000 points redeemed, above 100 000 dolars redeemed

# 3. What impact did the campaign have on booked flights during summer 2018?
SELECT
	Year,
    Month,
    SUM(Flights_Booked) Total_Booked,
    SUM(Flights_with_Companions) Total_Books_With_Companions,
    SUM(Total_Flights) Total_Flights
FROM
	customer_flight_activity
WHERE
	Year = 2018 AND Month BETWEEN 6 AND 8
GROUP BY Year, Month;
# LITTLE SUMMARY: Highest demanded month for bookings is July




