import fastf1
import pandas as pd
import time

all_results = []

current_year = 2026

wanted_columns = ['DriverNumber', 'FullName', 'Abbreviation', 'TeamName', 'Position', 'Time', 'Status']


def fetch_session(year,session_num):
    session = fastf1.get_session(year,session_num, 'R')
    session.load()
    results = session.results.copy()

    #add null results
    for col in wanted_columns:
        if col not in results.columns:
            results[col] = None

    #get rid of columns not wanted 
    results = results[wanted_columns].copy()
    all_results.append(results)



#print(all_results)



schedule = fastf1.get_event_schedule(1950)

for _, race in schedule.iterrows():
        round_number = race.get('RoundNumber', None)
        event_name = race.get('EventName', None)
        race_date = race.get('EventDate', None)
        #fetch_session(1950,round_number)
        

#print(all_results)

session = fastf1.get_session(2023,1, 'R')
session.load()
print(session.results.columns)














"""


# combine all races
df = pd.concat(all_results, ignore_index=True)


# export
df.to_excel('f1_results_full.xlsx', index=False)

print("Saved to excel file f1_results_full.xlsx")

"""