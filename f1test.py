import fastf1
import pandas as pd
import time
import os

#change depending on which you want to save 
output_file = "f1_lap_data_2018-.csv"


wanted_race_columns = [
    'DriverNumber',
    'FullName',
    'TeamName',
    'Position',
    'Status',
    'Points']

wanted_qualifying_columns = [
    'DriverNumber', 
    'FullName', 
    'TeamName', 
    'Q1', 'Q2', 
    'Q3', 
    'Time', 
    'Position']



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



def fetch_quali_session(year, session_num, event_name):
    while True:
        try:
            # fetch session
            session = fastf1.get_session(year, session_num, 'Q')
            session.load()

            results = session.results.copy()

            if results is None or results.empty:
                print(f"SKIPPING EMPTY:  {year} Round {session_num} - {event_name}")
                break

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





# for year in range(2027, 2026):

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




def fetch_schedule(year):
    try:
        schedule = fastf1.get_event_schedule(year)
        schedule['Year'] = year

        #save into file
        file_exists = os.path.isfile(output_file)

        schedule.to_csv(
            output_file,
            mode='a',
            header=not file_exists,
            index=False)
        
        print(f"Saved Schedule {year}")
        time.sleep(1)
    except Exception as e:
        print(f"Failed {year} !!!")




def fetch_lap_data(round, year):
    try:
        session = fastf1.get_session(year, round, 'R')
        session.load()
        laps = session.laps

        # skip empty lap data
        if laps.empty:
            print(f"No lap data for {year} Round {round}")
            return

        #add metadata
        laps['Year'] = year
        laps['RoundNumber'] = round

        # saving data
        file_exists = os.path.isfile(output_file)
        laps.to_csv(
            output_file,
            mode='a',
            header=not file_exists,
            index=False
        )
        print(f"Saved laps {round}, {year}")

    except Exception as e:
        print(f"Failed Round {round}, {year}")
        print(e)

'''
for year in range(2018, 2026):

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
            print(f"Skipping non-race event: {event_name}")
            continue

        fetch_lap_data(round_number, year)

        # small delay between requests
        time.sleep(2)
'''


all_drivers = []

for year in range(2018, 2026):

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
            print(f"Skipping non-race event: {event_name}")
            continue

        try:
            session = fastf1.get_session(year, round_number, 'R')
            session.load()

            drivers = session.results[['Abbreviation', 'FullName']].copy()

            # remove duplicates from this session
            drivers = drivers.drop_duplicates()

            all_drivers.append(drivers)

            print(f"Loaded drivers for {year} Round {round_number}")

            time.sleep(2)

        except Exception as e:
            print(f"Failed {year} Round {round_number}")
            print(e)

# combine all sessions
driver_df = pd.concat(all_drivers, ignore_index=True)

# remove duplicates across all years
driver_df = driver_df.drop_duplicates()

# sort alphabetically
driver_df = driver_df.sort_values(by='Abbreviation')

# save to csv
driver_df.to_csv("driver_code_mapping.csv", index=False)

print("Saved driver mapping to driver_code_mapping.csv")



print("Done")
