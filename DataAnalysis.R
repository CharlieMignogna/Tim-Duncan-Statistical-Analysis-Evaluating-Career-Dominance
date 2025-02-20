# nolint start: line_length_linter
install.packages("languageserver")
install.packages("tidyverse")

library(tidyverse)
library(dplyr)
library(ggplot2)
library(languageserver)

# load progress data
progress_data <- read.csv("combined_stats.csv")

# check the structure of the data
str(progress_data)


#convert SEASON_ID to numeric and filter data from 1970 onwards
progress_data <- progress_data %>%
  mutate(SEASON_YEAR = as.numeric(substr(SEASON_ID, 1, 4))) %>%
  filter(SEASON_YEAR >= 1970)

#filter data for Tim Duncan and AD
tim_duncan_data <- progress_data %>%
  filter(PlayerName == "Tim Duncan")

anthony_davis_data <- progress_data %>%
  filter(PlayerName == "Anthony Davis")

# calculate avg PPG for all players
all_players_avg_points <- progress_data %>%
  group_by(PlayerName, SEASON_ID) %>%
  summarise(avg_points = mean(PTS, na.rm = TRUE))

# Add a column to distinguish Tim Duncan and Anthony Davis from other players
all_players_avg_points <- all_players_avg_points %>%
  mutate(highlight = case_when(
    PlayerName == "Tim Duncan" ~ "Tim Duncan",
    PlayerName == "Anthony Davis" ~ "Anthony Davis",
    TRUE ~ "Other"
  ))


all_players_avg_points$SEASON_ID <- as.factor(all_players_avg_points$SEASON_ID)

tim_duncan_data$SEASON_ID <- as.factor(tim_duncan_data$SEASON_ID)
anthony_davis_data$SEASON_ID <- as.factor(anthony_davis_data$SEASON_ID)


# basic descriptive statistics
tim_duncan_avg_points <- mean(tim_duncan_data$PTS)
tim_duncan_avg_assists <- mean(tim_duncan_data$AST)
tim_duncan_avg_rebounds <- mean(tim_duncan_data$REB)

anthony_davis_avg_points <- mean(anthony_davis_data$PTS)
anthony_davis_avg_assists <- mean(anthony_davis_data$AST)
anthony_davis_avg_rebounds <- mean(anthony_davis_data$REB)

print(paste("Time Duncan - Avg Points(per season):", tim_duncan_avg_points))
print(paste("Time Duncan - Avg Assists(per season):", tim_duncan_avg_assists))
print(paste("Time Duncan - Avg Rebounds(per season):", tim_duncan_avg_rebounds))

print(paste("Anthony Davis - Avg Points(per season):", anthony_davis_avg_points)) # nolint: line_length_linter.
print(paste("Anthony Davis - Avg Assists(per season):", anthony_davis_avg_assists)) # nolint: line_length_linter.
print(paste("Anthony Davis - Avg Rebounds(per season):", anthony_davis_avg_rebounds)) # nolint: line_length_linter.

# max avg for TD and AD
tim_duncan_max <- all_players_avg_points %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_points)
anthony_davis_max <- all_players_avg_points %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_points)



# Plot average points per seasons
ggplot() +
  geom_line(data = all_players_avg_points %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "grey", alpha = 0.5) + 
  geom_line(data = all_players_avg_points %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_points %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max, aes(x = SEASON_ID, y = avg_points, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max, aes(x = SEASON_ID, y = avg_points, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Points per Season", x = "Season", y = "Points per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot points per seasons for Tim Duncan and Anthony Davis
ggplot() +
  geom_line(data = tim_duncan_data, aes(x = SEASON_ID, y = PTS, color = "Tim Duncan", group = PlayerName), size = 1.5) +
  geom_line(data = anthony_davis_data, aes(x = SEASON_ID, y = PTS, color = "Anthony Davis", group = PlayerName), size = 1.5) +
  geom_text(data = tim_duncan_data %>% slice_max(PTS), aes(x = SEASON_ID, y = PTS, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_data %>% slice_max(PTS), aes(x = SEASON_ID, y = PTS, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Points per Seasons", x = "Season", y = "Points per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# nolint end: line_length_linter
