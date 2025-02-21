# nolint start: line_length_linter
library(tidyverse)
library(dplyr)
library(ggplot2)
library(languageserver)
library(viridis)
library(ggthemes)

# Load player_stats data
player_stats <- read.csv("combined_stats.csv")

# Calculate additional efficiency metrics
player_stats <- player_stats %>%
  mutate(
    FG_PCT = FGM / FGA,
    eFG_PCT = (FGM + 0.5 * FG3M) / FGA,
    TS_PCT = PTS / (2 * (FGA + 0.44 * FTA)),
    PER = (PTS + REB + AST + STL + BLK - (FGA - FGM) - (FTA - FTM) - TOV) / GP
  )

# Ensure SEASON_ID is treated as a factor
player_stats$SEASON_ID <- as.factor(player_stats$SEASON_ID)

# Filter data for seasons from 1970 onwards
player_stats <- player_stats %>%
  mutate(SEASON_YEAR = as.numeric(substr(SEASON_ID, 1, 4))) %>%
  filter(SEASON_YEAR >= 1970)

# Ensure PlayerName is treated as a factor with correct levels
player_stats$PlayerName <- factor(player_stats$PlayerName)

# Filter data for Tim Duncan and Anthony Davis with efficiency metrics
tim_duncan_eff <- player_stats %>%
  filter(PlayerName == "Tim Duncan") %>%
  group_by(SEASON_ID) %>%
  summarize(
    PlayerName = first(PlayerName),
    PTS = sum(PTS),
    REB = sum(REB),
    AST = sum(AST),
    STL = sum(STL),
    BLK = sum(BLK),
    GP = sum(GP),
    FG_PCT = mean(FG_PCT),
    eFG_PCT = mean(eFG_PCT),
    TS_PCT = mean(TS_PCT),
    PER = mean(PER)
  )

anthony_davis_eff <- player_stats %>%
  filter(PlayerName == "Anthony Davis") %>%
  select(SEASON_ID, PlayerName, PTS, REB, AST, STL, BLK, GP, FG_PCT, eFG_PCT, TS_PCT, PER)

# Combine data for Tim Duncan and Anthony Davis
combined_data <- rbind(tim_duncan_eff, anthony_davis_eff)

# Add a column to distinguish between the selected players and others
player_stats$PlayerGroup <- ifelse(player_stats$PlayerName %in% c("Tim Duncan", "Anthony Davis"), player_stats$PlayerName, "Other")

# Convert PlayerGroup to a factor *after* assigning values
player_stats$PlayerGroup <- factor(player_stats$PlayerGroup, levels = c("Tim Duncan", "Anthony Davis", "Other"))

# Remove rows with NA values in relevant columns
player_stats <- player_stats %>%
  filter(!is.na(SEASON_ID) & !is.na(FG_PCT) & !is.na(eFG_PCT) & !is.na(TS_PCT) & !is.na(PER))

# Remove outliers
player_stats <- player_stats %>%
  filter(PER >= 0 & PER <= 40) %>%
  filter(FG_PCT >= 0 & FG_PCT <= 1) %>%
  filter(eFG_PCT >= 0 & eFG_PCT <= 1) %>%
  filter(TS_PCT >= 0 & TS_PCT <= 1)

# Calculate league average pace and scoring average for each season
league_averages <- player_stats %>%
  group_by(SEASON_ID) %>%
  summarize(
    avg_pace = mean(GP), 
    avg_ppg = mean(PTS)
  )

print("League Averages:")
print(league_averages)

# Merge league averages back into player_stats
player_stats <- player_stats %>%
  left_join(league_averages, by = "SEASON_ID")

# Define baseline period
baseline_period <- c("1998-99", "1999-00", "2000-01", "2001-02", "2002-03", "2003-04", "2004-05", "2005-06", "2006-07", "2007-08")

# Get baseline pace and scoring average
baseline_pace <- league_averages %>% filter(SEASON_ID %in% baseline_period) %>% summarize(avg_pace = mean(avg_pace)) %>% pull(avg_pace)
baseline_ppg <- league_averages %>% filter(SEASON_ID %in% baseline_period) %>% summarize(avg_ppg = mean(avg_ppg)) %>% pull(avg_ppg)

print("Baseline Averages:")
print(paste("Baseline Pace:", baseline_pace))
print(paste("Baseline PPG:", baseline_ppg))

# Calculate adjustment factors
player_stats <- player_stats %>%
  mutate(
    pace_adjustment = baseline_pace / avg_pace,
    ppg_adjustment = baseline_ppg / avg_ppg
  )

print("Adjustment Factors:")
print(head(player_stats %>% select(SEASON_ID, pace_adjustment, ppg_adjustment), 10))

# Apply adjustments to Tim Duncan's stats only
tim_duncan_adjusted <- tim_duncan_eff %>%
  left_join(player_stats %>% select(SEASON_ID, pace_adjustment, ppg_adjustment), by = "SEASON_ID") %>%
  mutate(
    adjusted_pts = PTS * ppg_adjustment * pace_adjustment,
    adjusted_reb = REB * pace_adjustment,
    adjusted_ast = AST * pace_adjustment,
    adjusted_stl = STL * pace_adjustment,
    adjusted_blk = BLK * pace_adjustment
  )

