

-----------------------------Take an overview of our data set


SELECT *
FROM World_suicide_rates.dbo.WSR


---------------------------- See how many main regions in our data


select Distinct(region)
from World_suicide_rates.dbo.WSR

SELECT DISTINCT(YEAR)
FROM World_suicide_rates.DBO.WSR



------------------------------Clean data and choose relevant columns, import them in the new table


DROP TABLE IF EXISTS World_suicide_rates.dbo.WSR_cleaned
SELECT 
	region_code, 
	region, 
	country_code, 
	Country, 
	year, 
	sex, 
	sex_code, 
	rate, 
	rate_low, 
	rate_high
INTO World_suicide_rates.dbo.WSR_Cleaned
FROM World_suicide_rates.dbo.WSR



---------------------------List Max/Min/Ave Rate of each Area in 20 years


SELECT 
	region, 
	region_code, 
	max(rate) AS highest_rate, 
	min(rate) AS lowest_rate, 
	AVG(rate) AS region_ave_20
FROM World_suicide_rates.DBO.WSR_Cleaned
WHERE sex = 'both sexes'
GROUP BY 
	region_code, 
	region
ORDER BY Region




----------------------List Countries in each region that have 2019 suicide rate higher than their region 20 years average


WITH Region_Average AS----------set up a CTE listing the 20 year average for each region
(
	SELECT 
		region, 
		region_code, 
		max(rate) AS highest_rate, 
		min(rate) AS lowest_rate, 
		AVG(rate) AS region_ave_20
	FROM World_suicide_rates.DBO.WSR_Cleaned
	WHERE sex = 'both sexes'
	GROUP BY 
		region_code, 
		region
)
SELECT 
	Country, 
	rate, 
	wsr.region_code, 
	region_ave_20, 
	year
FROM 
	World_suicide_rates.dbo.WSR_Cleaned AS WSR LEFT JOIN Region_Average AS RA 
	ON WSR.region_code = RA.region_code
WHERE 
	rate > region_ave_20 AND
	Year = 2019 AND
	sex = 'both sexes'
ORDER BY region_code




----------------------------Count how many countries that have 2019 suicide rate higher than its region 20 year average


WITH Region_Average AS
(
	SELECT 
		region, 
		region_code, 
		max(rate) AS highest_rate, 
		min(rate) AS lowest_rate, 
		AVG(rate) AS region_ave_20
	FROM World_suicide_rates.DBO.WSR_Cleaned
	WHERE sex = 'both sexes'
	GROUP BY 
		region_code, 
		region
)
SELECT 
	WSR.Region,
	region_ave_20,
	SUM(
		CASE
			WHEN rate >= region_ave_20 THEN 1
			ELSE 0
		END
		) AS higher_than_average_count
FROM 
	World_suicide_rates.dbo.WSR_Cleaned AS WSR LEFT JOIN Region_Average AS RA 
	ON WSR.region_code = RA.region_code
WHERE 
	year = 2019 AND
	sex = 'both sexes'
GROUP BY
	WSR.Region,
	region_ave_20




----------------------------------Identify country with Highest Suicide rate and year


SELECT 
	country, 
	rate, 
	year, 
	region
FROM World_suicide_rates.DBO.WSR_Cleaned
WHERE 
	sex = 'both sexes' AND 
	rate = 
	(
		SELECT max(rate)
		FROM World_suicide_rates.dbo.WSR_Cleaned
		WHERE sex = 'both sexes'
	)




------------------------------------How fast has suicide rate rised/fell for the past 20 years in all 6 regions


WITH base_rate_2000 AS 
(
	SELECT 
		region_code, 
		AVG(RATE) AS rate_2000
	FROM
		World_suicide_rates.DBO.WSR_Cleaned
	WHERE
		sex = 'both sexes' AND
		year = 2000
	GROUP BY 
		Region_code
)
SELECT
	region,
	YEAR,
	(AVG(WSR.RATE) - BR.rate_2000)/BR.rate_2000 * 100 AS percentage_diff
FROM
	World_suicide_rates.DBO.WSR_Cleaned AS WSR lEFT JOIN base_rate_2000 AS BR
	ON WSR.region_code = BR.region_code
WHERE
	sex = 'both sexes' AND
	year not like 2000
GROUP BY
	Region,
	YEAR,
	Sex,
	BR.rate_2000
ORDER BY
	Year,
	Region
