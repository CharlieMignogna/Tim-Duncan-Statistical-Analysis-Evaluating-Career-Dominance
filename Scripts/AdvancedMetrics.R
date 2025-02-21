install.packages("languageserver")
install.packages("tidyverse")

library(tidyverse)
library(dplyr)
library(ggplot2)
library(languageserver)

player_stats <- read.csv("combined_stats.csv")

tim_duncan_data <- progress_data %>%
  filter(PlayerName == "Tim Duncan")

anthony_davis_data <- progress_data %>%
  filter(PlayerName == "Anthony Davis")
