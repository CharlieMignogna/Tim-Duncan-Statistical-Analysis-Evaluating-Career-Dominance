# nolint start: line_length_linter
install.packages("languageserver")
install.packages("tidyverse")

library(tidyverse)
library(dplyr)
library(ggplot2)
library(languageserver)

# load progress data
progress_data <- read.csv("combined_stats.csv")


#convert SEASON_ID to numeric and filter data from 1970 onwards
progress_data <- progress_data %>%
  mutate(SEASON_YEAR = as.numeric(substr(SEASON_ID, 1, 4))) %>%
  filter(SEASON_YEAR >= 1970)

#filter data for Tim Duncan and AD
tim_duncan_data <- progress_data %>%
  filter(PlayerName == "Tim Duncan")

anthony_davis_data <- progress_data %>%
  filter(PlayerName == "Anthony Davis")

# Calculate average PPG, BLK, and STl for all players
all_players_avg_stats <- progress_data %>%
  group_by(PlayerName, SEASON_ID) %>%
  summarize(
    avg_points = mean(PTS, na.rm = TRUE),
    avg_blocks = mean(BLK, na.rm = TRUE),
    avg_steals = mean(STL, na.rm = TRUE),
    avg_rebounds = mean(REB, na.rm = TRUE),
    avg_assists = mean(AST, na.rm = TRUE),
    avg_fg_pct = mean(FG_PCT, na.rm = TRUE),
    avg_fg3_pct = mean(FG3_PCT, na.rm = TRUE),
    avg_ft_pct = mean(FT_PCT, na.rm = TRUE)
  )

# Add a column to distinguish Tim Duncan and Anthony Davis from other players
all_players_avg_stats <- all_players_avg_stats %>%
  mutate(highlight = case_when(
    PlayerName == "Tim Duncan" ~ "Tim Duncan",
    PlayerName == "Anthony Davis" ~ "Anthony Davis",
    TRUE ~ "Other"
  ))


all_players_avg_stats$SEASON_ID <- as.factor(all_players_avg_stats$SEASON_ID)
tim_duncan_data$SEASON_ID <- as.factor(tim_duncan_data$SEASON_ID)
anthony_davis_data$SEASON_ID <- as.factor(anthony_davis_data$SEASON_ID)


# basic descriptive statistics

tim_duncan_avg_points <- round(mean(tim_duncan_data$PTS), 2)
tim_duncan_avg_assists <- round(mean(tim_duncan_data$AST), 2)
tim_duncan_avg_rebounds <- round(mean(tim_duncan_data$REB), 2)

anthony_davis_avg_points <- round(mean(anthony_davis_data$PTS), 2)
anthony_davis_avg_assists <- round(mean(anthony_davis_data$AST), 2)
anthony_davis_avg_rebounds <- round(mean(anthony_davis_data$REB), 2)

print(paste("Tim Duncan - Avg Points(per season):", tim_duncan_avg_points))
print(paste("Tim Duncan - Avg Assists(per season):", tim_duncan_avg_assists))
print(paste("Tim Duncan - Avg Rebounds(per season):", tim_duncan_avg_rebounds))

print(paste("Anthony Davis - Avg Points(per season):", anthony_davis_avg_points)) 
print(paste("Anthony Davis - Avg Assists(per season):", anthony_davis_avg_assists)) 
print(paste("Anthony Davis - Avg Rebounds(per season):", anthony_davis_avg_rebounds)) 

# max avg for TD and AD
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

tim_duncan_max_fg_pct <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_fg_pct, with_ties = FALSE)
anthony_davis_max_fg_pct <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_fg_pct, with_ties = FALSE)

tim_duncan_max_fg3_pct <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_fg3_pct, with_ties = FALSE)
anthony_davis_max_fg3_pct <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_fg3_pct, with_ties = FALSE)

