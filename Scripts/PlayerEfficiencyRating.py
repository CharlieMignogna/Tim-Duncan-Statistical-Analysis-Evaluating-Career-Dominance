from nba_api.stats.static import players 
from nba_api.stats.endpoints import playercareerstats, playergamelog, leaguedashplayerstats
import pandas as pd
import os
import time
from requests.exceptions import ReadTimeout

# get player ID based on player name
def get_player_id(player_name):
    player_dict = players.get_players()
    for player in player_dict:
        if player['full_name'] == player_name:
            return player['id']
    return None

# fetch player career stats (not needed here but might be useful in the future)
def fetch_player_stats(player_id):
    career = playercareerstats.PlayerCareerStats(player_id=player_id)
    career_df = career.get_data_frames()[0]
    return career_df

# fetch player game logs for a specific season with retry logic
def fetch_player_gamelog(player_id, season, retries=3, timeout=60):
    for i in range(retries):
        try:
            game_logs = playergamelog.PlayerGameLog(player_id=player_id, season=season, timeout=timeout)
            game_logs_df = game_logs.get_data_frames()[0]
            return game_logs_df
        except ReadTimeout:
            print(f"Read timeout occurred. Retrying {i+1}/{retries}...")
            time.sleep(5)  # wait for 5 seconds before retrying
    print(f"Failed to fetch game logs for player {player_id} in season {season} after {retries} retries.")
    return pd.DataFrame()  # return an empty DataFrame if all retries fail

# fetch league stats for a specific season with retry logic
def fetch_league_stats(season, retries=3, timeout=60):
    for i in range(retries):
        try:
            league_stats = leaguedashplayerstats.LeagueDashPlayerStats(season=season, timeout=timeout)
            league_stats_df = league_stats.get_data_frames()[0]
            return league_stats_df
        except ReadTimeout:
            print(f"Read timeout occurred. Retrying {i+1}/{retries}...")
            time.sleep(5)  # wait for 5 seconds before retrying
    print(f"Failed to fetch league stats for season {season} after {retries} retries.")
    return pd.DataFrame()  # return an empty DataFrame if all retries fail

# calculate unadjusted PER for a player in a specific season
def calculate_uPER(stats):
    # check for all columns 
    required_columns = ['PTS', 'FGM', 'FTM', 'FG3M', 'AST', 'REB', 'OREB', 'DREB', 'BLK', 'STL', 'FGA', 'FTA', 'TOV', 'MIN']
    for col in required_columns:
        if col not in stats:
            stats[col] = 0

    uPER = (stats['PTS'] + stats['FGM'] + stats['FTM'] + stats['FG3M'] + stats['AST'] + stats['REB'] + stats['OREB'] + stats['DREB'] + stats['BLK'] + stats['STL']
        - (stats['FGA'] - stats['FGM']) - (stats['FTA'] - stats['FTM']) - stats['TOV']) / stats['MIN']
    return uPER

# adjust PER for pace (pace being the number of possessions per 48 minutes)
def adjust_for_pace(uPER, team_pace, league_pace):
    return uPER * (league_pace / team_pace)

# normalize PER to league average PER
def normalize_PER(uPER, league_avg_PER):
    return uPER * (15 / league_avg_PER)

# calculate PER for a player in a specific season
def calculate_PER(player_name, season):
    # Get player ID
    player_id = get_player_id(player_name)
    if not player_id:
        print(f"Player {player_name} not found")
        return
    
    # Fetch player game logs for the season
    game_logs = fetch_player_gamelog(player_id, season)
    if game_logs.empty:
        print(f"No game logs found for {player_name} in season {season}")
        return None
    
    # Aggregate the stats from the game logs
    aggregated_stats = game_logs[['PTS', 'FGM', 'FTM', 'FG3M', 'AST', 'REB', 'OREB', 'DREB', 'BLK', 'STL', 'FGA', 'FTA', 'TOV', 'MIN']].sum()
    
    # Calculate unadjusted 
    uPER = calculate_uPER(aggregated_stats)
    print(f"Unadjusted PER (uPER): {uPER}")

    # Fetch league stats for the season
    league_stats = fetch_league_stats(season)
    if league_stats.empty:
        print(f"No league stats found for season {season}")
        return None

    # Calculate league averages
    if 'PACE' in league_stats.columns:
        league_pace = league_stats['PACE'].mean()
    else:
        # Calculate league pace if not directly available (using formula: league_pace = ((FGA + 0.44 * FTA - OREB + TOV) / MIN).mean() * 48)
        league_pace = ((league_stats['FGA'] + 0.44 * league_stats['FTA'] - league_stats['OREB'] + league_stats['TOV']) / league_stats['MIN']).mean() * 48  # Assuming 48 minutes per game
     
    if 'PER' in league_stats.columns:
        league_avg_PER = league_stats['PER'].mean()
    else:
        # Calculate league average PER using available data
        league_avg_PER = ((league_stats['PTS'] + league_stats['FGM'] + league_stats['FTM'] + league_stats['FG3M'] + league_stats['AST'] + league_stats['REB'] + league_stats['OREB'] + league_stats['DREB'] + league_stats['BLK'] + league_stats['STL']
            - (league_stats['FGA'] - league_stats['FGM']) - (league_stats['FTA'] - league_stats['FTM']) - league_stats['TOV']) / league_stats['MIN']).mean()

    print(f"League Pace: {league_pace}, League Avg PER: {league_avg_PER}")

    # Adjust and normalize PER 
    pace_adjusted_PER = adjust_for_pace(uPER, league_pace, league_pace)  
    normalized_PER = normalize_PER(pace_adjusted_PER, league_avg_PER)
    
    print(f"{player_name}'s PER: {normalized_PER}")

    # Create subfolder for game logs if it doesn't exist
    subfolder = 'game_logs'
    if not os.path.exists(subfolder):
        os.makedirs(subfolder)

    # Save data to CSV files in the subfolder
    game_logs.to_csv(os.path.join(subfolder, f"{player_name}_game_logs_{season}.csv"), index=False)

    return normalized_PER

def calculate_PER_for_all_seasons(player_name):
    player_id = get_player_id(player_name)
    if not player_id:
        print(f"Player {player_name} not found")
        return
    
    # Fetch player career stats to get the seasons played
    career_stats = fetch_player_stats(player_id)
    seasons = career_stats['SEASON_ID'].unique()
    
    per_by_season = []
    for season in seasons:
        per = calculate_PER(player_name, season)
        if per is not None:
            per_by_season.append({'Season': season, 'PER': per, 'Player': player_name})
    
    return pd.DataFrame(per_by_season)

# Calculate PER for Tim Duncan and Anthony Davis
tim_duncan_per = calculate_PER_for_all_seasons('Tim Duncan')
anthony_davis_per = calculate_PER_for_all_seasons('Anthony Davis')

# Combine the results and save to CSV
combined_per = pd.concat([tim_duncan_per, anthony_davis_per])
combined_per.to_csv('tim_duncan_anthony_davis_per.csv', index=False)