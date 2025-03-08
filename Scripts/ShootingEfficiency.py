import pandas as pd

nba_data = pd.read_csv('../Stats_Data/combined_stats.csv')

# Calculate shooting metrics for all players
nba_data['eFG%'] = (nba_data['FGM'] + 0.5 * nba_data['FG3M']) / nba_data['FGA']
nba_data['FG%'] = nba_data['FGM'] / nba_data['FGA']
nba_data['TS%'] = nba_data['PTS'] / (2 * (nba_data['FGA'] + 0.44 * nba_data['FTA']))

# Save the results to a new CSV file
nba_data.to_csv('../Stats_Data/shooting_metrics.csv', index=False)

print("Shooting metrics calculated and saved to shooting_metrics.csv")