print("Adjusted Stats for Tim Duncan:")
print(head(tim_duncan_adjusted %>% select(PlayerName, SEASON_ID, adjusted_pts, adjusted_reb, adjusted_ast, adjusted_stl, adjusted_blk), 10))

# Ensure unique rows for each season in tim_duncan_adjusted
tim_duncan_adjusted <- tim_duncan_adjusted %>%
  group_by(SEASON_ID) %>%
  summarize(
    adjusted_pts = sum(adjusted_pts),
    adjusted_reb = sum(adjusted_reb),
    adjusted_ast = sum(adjusted_ast),
    adjusted_stl = sum(adjusted_stl),
    adjusted_blk = sum(adjusted_blk)
  )

# Merge adjusted Tim Duncan stats back into player_stats
player_stats <- player_stats %>%
  left_join(tim_duncan_adjusted, by = "SEASON_ID", suffix = c("", "_adjusted"))

# Define color values
color_values <- c("Tim Duncan" = "#1a188e", "Anthony Davis" = "#9c1c27", "Other" = "gray50") # Viridis-inspired

# Plot FG%, eFG%, and TS% over seasons for Tim Duncan and Anthony Davis using area charts
ggplot(player_stats, aes(x = SEASON_ID, y = FG_PCT, group = PlayerName, color = PlayerGroup)) +
  geom_line(alpha = 0.5) +
  geom_line(data = combined_data, aes(x = SEASON_ID, y = FG_PCT, group = PlayerName, color = PlayerName), size = 1.2) +
  geom_point(data = combined_data, aes(x = SEASON_ID, y = FG_PCT, group = PlayerName, color = PlayerName), size = 3, alpha = 0.7) +
  labs(title = "Field Goal Percentage Over Seasons (Adjusted to 1998-2008 pace and scoring)",
       x = "Season",
       y = "FG%",
       color = "Player") +
  scale_color_manual(values = color_values) +
  theme_fivethirtyeight() +
  theme(axis.text.x = element_text(size = 4))

# Effective Field Goal Percentage
ggplot(player_stats, aes(x = SEASON_ID, y = eFG_PCT, group = PlayerName, color = PlayerGroup)) +
  geom_line(alpha = 0.5) +
  geom_line(data = combined_data, aes(x = SEASON_ID, y = eFG_PCT, group = PlayerName, color = PlayerName), size = 1.2) +
  geom_point(data = combined_data, aes(x = SEASON_ID, y = eFG_PCT, group = PlayerName, color = PlayerName), size = 3, alpha = 0.7) +
  labs(title = "Effective Field Goal Percentage Over Seasons (Adjusted to 1998-2008 pace and scoring)",
       x = "Season",
       y = "eFG%",
       color = "Player") +
  scale_color_manual(values = color_values) +
  theme_fivethirtyeight() +
  theme(axis.text.x = element_text(size = 4))

# True Shooting Percentage
ggplot(player_stats, aes(x = SEASON_ID, y = TS_PCT, group = PlayerName, color = PlayerGroup)) +
  geom_line(alpha = 0.5) +
  geom_line(data = combined_data, aes(x = SEASON_ID, y = TS_PCT, group = PlayerName, color = PlayerName), size = 1.2) +
  geom_point(data = combined_data, aes(x = SEASON_ID, y = TS_PCT, group = PlayerName, color = PlayerName), size = 3, alpha = 0.7) +
  labs(title = "True Shooting Percentage Over Seasons (Adjusted to 1998-2008 pace and scoring)",
       x = "Season",
       y = "TS%",
       color = "Player") +
  scale_color_manual(values = color_values) +
  theme_fivethirtyeight() +
  theme(axis.text.x = element_text(size = 4))

# Player Efficiency Rating
ggplot(player_stats, aes(x = SEASON_ID, y = PER, group = PlayerName, color = PlayerGroup)) +
  geom_line(alpha = 0.5) +
  geom_line(data = combined_data, aes(x = SEASON_ID, y = PER, group = PlayerName, color = PlayerName), size = 1.2) +
  geom_point(data = combined_data, aes(x = SEASON_ID, y = PER, group = PlayerName, color = PlayerName), size = 3, alpha = 0.7) +
  geom_smooth(data = combined_data, aes(x = SEASON_ID, y = PER, group = PlayerName, color = PlayerName), method = "loess", se = FALSE, linetype = "dashed", alpha = 0.5) +
  labs(title = "Player Efficiency Rating Over Seasons (Adjusted to 1998-2008 pace and scoring)",
       x = "Season",
       y = "PER",
       color = "Player") +
  scale_color_manual(values = color_values) +
  theme_fivethirtyeight() +
  theme(axis.text.x = element_text(size = 4))

# nolint end: line_length_linter