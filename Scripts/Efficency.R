# nolint start: line_length_linter

library(tidyverse)
library(dplyr)
library(readr)
library(jsonlite)

# Load configuration
config <- fromJSON("config.json")
nba_stats_path <- config$nba_stats_path

# Read the CSV data
nba_data <- read_csv(file.path(nba_stats_path, 'shooting_metrics.csv'))

# Filter data for Tim Duncan and Anthony Davis
highlight_players <- nba_data %>%
  filter(PlayerName %in% c("Tim Duncan", "Anthony Davis"))

# Filter data to include only seasons from 1979 onward (the year the 3-point line was introduced)
nba_data <- nba_data %>%
  filter(SEASON_ID >= "1979-80" & GP > 20)

highlight_players <- highlight_players %>%
  filter(SEASON_ID >= "1979-80" & GP > 20)

# Find the midpoint for labeling
tim_duncan_midpoint <- highlight_players %>% filter(PlayerName == "Tim Duncan") %>% slice(n() %/% 2 + 1)
anthony_davis_midpoint <- highlight_players %>% filter(PlayerName == "Anthony Davis") %>% slice(n() %/% 2 + 1)

# Plot eFG%
ggplot() +
  geom_line(data = nba_data %>% filter(!PlayerName %in% c("Tim Duncan", "Anthony Davis")), aes(x = SEASON_ID, y = `eFG%`, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = highlight_players %>% filter(PlayerName == "Tim Duncan"), aes(x = SEASON_ID, y = `eFG%`, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = highlight_players %>% filter(PlayerName == "Anthony Davis"), aes(x = SEASON_ID, y = `eFG%`, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_midpoint, aes(x = SEASON_ID, y = `eFG%`, label = "Tim Duncan"), color = "blue", vjust = -1.5) +
  geom_text(data = anthony_davis_midpoint, aes(x = SEASON_ID, y = `eFG%`, label = "Anthony Davis"), color = "red", vjust = -1.5) +
  labs(
    title = "Effective Field Goal Percentage (eFG%) of NBA Players by Season",
    x = "Season",
    y = "Effective Field Goal Percentage (eFG%)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Find the midpoint for labeling FG%
tim_duncan_midpoint_fg <- highlight_players %>% filter(PlayerName == "Tim Duncan") %>% slice(n() %/% 2 + 1)
anthony_davis_midpoint_fg <- highlight_players %>% filter(PlayerName == "Anthony Davis") %>% slice(n() %/% 2 + 1)

# Plot FG%
ggplot() +
  geom_line(data = nba_data %>% filter(!PlayerName %in% c("Tim Duncan", "Anthony Davis")), aes(x = SEASON_ID, y = `FG%`, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = highlight_players %>% filter(PlayerName == "Tim Duncan"), aes(x = SEASON_ID, y = `FG%`, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = highlight_players %>% filter(PlayerName == "Anthony Davis"), aes(x = SEASON_ID, y = `FG%`, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_midpoint_fg, aes(x = SEASON_ID, y = `FG%`, label = "Tim Duncan"), color = "blue", vjust = -1.5) +
  geom_text(data = anthony_davis_midpoint_fg, aes(x = SEASON_ID, y = `FG%`, label = "Anthony Davis"), color = "red", vjust = -1.5) +
  labs(
    title = "Field Goal Percentage (FG%) of NBA Players by Season",
    x = "Season",
    y = "Field Goal Percentage (FG%)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Find the midpoint for labeling TS%
tim_duncan_midpoint_ts <- highlight_players %>% filter(PlayerName == "Tim Duncan") %>% slice(n() %/% 2 + 1)
anthony_davis_midpoint_ts <- highlight_players %>% filter(PlayerName == "Anthony Davis") %>% slice(n() %/% 2 + 1)

# Plot TS%
ggplot() +
  geom_line(data = nba_data %>% filter(!PlayerName %in% c("Tim Duncan", "Anthony Davis")), aes(x = SEASON_ID, y = `TS%`, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = highlight_players %>% filter(PlayerName == "Tim Duncan"), aes(x = SEASON_ID, y = `TS%`, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = highlight_players %>% filter(PlayerName == "Anthony Davis"), aes(x = SEASON_ID, y = `TS%`, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_midpoint_ts, aes(x = SEASON_ID, y = `TS%`, label = "Tim Duncan"), color = "blue", vjust = -1.5) +
  geom_text(data = anthony_davis_midpoint_ts, aes(x = SEASON_ID, y = `TS%`, label = "Anthony Davis"), color = "red", vjust = -1.5) +
  labs(
    title = "True Shooting Percentage (TS%) of NBA Players by Season",
    x = "Season",
    y = "True Shooting Percentage (TS%)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Calculate career averages for Tim Duncan and Anthony Davis
tim_duncan_career_avg <- highlight_players %>%
  filter(PlayerName == "Tim Duncan") %>%
  summarize(
    career_avg_efg = mean(`eFG%`, na.rm = TRUE),
    career_avg_fg = mean(`FG%`, na.rm = TRUE),
    career_avg_ts = mean(`TS%`, na.rm = TRUE)
  )

anthony_davis_career_avg <- highlight_players %>%
  filter(PlayerName == "Anthony Davis") %>%
  summarize(
    career_avg_efg = mean(`eFG%`, na.rm = TRUE),
    career_avg_fg = mean(`FG%`, na.rm = TRUE),
    career_avg_ts = mean(`TS%`, na.rm = TRUE)
  )

# Print career averages
print(paste("Tim Duncan - Career Avg eFG%:", round(tim_duncan_career_avg$career_avg_efg, 2)))
print(paste("Tim Duncan - Career Avg FG%:", round(tim_duncan_career_avg$career_avg_fg, 2)))
print(paste("Tim Duncan - Career Avg TS%:", round(tim_duncan_career_avg$career_avg_ts, 2)))

print(paste("Anthony Davis - Career Avg eFG%:", round(anthony_davis_career_avg$career_avg_efg, 2)))
print(paste("Anthony Davis - Career Avg FG%:", round(anthony_davis_career_avg$career_avg_fg, 2)))
print(paste("Anthony Davis - Career Avg TS%:", round(anthony_davis_career_avg$career_avg_ts, 2)))

# nolint end: line_length_linter