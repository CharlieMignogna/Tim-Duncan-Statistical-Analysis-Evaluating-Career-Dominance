# nolint start: line_length_linter

library(tidyverse)
library(dplyr)
library(ggplot2)
library(languageserver)
library(jsonlite)

# Load configuration
config <- fromJSON("config.json")
nba_stats_path <- config$nba_stats_path

# Read the CSV data
nba_data <- read_csv(file.path(nba_stats_path, 'combined_stats.csv'))

# Convert SEASON_ID to numeric and filter data from 1979 onwards
progress_data <- nba_data %>%
  mutate(SEASON_YEAR = as.numeric(substr(SEASON_ID, 1, 4))) %>%
  filter(SEASON_YEAR >= 1979)

# Filter data for Tim Duncan and AD
tim_duncan_data <- progress_data %>%
  filter(PlayerName == "Tim Duncan")

anthony_davis_data <- progress_data %>%
  filter(PlayerName == "Anthony Davis")

# Calculate average PTS, BLK, STL, REB, and AST for all players
all_players_avg_stats <- progress_data %>%
  group_by(PlayerName, SEASON_ID) %>%
  summarize(
    avg_points = mean(PTS, na.rm = TRUE),
    avg_blocks = mean(BLK, na.rm = TRUE),
    avg_steals = mean(STL, na.rm = TRUE),
    avg_rebounds = mean(REB, na.rm = TRUE),
    avg_assists = mean(AST, na.rm = TRUE),
  )

# Add a column to distinguish Tim Duncan and Anthony Davis from other players
all_players_avg_stats <- all_players_avg_stats %>%
  mutate(highlight = case_when(
    PlayerName == "Tim Duncan" ~ "Tim Duncan",
    PlayerName == "Anthony Davis" ~ "Anthony Davis",
    TRUE ~ "Other"
  ))

# Ensure SEASON_ID is a factor
all_players_avg_stats$SEASON_ID <- as.factor(all_players_avg_stats$SEASON_ID)
tim_duncan_data$SEASON_ID <- as.factor(tim_duncan_data$SEASON_ID)
anthony_davis_data$SEASON_ID <- as.factor(anthony_davis_data$SEASON_ID)

# Check for missing values
all_players_avg_stats <- all_players_avg_stats %>%
  filter(!is.na(avg_points) & !is.na(avg_blocks) & !is.na(avg_steals) & !is.na(avg_rebounds) & !is.na(avg_assists))

# Max avg for TD and AD
tim_duncan_max_points <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_points, with_ties = FALSE)
anthony_davis_max_points <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_points, with_ties = FALSE)

tim_duncan_max_blocks <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_blocks, with_ties = FALSE)
anthony_davis_max_blocks <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_blocks, with_ties = FALSE)

tim_duncan_max_steals <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_steals, with_ties = FALSE)
anthony_davis_max_steals <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_steals, with_ties = FALSE)

tim_duncan_max_rebounds <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_rebounds, with_ties = FALSE)
anthony_davis_max_rebounds <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_rebounds, with_ties = FALSE)

tim_duncan_max_assists <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_assists, with_ties = FALSE)
anthony_davis_max_assists <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_assists, with_ties = FALSE)

# Average points per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "grey", alpha = 0.5) + 
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_points, aes(x = SEASON_ID, y = avg_points, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_points, aes(x = SEASON_ID, y = avg_points, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Tim Duncan vs Anthony Davis", x = "Season", y = "Average Points per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Average blocks per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_blocks, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_blocks, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_blocks, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_blocks, aes(x = SEASON_ID, y = avg_blocks, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_blocks, aes(x = SEASON_ID, y = avg_blocks, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Blocks per Seasons", x = "Season", y = "Average Blocks per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Average steals per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_steals, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_steals, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_steals, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_steals, aes(x = SEASON_ID, y = avg_steals, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_steals, aes(x = SEASON_ID, y = avg_steals, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Steals per Seasons", x = "Season", y = "Average Steals per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Average rebounds per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_rebounds, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_rebounds, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_rebounds, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_rebounds, aes(x = SEASON_ID, y = avg_rebounds, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_rebounds, aes(x = SEASON_ID, y = avg_rebounds, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Rebounds per Seasons", x = "Season", y = "Average Rebounds per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Average assists per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_assists, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_assists, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_assists, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_assists, aes(x = SEASON_ID, y = avg_assists, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_assists, aes(x = SEASON_ID, y = avg_assists, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Assists per Seasons", x = "Season", y = "Average Assists per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Calculate average stats for Tim Duncan and Anthony Davis
tim_duncan_avg_points <- round(mean(tim_duncan_data$PTS), 2)
tim_duncan_avg_assists <- round(mean(tim_duncan_data$AST), 2)
tim_duncan_avg_rebounds <- round(mean(tim_duncan_data$REB), 2)
tim_duncan_avg_blocks <- round(mean(tim_duncan_data$BLK, na.rm = TRUE), 2)
tim_duncan_avg_steals <- round(mean(tim_duncan_data$STL, na.rm = TRUE), 2)

anthony_davis_avg_points <- round(mean(anthony_davis_data$PTS), 2)
anthony_davis_avg_assists <- round(mean(anthony_davis_data$AST), 2)
anthony_davis_avg_rebounds <- round(mean(anthony_davis_data$REB), 2)
anthony_davis_avg_blocks <- round(mean(anthony_davis_data$BLK, na.rm = TRUE), 2)
anthony_davis_avg_steals <- round(mean(anthony_davis_data$STL, na.rm = TRUE), 2)

# Print the averages
print(paste("Tim Duncan - Avg Points(per season):", tim_duncan_avg_points))
print(paste("Tim Duncan - Avg Assists(per season):", tim_duncan_avg_assists))
print(paste("Tim Duncan - Avg Rebounds(per season):", tim_duncan_avg_rebounds))
print(paste("Tim Duncan - Avg Blocks(per season):", tim_duncan_avg_blocks))
print(paste("Tim Duncan - Avg Steals(per season):", tim_duncan_avg_steals))

print(paste("Anthony Davis - Avg Points(per season):", anthony_davis_avg_points)) 
print(paste("Anthony Davis - Avg Assists(per season):", anthony_davis_avg_assists)) 
print(paste("Anthony Davis - Avg Rebounds(per season):", anthony_davis_avg_rebounds)) 
print(paste("Anthony Davis - Avg Blocks(per season):", anthony_davis_avg_blocks))
print(paste("Anthony Davis - Avg Steals(per season):", anthony_davis_avg_steals))
# nolint end: line_length_linter