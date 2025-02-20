from nba_api.stats.static import players 
from nba_api.stats.endpoints import playercareerstats
import pandas as pd
import time
import os

# Get all players
all_players = players.get_players()


# Initialize an empty list to hold the data frames
all_players_stats = []

# Load progress if exists
if os.path.exists('progress.csv'):
    progress_df = pd.read_csv('progress.csv')
    processed_players = set(progress_df['PLAYER_ID'])
    all_players_stats.append(progress_df)
else:
    processed_players = set()



# Loop through each player and get their career stats
for player in all_players:
    if player['id'] in processed_players:
        continue
    try:
        player_id = player['id']
        player_stats = playercareerstats.PlayerCareerStats(player_id=player_id).get_data_frames()[0]
        player_stats['PlayerName'] = player['full_name']
        player_stats['PLAYER_ID'] = player_id
        all_players_stats.append(player_stats)
        print(f"Retrieved stats for {player['full_name']}")

        total_processed = len(all_players_stats) - 1 + len(processed_players)
        percentage = int(total_processed / len(all_players) * 100)
        print("item: ", total_processed, "of", len(all_players), " ", percentage, "%")
        
        # Save progress periodically
        if len(all_players_stats) % 100 == 0:
            progress_df = pd.concat(all_players_stats, ignore_index=True)
            progress_df.to_csv('progress.csv', index=False)
            print("Progress saved")
        
        time.sleep(0.5)  # Increase sleep time to avoid rate limits
    except Exception as e:
        print(f"Could not retrieve stats for player {player['full_name']}: {e}")
        time.sleep(5)  # Wait longer before retrying

# Combine all player stats into a single DataFrame
combined_stats = pd.concat(all_players_stats, ignore_index=True)

# Save the combined stats to a CSV file
combined_stats.to_csv('combined_stats.csv', index=False)

# Remove progress file after completion
if os.path.exists('progress.csv'):
    os.remove('progress.csv')