## Airline Loyalty Program Data Analysis
This repository presents an analysis of anonymized data from an airline loyalty program. 

The dataset encompasses two primary tables: customer_flight_activity, detailing flight-related metrics, and customer_loyalty_history, containing demographic and loyalty program information. The analysis was conducted in MySQL, utilizing various queries to extract meaningful insights and address specific questions related to customer behavior, enrollment trends, flight activity, demographic distributions, and campaign impact.

## Overview
Data Structure: The data structure was reviewed and deemed suitable for analysis. Column values with spaces were replaced by underscores for seamless querying in MySQL.

Data Import: The data was successfully imported into MySQL tables customer_flight_activity and customer_loyalty_history using the LOAD DATA INFILE function after schema creation.

## Analysis Highlights
Demographic Analysis: Gender distribution showed an even split (50/50), while bachelor's and college degrees were the most prevalent education levels.

Location Distribution: Popular regions among members included Ontario, British Columbia, and Quebec, with Toronto, Vancouver, and Montreal as top cities.

Enrollment and Cancellation Trends: Enrollment numbers gradually increased over six years. Flight cancellation rates notably rose, showing a sixfold trend from 2014 to 2018.

Flight Activity Analysis: Identified the maximum average flights booked at three occurrences.

Correlation Analysis: Found negligible associations between dollar cost points redeemed and customer CLV or salary.

Customer Segmentation: Highlighted female/male with bachelor's degrees as the top customer segments in terms of total flights and points.

Campaign Impact Analysis: The campaign had a notable impact on loyalty program memberships, with a net cost of approximately $16,000 and a gross cost of around $368,000. Notably successful in Ontario-Toronto, British Columbia-Vancouver, and Quebec-Montreal regions.

## Conclusion
The analysis unveiled several critical insights, including demographic distributions, enrollment trends, flight activity patterns, and the campaign's impact on program memberships and bookings. 

Despite certain trends and correlations observed, several aspects displayed negligible associations. This repository contains SQL queries utilized for analysis, offering a comprehensive understanding of the airline loyalty program's data landscape.

For a deeper understanding of the analysis, please refer to the individual SQL queries and their respective findings documented in this repository.
