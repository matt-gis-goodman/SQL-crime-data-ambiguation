This SQL query was constructed primarily using regular expressions to create a database view that is appropriately 'sanitized' for public consumption while still stored within the CJIS-compliant infrastructure of the law enforcement agency's Records Management System. 

Ther are two 'main' blocks of code:

1). The first main function ambiguates and 'address' field. For the most 'victim-sensitive' crimes, all street address information (i.e. "1234 Main St") is simply replaced with with city/township jurisdiction field (i.e. "Brimson Township"). For other crime types that contain regular civic addresses, the address is changed to a 'block address' (i.e. 1200-block Main St). Intersections are left as-is (i.e. Oak St / Lake Ave) on the assumption that there is no personally identifiable information associated with a road intersection. Some records contian 'common names' (i.e. "Taco Bell") or latitude/longitude coordinate pairs in the address field, which are recognized and ambiguated as well. 

2). The second main function of the query is to ambiguate the actual latitude and longitude valudes (decimals/floats) so that they can be used for mapping, but will not acurately/precisely locate the incident. This ambiguation takes into account whether the incident is in a rural vs. urban jurisdiction (skewing rural incidents more than urban ones). It also skews victim-sensitive crimes much more than other crime types. The whether the latitude or longitude is skewed up or down is determined by the value of the digit in the 5th decimal place (the hundred thousandths place) - if it's 5 or greater, the coordinate skews up and if it's 4 or lower the coordinate skews down. Additionally, after the prescribed math is applied to the decimal, it is then rounded (to the thousandths or ten-thousandths place, depending on criteria). Ultimately, these math functions result in the following approximate skewing to locations:

 - Victim-sensitive crimes in RURAL areas: average skew of 6,612-feet
 - Victim-sensitive crimes in URBAN areas: average skew of 3,524-feet
 - Non-victim-sensitive crimes in RURAL areas: average skew of 653-feet
 - Non-victim-sensitive crimes in URBAN areas: average skew of 279-feet

Obviously this query will not 'plug-and-play' for agencies with differing data schemas, but it is intended to serve as a rudimentary model for scrubbing and altering complex data for mapping and/or publishing. 

Questions? Please reach out, 

-   Matt Goodman, GIS Principal
-   St. Louis County Sheriff's Office
-   9-1-1 Communications Division
-   2030 N Arlington Ave
-   (218) 726-2938 (office)
-   goodmanm@stlouiscountymn.gov
