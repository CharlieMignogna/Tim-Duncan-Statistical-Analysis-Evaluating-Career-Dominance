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
  filter(PlayerName == "Tim Duncan")

anthony_davis_eff <- player_stats %>%
  filter(PlayerName == "Anthony Davis")

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

# Define color values
color_values <- c("Tim Duncan" = "#1a188e", "Anthony Davis" = "#9c1c27", "Other" = "gray50") # Viridis-inspired
# Plot FG%, eFG%, and TS% over seasons for Tim Duncan and Anthony Davis using area charts
ggplot(player_stats, aes(x = SEASON_ID, y = FG_PCT, group = PlayerName, color = PlayerGroup)) +
  geom_line(alpha = 0.5) +
  geom_line(data = combined_data, aes(x = SEASON_ID, y = FG_PCT, group = PlayerName, color = PlayerName), size = 1.2) +
  geom_point(data = combined_data, aes(x = SEASON_ID, y = FG_PCT, group = PlayerName, color = PlayerName), size = 3, alpha = 0.7) +
  labs(title = "Field Goal Percentage Over Seasons",
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
  labs(title = "Effective Field Goal Percentage Over Seasons",
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
  labs(title = "True Shooting Percentage Over Seasons",
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
  labs(title = "Player Efficiency Rating Over Seasons",
       x = "Season",
       y = "PER",
       color = "Player") +
  scale_color_manual(values = color_values) +
  theme_fivethirtyeight() +
  theme(axis.text.x = element_text(size = 4))


# nolint end: line_length_linter