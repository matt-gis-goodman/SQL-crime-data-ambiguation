SELECT
ICR_NUMBER
, CAST(FORMAT(REPORTED_DATE, 'yyyy-MM-dd') AS nvarchar(10)) AS REPORTED_DATE
, CAST(REPORTED_DATE AS date) AS REPORTED_DT
, CASE WHEN [UCR_DESC] LIKE '%Family%Offenses%' OR --List of all victim-sensitive crimes 
                         [UCR_DESC] LIKE '%Fondling%' OR
                         [UCR_DESC] LIKE '%Rape%' OR
                         [UCR_DESC] LIKE '%Sodomy%' OR
                         [UCR_DESC] LIKE '%Trafficking%' OR
                         [UCR_DESC] LIKE '%Incest%' OR
                         [UCR_DESC] LIKE '%Sexual%Assault%' 
			THEN TRIM([LOCATION_NAME])			-- all street address info is removed and replaced with the city/township name instead.
		WHEN [INCIDENT_ADDRESS] LIKE '4[0-9].%' 
			THEN 
			CASE WHEN [INCIDENT_ADDRESS] LIKE '4[0-9].%;%(%' 
					THEN TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(';', [INCIDENT_ADDRESS]) + 1, ABS(CHARINDEX('(', [INCIDENT_ADDRESS], CHARINDEX(';', [INCIDENT_ADDRESS])) - CHARINDEX(';', [INCIDENT_ADDRESS]) - 1))) 
				 WHEN [INCIDENT_ADDRESS] LIKE '4[0-9].%;%' 
					THEN TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(';', [INCIDENT_ADDRESS]) + 1, ABS(LEN([INCIDENT_ADDRESS])))) 
				 ELSE SUBSTRING([INCIDENT_ADDRESS], 1, 5) + 'XX, ' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX('-9', INCIDENT_ADDRESS, 5), 6) + 'XX'
			END 
		WHEN ([INCIDENT_ADDRESS] LIKE '%[A-Z] %/%[A-Z]%' AND [INCIDENT_ADDRESS] NOT LIKE '%1/2%') 
			AND ([INCIDENT_ADDRESS] NOT LIKE '%,%' OR CHARINDEX('/', [INCIDENT_ADDRESS]) < CHARINDEX(',', [INCIDENT_ADDRESS])) OR ([INCIDENT_ADDRESS] LIKE 'I-35/%') 
			THEN 
			CASE WHEN [INCIDENT_ADDRESS] LIKE '%[A-Z] %/%[A-Z]%,%' OR
                         [INCIDENT_ADDRESS] LIKE 'I-35/%,%' 
					THEN TRIM(SUBSTRING([INCIDENT_ADDRESS], 1, ABS(CHARINDEX(', ', [INCIDENT_ADDRESS]) - 1))) 
				 WHEN ([INCIDENT_ADDRESS] LIKE '%[A-Z] %/%[A-Z]%' OR [INCIDENT_ADDRESS] LIKE 'I-35/%') AND [INCIDENT_ADDRESS] NOT LIKE '%,%' 
					THEN TRIM([INCIDENT_ADDRESS]) 
			END 
		WHEN SUBSTRING([INCIDENT_ADDRESS], 1, 12) LIKE '[1-9]%blk %' OR SUBSTRING([INCIDENT_ADDRESS], 1, 12) LIKE '[1-9]%block %' 
			THEN 
			CASE WHEN [INCIDENT_ADDRESS] LIKE '[1-9]%blk %,%' 
					THEN REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], 1, ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - 1))), ' BLK ', '-block ') 
				 WHEN [INCIDENT_ADDRESS] LIKE '[1-9]%-BLOCK %,%' 
					THEN REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], 1, ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - 1))), '-BLOCK', '-block') 
				 WHEN [INCIDENT_ADDRESS] LIKE '[1-9]% BLOCK %,%' 
					THEN REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], 1, ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - 1))), ' BLOCK', '-block') 
                 WHEN ([INCIDENT_ADDRESS] LIKE '[1-9]% blk %' OR [INCIDENT_ADDRESS] LIKE '[1-9]% BLOCK %') AND ([INCIDENT_ADDRESS] NOT LIKE '%,%') 
					THEN REPLACE(REPLACE(TRIM([INCIDENT_ADDRESS]), ' blk', '-block'), ' BLOCK', '-block')
				 WHEN ([INCIDENT_ADDRESS] LIKE '[1-9]%-blk %' OR [INCIDENT_ADDRESS] LIKE '[1-9]%-block %') AND ([INCIDENT_ADDRESS] NOT LIKE '%,%') 
					THEN REPLACE(REPLACE(TRIM([INCIDENT_ADDRESS]), '-blk', '-block'), '-BLOCK', '-block')
			END 
		WHEN ([INCIDENT_ADDRESS] LIKE '[1-9]-[1-9]%') OR
             ([INCIDENT_ADDRESS] LIKE '[1-9][0-9]-[1-9]%') OR
             ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9]-[1-9]%') OR
             ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9]-[1-9]%') OR
             ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9]-[1-9]%') OR
             ([INCIDENT_ADDRESS] LIKE '%[0-9] - [1-9]%') 
				THEN 
				CASE WHEN ([INCIDENT_ADDRESS] LIKE '[1-9]-[1-9]% %,%' OR [INCIDENT_ADDRESS] LIKE '[1-9][0-9]-[0-9]% %,%') 
						THEN 'Zero-block ' + TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))) 
					 WHEN (([INCIDENT_ADDRESS] LIKE '[1-9]-[1-9]% %' OR [INCIDENT_ADDRESS] LIKE '[1-9][0-9]-[0-9]% %') AND ([INCIDENT_ADDRESS] NOT LIKE '%,%')) 
						THEN 'Zero-block ' + TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS])))
                     WHEN [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9]-[1-9]% %,%' 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 1) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS]))) 
					 WHEN [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9]-[1-9]% %' AND [INCIDENT_ADDRESS] NOT LIKE '%,%' 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 1) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS])) 
					 WHEN [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9]-[1-9]% %,%' 
						THEN SUBSTRING([INCIDENT_ADDRESS],1, 2) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS]))) 
					 WHEN [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9]-[1-9]% %' AND [INCIDENT_ADDRESS] NOT LIKE '%,%' 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 2) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS])) 
					 WHEN [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9]-[1-9]% %,%' 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 2) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS]))) 
					 WHEN [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9]-[1-9]% %' AND [INCIDENT_ADDRESS] NOT LIKE '%,%' 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 2) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS]))  
					 WHEN [INCIDENT_ADDRESS] LIKE '[1-9] - [1-9]% %,%' OR
                         [INCIDENT_ADDRESS] LIKE '[1-9][0-9] - [1-9]% %,%' OR
                         [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9] - [1-9]% %,%' OR
                         [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9] - [1-9]% %,%' OR
                         [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9] - [1-9]% %,%' 
						 THEN 
						 CASE WHEN CHARINDEX(' ', [INCIDENT_ADDRESS]) < 4 
								THEN 'Zero-block ' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2), ABS(CHARINDEX(',', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2) - CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2)))
							  WHEN CHARINDEX(' ', [INCIDENT_ADDRESS]) = 4 
								THEN SUBSTRING([INCIDENT_ADDRESS], 1, 1) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ',  [INCIDENT_ADDRESS]) + 2), ABS(CHARINDEX(',', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2) - CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2))) 
							  WHEN CHARINDEX(' ', [INCIDENT_ADDRESS]) = 5 
								THEN SUBSTRING([INCIDENT_ADDRESS], 1, 2) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2),  ABS(CHARINDEX(',', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2) - CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2))) 
							  WHEN CHARINDEX(' ', [INCIDENT_ADDRESS]) = 6 
								THEN SUBSTRING([INCIDENT_ADDRESS], 1, 3) + '00-block' + SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2), ABS(CHARINDEX(',', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2) - CHARINDEX(' ', [INCIDENT_ADDRESS], CHARINDEX('- ', [INCIDENT_ADDRESS]) + 2))) 
						 END 
				END 
		WHEN ([INCIDENT_ADDRESS] LIKE '[1-9] %[A-Z]% %APT%' OR
              [INCIDENT_ADDRESS] LIKE '[1-9][0-9] %[A-Z]% %APT%' OR
              [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9] %[A-Z]% %APT%' OR
              [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9] %[A-Z]% %APT%' OR
              [INCIDENT_ADDRESS] LIKE ('[1-9][0-9][0-9][0-9][0-9] %[A-Z]% %APT%') OR
              SUBSTRING([INCIDENT_ADDRESS], 1, CHARINDEX(' ', [INCIDENT_ADDRESS])) LIKE ('%[0-9]-H% [A-Z]% %APT%')) AND ([INCIDENT_ADDRESS] NOT LIKE '%,%' OR
              CHARINDEX('APT', [INCIDENT_ADDRESS]) < CHARINDEX(',', [INCIDENT_ADDRESS])) 
			  THEN 
			  CASE WHEN ([INCIDENT_ADDRESS] LIKE '[1-9] %[A-Z]%APT%' OR
						[INCIDENT_ADDRESS] LIKE '[1-9][0-9] %[A-Z]%APT%' OR
						[INCIDENT_ADDRESS] LIKE '[1-9]-H %[A-Z]%APT%' OR
						[INCIDENT_ADDRESS] LIKE '[1-9][0-9]-H %[A-Z]%APT%') 
						THEN 'Zero-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX('APT', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
					WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9] %[A-Z]%APT%') 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 1) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX('APT', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
					WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9] %[A-Z]%APT%') 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 2) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX('APT', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
					WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9] %[A-Z]%APT%') 
						THEN SUBSTRING([INCIDENT_ADDRESS], 1, 3) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX('APT', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
			  END 
		WHEN (([INCIDENT_ADDRESS] NOT LIKE '%APT%') OR
              ([INCIDENT_ADDRESS] LIKE '%APT%' AND CHARINDEX('APT', [INCIDENT_ADDRESS]) > CHARINDEX(',', [INCIDENT_ADDRESS]))) AND (([INCIDENT_ADDRESS] LIKE ('[1-9] %[A-Z]% %') OR
               [INCIDENT_ADDRESS] LIKE ('[1-9][0-9] %[A-Z]% %') OR
               [INCIDENT_ADDRESS] LIKE ('[1-9][0-9][0-9] %[A-Z]% %') OR
               [INCIDENT_ADDRESS] LIKE ('[1-9][0-9][0-9][0-9] %[A-Z]% %') OR
               [INCIDENT_ADDRESS] LIKE ('[1-9][0-9][0-9][0-9][0-9] %[A-Z]% %'))) OR
               SUBSTRING([INCIDENT_ADDRESS], 1, CHARINDEX(' ', [INCIDENT_ADDRESS])) LIKE ('%[0-9]-H%') 
			   THEN 
			   CASE WHEN ([INCIDENT_ADDRESS] LIKE '[1-9] %[A-Z]%' OR
                          [INCIDENT_ADDRESS] LIKE '[1-9]-H %[A-Z]%' OR
                          [INCIDENT_ADDRESS] LIKE '[1-9][0-9] %[A-Z]%' OR
                          [INCIDENT_ADDRESS] LIKE '[1-9][0-9]-H %[A-Z]%') 
						  THEN 
						  CASE WHEN ([INCIDENT_ADDRESS] LIKE '[1-9] %[A-Z]%,%' OR
									 [INCIDENT_ADDRESS] LIKE '[1-9][0-9] %[A-Z]%,%' OR
									 [INCIDENT_ADDRESS] LIKE '[1-9]-H %[A-Z]%,%' OR
								     [INCIDENT_ADDRESS] LIKE '[1-9][0-9]-H %[A-Z]%,%') 
									THEN 'Zero-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
								WHEN ([INCIDENT_ADDRESS] NOT LIKE '%,%') 
									THEN 'Zero-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS]))), '1/2', '') 
						  END 
					 WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9] %[A-Z]%' OR
                           [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9]-H %[A-Z]%') 
						   THEN 
						   CASE WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9] %[A-Z]%,%' OR
									  [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9]-H %[A-Z]%,%') 
									  THEN SUBSTRING([INCIDENT_ADDRESS], 1, 1) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
								WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9] %[A-Z]%' OR
									  [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9]-H %[A-Z]%') AND ([INCIDENT_ADDRESS] NOT LIKE '%,%') 
									  THEN SUBSTRING([INCIDENT_ADDRESS], 1, 1) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS]))), '1/2', '') 
						   END 
					 WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9] %[A-Z]%' OR
                           [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9]-H %[A-Z]%') 
						   THEN 
						   CASE WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9] %[A-Z]%,%' OR
									  [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9]-H %[A-Z]%,%') 
										THEN SUBSTRING([INCIDENT_ADDRESS], 1, 2) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
								WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9] %[A-Z]%' OR
									  [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9]-H %[A-Z]%') AND ([INCIDENT_ADDRESS] NOT LIKE '%,%') 
										THEN + SUBSTRING([INCIDENT_ADDRESS], 1, 2) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS]))), '1/2', '') 
							END 
					  WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9] %[A-Z]%' OR [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9]-H %[A-Z]%') 
						THEN 
						CASE WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9] %[A-Z]%,%' OR [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9]-H %[A-Z]%,%') 
								THEN SUBSTRING([INCIDENT_ADDRESS], 1, 3) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), ABS(CHARINDEX(',', [INCIDENT_ADDRESS]) - CHARINDEX(' ', [INCIDENT_ADDRESS])))), '1/2', '') 
							 WHEN ([INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9] %[A-Z]%,%' OR [INCIDENT_ADDRESS] LIKE '[1-9][0-9][0-9][0-9][0-9]-H %[A-Z]%,%') AND ([INCIDENT_ADDRESS] NOT LIKE '%,%') 
								THEN SUBSTRING([INCIDENT_ADDRESS], 1, 3) + '00-block ' + REPLACE(TRIM(SUBSTRING([INCIDENT_ADDRESS], CHARINDEX(' ', [INCIDENT_ADDRESS]), LEN([INCIDENT_ADDRESS]))), '1/2', '') 
						END 
			   END 
		WHEN [INCIDENT_ADDRESS] LIKE '[A-Z]%,%' 
			THEN TRIM(SUBSTRING([INCIDENT_ADDRESS], 1, ABS(CHARINDEX(', ',  [INCIDENT_ADDRESS]) - 1)))
		WHEN [INCIDENT_ADDRESS] IS NULL 
			THEN 'Street info not available' 
			ELSE 'Street info not available' 
	END AS AMBIGUATED_ADDRESS
	
	, LOCATION_NAME
	, LOCATION_CODE
	, CRIME_TYPE_CODE
	, CRIME_TYPE_DESC

-- LATITUDE!
, CASE
	WHEN ([LATITUDE] = '0' OR [LATITUDE] LIKE '0.0%' OR [LATITUDE] IS NULL) THEN '47'  -- Missing valid latitude coordinates
---- List of vicitm-sensitive crimes---
	WHEN ([UCR_DESC] LIKE '%Family%Offenses%' OR
		[UCR_DESC] LIKE '%Fondling%' OR
		[UCR_DESC] LIKE '%Rape%' OR
		[UCR_DESC] LIKE '%Sodomy%' OR
		[UCR_DESC] LIKE '%Trafficking%' OR
		[UCR_DESC] LIKE '%Incest%' OR
		[UCR_DESC] LIKE '%Sexual%Assault%') THEN
		CASE 
			WHEN [LOCATION_NAME] LIKE '%Twp%' OR [LOCATION_NAME] LIKE 'UT %' OR [LOCATION_NAME] IS NULL THEN  -- crimes in rural areas (get ambiguated more) --- 
				CASE 
					WHEN [LATITUDE] LIKE '4[0-9][0-9]%' THEN   --- latitude missing decimal 
						ROUND(CONVERT(decimal(6, 4), LEFT([LATITUDE], 2) + '.' + SUBSTRING([LATITUDE], 3, 3)) + (CASE WHEN SUBSTRING([LATITUDE], 7, 1)<5 THEN -1 ELSE 1 END)*(0.0150),3) --skews by +/- 0.015 degrees, then rounds-off the coordinate to the thousandths place 
						--- end of victim-sensitive crimes in rural areas that do not have a decimal in the latitude
					WHEN [LATITUDE] LIKE '4[0-9].[0-9][0-9][0-9]%' THEN  --- latitude has required decimal
						ROUND([LATITUDE]+ (CASE WHEN SUBSTRING([LATITUDE], 8, 1)<5 THEN -1 ELSE 1 END)*(0.0150),3) --skews by +/- 0.015 degrees, then rounds-off the coordinate to the thousandths place 
					 --- end vicitim-sensitive crimes in rural areas that do have a decimal in the latitude
				END --- end latitude handling for victim-sensitive crimes in rural areas
			WHEN [LOCATION_NAME] NOT LIKE '%Twp%' AND [LOCATION_NAME] NOT LIKE 'UT %' THEN  --- victim-sensitive crimes in cities (non-rural areas)
				CASE 
					WHEN [LATITUDE] LIKE '4[0-9][0-9]%' THEN  --- latitude missing decimal ----
						ROUND(CONVERT(decimal(6, 3), LEFT([LATITUDE], 2) + '.' + SUBSTRING([LATITUDE], 3, 3)) + (CASE WHEN SUBSTRING([LATITUDE], 7, 1)<5 THEN -1 ELSE 1 END)*(0.0080),3)  --skews by +/- 0.008 degrees, then rounds-off the coordinate to the thousandths place 
						--- end of victim-sensitive crimes in rural areas that do not have a decimal in the latitude
					WHEN [LATITUDE] LIKE '4[0-9].[0-9][0-9][0-9]%' THEN  --- latitude has required decimal
						ROUND([LATITUDE]+ (CASE WHEN SUBSTRING([LATITUDE], 8, 1)<5 THEN -1 ELSE 1 END)*(0.0080),3) --skews by +/- 0.008 degrees, then rounds-off the coordinate to the thousandths place 
						 --- end vicitim-sensitive crimes in rural areas that do have a decimal in the latitude
						--- end latitude handling for victim-sensitive crimes in rural areas
				END -- end victim-sensitive crimes in cities
		END -- end victim-sensitive crimes
	WHEN [LATITUDE] LIKE '4[0-9][0-9]%'  THEN -- latitude does not have necessary decimal
		CASE 
			WHEN [LOCATION_NAME] LIKE '%Twp%' OR [LOCATION_NAME] LIKE 'UT %' OR [LOCATION_NAME] IS NULL THEN
				ROUND(CONVERT(decimal(6, 4), LEFT([LATITUDE], 2) + '.' + SUBSTRING([LATITUDE], 3, 3)) + (CASE WHEN SUBSTRING([LATITUDE], 7, 1)<5 THEN -1 ELSE 1 END)*(0.0006+(CAST(SUBSTRING([LATITUDE], 7, 1) AS INT)*0.0002)),4) --skews by +/- 0.0002 degrees, then rounds-off the coordinate to the ten-thousandths place
			WHEN [LOCATION_NAME] NOT LIKE '%Twp%' AND [LOCATION_NAME] NOT LIKE 'UT %' THEN
				ROUND(CONVERT(decimal(6, 4), LEFT([LATITUDE], 2) + '.' + SUBSTRING([LATITUDE], 3, 3)) + (CASE WHEN SUBSTRING([LATITUDE], 7, 1)<5 THEN -1 ELSE 1 END)*(0.0001+(CAST(SUBSTRING([LATITUDE], 7, 1) AS INT)*0.0001)),4) --skews by +/- 0.0001 degrees, then rounds-off the coordinate to the ten-thousandths place
		END
	WHEN [LATITUDE] LIKE '4[0-9].[0-9]%' THEN  -- latitude has required decimal
		CASE
			WHEN [LOCATION_NAME] LIKE '%Twp%' OR [LOCATION_NAME] LIKE 'UT %' OR [LOCATION_NAME] IS NULL THEN
				ROUND([LATITUDE]+ (CASE WHEN SUBSTRING([LATITUDE], 8, 1)<5 THEN -1 ELSE 1 END)*(0.0006+(CAST(SUBSTRING([LATITUDE], 8, 1) AS INT)*0.0002)),4) --skews by +/- 0.0002 degrees, then rounds-off the coordinate to the ten-thousandths place
			WHEN [LOCATION_NAME] NOT LIKE '%Twp%' AND [LOCATION_NAME] NOT LIKE 'UT %' THEN
				ROUND([LATITUDE]+ (CASE WHEN SUBSTRING([LATITUDE], 8, 1)<5 THEN -1 ELSE 1 END)*(0.0001+(CAST(SUBSTRING([LATITUDE], 8, 1) AS INT)*0.0001)),4) --skews by +/- 0.0001 degrees, then rounds-off the coordinate to the ten-thousandths place
		
		END -- end regular crimes with decimals
		ELSE ROUND([LATITUDE], 4) -- regular crimes with normal latitude that include necessary decimal
	END AS AMBIGUATED_LATITUDE

---LONGITUDE!
,
CASE WHEN ([LONGITUDE] = '0' OR	[LONGITUDE] LIKE '0.0%' OR	[LONGITUDE] IS NULL) THEN '-91'  --sets a known 'bogus' longitude for those missing the attribute.
     WHEN ([UCR_DESC] LIKE '%Family%Offenses%' OR -- all victim-sensitive crimes
	       [UCR_DESC] LIKE '%Fondling%' OR
	       [UCR_DESC] LIKE '%Rape%' OR
	       [UCR_DESC] LIKE '%Sodomy%' OR
	       [UCR_DESC] LIKE '%Trafficking%' OR
	       [UCR_DESC] LIKE '%Incest%' OR
	       [UCR_DESC] LIKE '%Sexual%Assault%') THEN 
	    CASE WHEN [LOCATION_NAME] LIKE '%Twp%' OR [LOCATION_NAME] LIKE 'UT %' OR [LOCATION_NAME] IS NULL THEN --rural areas
			   CASE WHEN [LONGITUDE] LIKE '9[0-9][0-9]%' -- missing negative symbol and decimal
					  THEN ROUND(CONVERT(decimal(6, 3), '-' + LEFT([LONGITUDE], 2) + '.' + SUBSTRING([LONGITUDE], 3, 4))  + (CASE WHEN SUBSTRING([LONGITUDE], 7,1)<5 THEN -1 ELSE 1 END)*(0.015),3) --skews by +/- 0.015 degrees, then rounds-off the coordinate to the thousandths place
		        WHEN [LONGITUDE] LIKE '-9[0-9].[0-9][0-9][0-9]%' -- has negative symbol and decimal
					  THEN ROUND([LONGITUDE] + (CASE WHEN SUBSTRING([LONGITUDE], 9,1)<5  THEN -1 ELSE 1 END)*(0.015),3) --skews by +/- 0.015 degrees, then rounds-off the coordinate to the thousandths place
		   END -- end victim-sensitive crimes in rural areas
	      WHEN [LOCATION_NAME] NOT LIKE '%Twp%' AND [LOCATION_NAME] NOT LIKE 'UT %' THEN -- municipal (non rural) areas
		      CASE WHEN [LONGITUDE] LIKE '9[0-9][0-9]%' -- longitude missing negative symbol and decimal
						THEN ROUND(CONVERT(decimal(6, 3), '-' + LEFT([LONGITUDE], 2) + '.' + SUBSTRING([LONGITUDE], 3, 4)) + (CASE WHEN SUBSTRING([LONGITUDE], 7,1)<5  THEN -1 ELSE 1 END)*(0.008),3) --skews by +/- 0.008 degrees, then rounds-off the coordinate to the thousandths place
			      -- end victim-sensitive crimes in municipal areas that lack negative and decimals in longitude
					WHEN [LONGITUDE] LIKE '-9[0-9].[0-9][0-9][0-9]%' -- has negative symbol and decimal
						THEN ROUND([LONGITUDE] + (CASE WHEN SUBSTRING([LONGITUDE], 9,1)<5  THEN -1 ELSE 1 END)*(0.008),3) --skews by +/- 0.008 degrees, then rounds-off the coordinate to the thousandths place
			     -- end victim-sensitive crimes in urban areas with negative and decimal symbols
		      END -- end victim-sensitive crimes in urban areas with different lat/long formatting
	        END  -- end victim-sensitive crimes in urban areas
	WHEN [LONGITUDE] LIKE '9[0-9][0-9]%' -- all other 'regular' crime types
		THEN CASE WHEN [LOCATION_NAME] LIKE '%Twp%' OR [LOCATION_NAME] LIKE 'UT %' OR [LOCATION_NAME] IS NULL 
					THEN ROUND(CONVERT(decimal(6, 4), '-' + LEFT([LONGITUDE], 2) + '.' + SUBSTRING([LONGITUDE], 3, 4)) + (CASE WHEN SUBSTRING([LONGITUDE], 7,1)<5 THEN -1 ELSE 1 END)*(0.0006+(CAST(SUBSTRING([LONGITUDE], 7, 1) AS INT)*0.0002)),4)  --skews by +/- 0.0002 degrees, then rounds-off the coordinate to the ten-thousandths place
				  WHEN [LOCATION_NAME] NOT LIKE '%Twp%' AND [LOCATION_NAME] NOT LIKE 'UT %' 
					THEN ROUND(CONVERT(decimal(6, 4), '-' + LEFT([LONGITUDE], 2) + '.' + SUBSTRING([LONGITUDE], 3, 4)) + (CASE WHEN SUBSTRING([LONGITUDE], 7,1)<5 THEN -1 ELSE 1 END)*(0.0001+(CAST(SUBSTRING([LONGITUDE], 7, 1) AS INT)*0.0001)),4) --skews by +/- 0.0001 degrees, then rounds-off the coordinate to the ten-thousandths place
			END
		WHEN [LONGITUDE] LIKE '-9[0-9].[0-9][0-9][0-9]%' THEN -- has negative symbol and decimal
			CASE WHEN [LOCATION_NAME] LIKE '%Twp%' OR [LOCATION_NAME] LIKE 'UT %' OR [LOCATION_NAME] IS NULL 
					THEN ROUND([LONGITUDE]+((CASE WHEN SUBSTRING([LONGITUDE], 9,1)<5 THEN -1 ELSE 1 END)*(0.0006+(CAST(SUBSTRING([LONGITUDE], 9, 1) AS INT)*0.0002))),4) --skews by +/- 0.0002 degrees, then rounds-off the coordinate to the ten-thousandths place
				WHEN [LOCATION_NAME] NOT LIKE '%Twp%' AND [LOCATION_NAME] NOT LIKE 'UT %' 
					THEN ROUND([LONGITUDE]+((CASE WHEN SUBSTRING([LONGITUDE], 9,1)<5  THEN -1 ELSE 1 END)*(0.0001+(CAST(SUBSTRING([LONGITUDE], 9, 1) AS INT)*0.0001))),4) --skews by +/- 0.0001 degrees, then rounds-off the coordinate to the ten-thousandths place
		END
ELSE ROUND([LONGITUDE], 4) 	 -- regular crimes with normal latitude that include necessary decimal					 
END AS AMBIGUATED_LONGITUDE
						 , ARREST_INDICATOR, UCR_CODE, UCR_DESC, CASE WHEN UCR_DESC IN ('Aggravated Assault', 
                         'Simple Assault', 'Intimidation') THEN 'Assault Offenses' WHEN UCR_DESC LIKE '%Drug%Narcotic%' OR
                         UCR_DESC LIKE '%Drug%Equipment%' THEN 'Drug/Narcotic Offenses' WHEN UCR_DESC LIKE '%Pretense%' OR
                         UCR_DESC LIKE '%Swindle%' OR
                         UCR_DESC LIKE '%Confidence%Game%' OR
                         UCR_DESC LIKE '%Credit Card%' OR
                         UCR_DESC LIKE '%Teller%Machine%' OR
                         UCR_DESC LIKE '%Impersonation%' OR
                         UCR_DESC LIKE '%Welfare%' OR
                         UCR_DESC LIKE '%Wire Fraud%' OR
                         UCR_DESC LIKE '%Identity Theft%' OR
                         UCR_DESC LIKE '%Hacking%Computer%' OR
                         UCR_DESC LIKE '%Bad%Checks%' THEN 'Fraud Offenses' WHEN UCR_DESC LIKE '%Betting%Wagering%' OR
                         UCR_DESC LIKE '%Operating%Promoting%Assist%Gambling%' OR
                         UCR_DESC LIKE '%Gambling%Equipment%' OR
                         UCR_DESC LIKE '%Sports%Gambling%' THEN 'Gambling Offenses' WHEN UCR_DESC LIKE '%Murder%Non%neg%Manslaughter%' OR
                         UCR_DESC LIKE '%Negligent%Manslaughter%' OR
                         UCR_DESC LIKE '%Justifiable%Homicide%' THEN 'Homicide Offenses' WHEN UCR_DESC LIKE '%Human%Traffic%' OR
                         UCR_DESC LIKE '%Commercial Sex%' OR
                         UCR_DESC LIKE '%Involuntary%Servitude%' THEN 'Human Trafficking' WHEN UCR_DESC LIKE '%Pocket%pick%' OR
                         UCR_DESC LIKE '%Purse%snatch%' OR
                         UCR_DESC LIKE '%Shoplift%' OR
                         UCR_DESC LIKE 'Theft From%' OR
                         UCR_DESC LIKE '%Other Larceny%' OR
                         UCR_DESC LIKE 'Theft%Motor%Vehicle%' THEN 'Larceny/Theft Offenses' WHEN UCR_DESC LIKE '%Prostitution%' THEN 'Prostituation Offenses' WHEN UCR_DESC LIKE '%Rape%' OR
                         UCR_DESC LIKE '%Sodomy%' OR
                         UCR_DESC LIKE '%Sex%Assault%Object%' OR
                         UCR_DESC LIKE '%Fondling%' OR
                         UCR_DESC LIKE '%Incest%' THEN 'Sex Offenses' WHEN UCR_DESC LIKE '%Rape%' OR
                         UCR_DESC LIKE '%Sodomy%' OR
                         UCR_DESC LIKE '%Sex%Assault%Object%' OR
                         UCR_DESC LIKE '%Fondling%' OR
                         UCR_DESC LIKE '%Incest%' THEN 'Sex Offenses' ELSE UCR_DESC END AS UCR_Category, AGENCY_CODE, OFFICE_CODE, YEAR, MONTH
FROM            [SandboxData].[dbo].[FICTION_RMS_Incidents]
WHERE        (CRIME_TYPE_CODE <> 'N/A') AND (UCR_DESC NOT IN ('NIBRS non-reportable offense', 'All Other Offenses')) 