tim_duncan_max_ft_pct <- all_players_avg_stats %>% filter(PlayerName == "Tim Duncan") %>% slice_max(avg_ft_pct, with_ties = FALSE)
anthony_davis_max_ft_pct <- all_players_avg_stats %>% filter(PlayerName == "Anthony Davis") %>% slice_max(avg_ft_pct, with_ties = FALSE)
# Plot average points per seasons
ggplot() +
  geom_line(data = all_players_avg_points %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "grey", alpha = 0.5) + 
  geom_line(data = all_players_avg_points %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_points %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_points, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max, aes(x = SEASON_ID, y = avg_points, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max, aes(x = SEASON_ID, y = avg_points, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Tim Duncan vs Anthony Davis", x = "Season", y = "Average Points per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# average points per seasons
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

# average blocks per seasons
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

# average steals per seasons
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

# average rebounds per seasons
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

# average assists per seasons
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

tim_duncan_avg_fg_pct <- round(mean(tim_duncan_data$FG_PCT, na.rm = TRUE), 2)
tim_duncan_avg_fg3_pct <- round(mean(tim_duncan_data$FG3_PCT, na.rm = TRUE), 2)
tim_duncan_avg_ft_pct <- round(mean(tim_duncan_data$FT_PCT, na.rm = TRUE), 2)
anthony_davis_avg_fg_pct <- round(mean(anthony_davis_data$FG_PCT, na.rm = TRUE), 2)
anthony_davis_avg_fg3_pct <- round(mean(anthony_davis_data$FG3_PCT, na.rm = TRUE), 2)
anthony_davis_avg_ft_pct <- round(mean(anthony_davis_data$FT_PCT, na.rm = TRUE), 2)
print(paste("Tim Duncan - Avg FG_PCT(per season):", tim_duncan_avg_fg_pct))
print(paste("Tim Duncan - Avg FG3_PCT(per season):", tim_duncan_avg_fg3_pct))
print(paste("Tim Duncan - Avg FT_PCT(per season):", tim_duncan_avg_ft_pct))
print(paste("Anthony Davis - Avg FG_PCT(per season):", anthony_davis_avg_fg_pct))
print(paste("Anthony Davis - Avg FG3_PCT(per season):", anthony_davis_avg_fg3_pct))
print(paste("Anthony Davis - Avg FT_PCT(per season):", anthony_davis_avg_ft_pct))


# Plot average FG_PCT per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_fg_pct, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_fg_pct, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_fg_pct, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_fg_pct, aes(x = SEASON_ID, y = avg_fg_pct, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_fg_pct, aes(x = SEASON_ID, y = avg_fg_pct, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Field Goal Percentage per Season", x = "Season", y = "Average FG_PCT per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot average FG3_PCT per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_fg3_pct, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_fg3_pct, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_fg3_pct, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_fg3_pct, aes(x = SEASON_ID, y = avg_fg3_pct, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_fg3_pct, aes(x = SEASON_ID, y = avg_fg3_pct, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Three-Point Field Goal Percentage per Season", x = "Season", y = "Average FG3_PCT per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot average FT_PCT per seasons
ggplot() +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Other"), aes(x = SEASON_ID, y = avg_ft_pct, group = PlayerName), color = "grey", alpha = 0.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Tim Duncan"), aes(x = SEASON_ID, y = avg_ft_pct, group = PlayerName), color = "blue", size = 1.5) +
  geom_line(data = all_players_avg_stats %>% filter(highlight == "Anthony Davis"), aes(x = SEASON_ID, y = avg_ft_pct, group = PlayerName), color = "red", size = 1.5) +
  geom_text(data = tim_duncan_max_ft_pct, aes(x = SEASON_ID, y = avg_ft_pct, label = "Tim Duncan"), color = "blue", vjust = -1) +
  geom_text(data = anthony_davis_max_ft_pct, aes(x = SEASON_ID, y = avg_ft_pct, label = "Anthony Davis"), color = "red", vjust = -1) +
  labs(title = "Free Throw Percentage per Season", x = "Season", y = "Average FT_PCT per Season") +
  scale_color_manual(values = c("Tim Duncan" = "blue", "Anthony Davis" = "red", "Other" = "grey")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# nolint end: line_length_linter