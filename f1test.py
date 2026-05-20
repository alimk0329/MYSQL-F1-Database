import fastf1
import pandas as pd
import time
import os

output_file = "f1_qualifying_results_full.csv"

wanted_race_columns = [
    'DriverNumber',
    'FullName',
    'TeamName',
    'Position',
    'Status',
    'Points'
]

wanted_qualifying_columns = ['DriverNumber',
    'FullName', 'TeamName',
    'Q1', 'Q2', 'Q3', 'Time', 'Position']



def fetch_race_session(year, session_num, event_name):

    while True:
        try:
            # fetch session
            session = fastf1.get_session(year, session_num, 'R')
            session.load()

            results = session.results.copy()

            # add missing columns
            for col in wanted_race_columns:
                if col not in results.columns:
                    results[col] = None

            # keep wanted columns
            results = results[wanted_race_columns].copy()

            # add metadata
            results['RoundNumber'] = session_num
            results['EventName'] = event_name
            results['Year'] = year

            # append to CSV
            file_exists = os.path.isfile(output_file)

            results.to_csv(
                output_file,
                mode='a',
                header=not file_exists,
                index=False
            )

            print(f"SAVED: {year} Round {session_num} - {event_name}")

            break

        except Exception as e:

            # permanent invalid event
            if "testing event" in str(e).lower():
                print(f"Skipping testing event: {event_name}")
                break

            print(f"FAILED: {year} Round {session_num}")
            print(f"Reason: {e}")
            print("Waiting 15 minutes before retry...\n")

            time.sleep(900)



session = fastf1.get_session(2025, 1, 'Q')
session.load()
print(session.results)


def fetch_quali_session(year, session_num, event_name):
    while True:
        try:
            # fetch session
            session = fastf1.get_session(year, session_num, 'Q')
            session.load()

            results = session.results.copy()

            # add missing columns
            for col in wanted_qualifying_columns:
                if col not in results.columns:
                    results[col] = None

            # keep wanted columns
            results = results[wanted_qualifying_columns].copy()

            # add metadata
            results['RoundNumber'] = session_num
            results['EventName'] = event_name
            results['Year'] = year

            # append to CSV
            file_exists = os.path.isfile(output_file)

            results.to_csv(
                output_file,
                mode='a',
                header=not file_exists,
                index=False
            )

            print(f"SAVED: {year} Round {session_num} - {event_name}")

            break

        except Exception as e:

            # permanent invalid event
            if "testing event" in str(e).lower():
                print(f"Skipping testing event: {event_name}")
                break

            print(f"FAILED: {year} Round {session_num}")
            print(f"Reason: {e}")
            print("Waiting 15 minutes before retry...\n")

            time.sleep(900)









for year in range(1950, 2026):

    # retry schedule loading
    while True:
        try:
            schedule = fastf1.get_event_schedule(year)
            break

        except Exception as e:
            print(f"Failed loading schedule for {year}")
            print(e)

            print("Retrying in 15 minutes...\n")

            time.sleep(900)

    for _, race in schedule.iterrows():

        round_number = race.get('RoundNumber', None)
        event_name = race.get('EventName', None)

        # skip invalid/testing events
        if round_number is None or round_number == 0:
            print(f"Skipping non-qualifying event: {event_name}")
            continue

        fetch_quali_session(year, round_number, event_name)

        # small delay between requests
        time.sleep(2)


print("Done")
