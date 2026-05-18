import fastf1
import pandas as pd
import time

all_race_results = []
all_qualifying_results = []


wanted_race_columns = ['DriverNumber', 'FullName', 'Abbreviation', 'TeamName', 'Position', 'Status', 'Points']

def fetch_race_session(year,session_num, event_name, race_date):
    while True:
        try:
            #fetches the session and copies it to results dataframe for editing
            session = fastf1.get_session(year,session_num, 'R')
            session.load()
            results = session.results.copy()

            #add null results
            for col in wanted_race_columns:
                if col not in results.columns:
                    results[col] = None

            #get rid of columns not wanted 
            results = results[wanted_race_columns].copy()

            #add additional columns for session information
            results['RoundNumber'] = session_num
            results['EventName'] = event_name
            results['EventDate'] = race_date

            #adds results to list of all results
            all_race_results.append(results)
            break
        except Exception as e:
            print(f"FAILED: {year} Round {round_number}")
            print(f"Reason: {e}")
            print("Waiting 15 minutes before retry...\n")

            time.sleep(900)  # 900 seconds = 15 minutes








for year in range(1950, 1955):
    schedule = fastf1.get_event_schedule(year)
    for _, race in schedule.iterrows():
            round_number = race.get('RoundNumber', None)
            event_name = race.get('EventName', None)
            race_date = race.get('EventDate', None)
            try:
                fetch_race_session(year, round_number, event_name, race_date)

                print(f"Loaded {year} Round {round_number} - {event_name}")
                time.sleep(2)  # Sleep for 2 seconds to avoid hitting API rate limits

            except Exception as e:
                print(f"Failed {year} Round {round_number}: {e}")
            







# combine all races
df = pd.concat(all_race_results, ignore_index=True)


# export
df.to_excel('f1__race_results_full.xlsx', index=False)

print("Saved to excel file f1_race_results_full.xlsx")

