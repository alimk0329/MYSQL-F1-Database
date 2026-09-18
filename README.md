# MYSQL-F1-Database


# Overview
This project aims to create an efficient database for storing, organizing, and analyzing Formula 1 driver statistics.
There are limitations of relying solely on APIs for accessing F1 data, and this provides a curated and more readily analyzable dataset for fans and researchers. 
The database allows for detailed comparisons of drivers across seasons, tracks lap data, pit-stop strategies, and overall race performance with simple queries. 


## Purpose & Motivation

The primary motivation behind this project is to overcome the challenges of extracting and managing comprehensive F1 statistics from available APIs.  
By consolidating data into a dedicated database, users can more easily:

Conduct in-depth driver comparisons across different seasons.
Analyze lap data and pit stop strategies.
Gain deeper insights into race weekend performance.
Explore trends and patterns in Formula 1 racing.

## Database Design & Entities

    The database incorporates the following entities to represent key aspects of F1 events:

    *   **Drivers:** Information about each driver (ID, number, name).
    *   **Teams:** Details on the competing teams.
    *   **Event Weekends:**  Data related to individual race weekends (round number, year, country, location, session dates/times).
    *   **Race Results:** The final results of each race for each driver.
    *   **Qualifying Results:** Qualifying times and positions for drivers.
    *   **Lap Data:** Detailed lap-by-lap information including timings, tyre compounds, and pit stop details.
    *   **Pit Stops:**  Specific data concerning pit stops during a race.
    *   **Driver Standings:** Championship standings at the end of each race weekend.
    *   **Driver Race Stats:** Aggregate statistics for drivers in each race (fastest lap, average lap time, laps led).
