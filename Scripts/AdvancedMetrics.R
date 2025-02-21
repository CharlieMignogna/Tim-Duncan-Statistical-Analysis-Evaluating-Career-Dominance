install.packages("languageserver")
install.packages("tidyverse")

library(tidyverse)
library(dplyr)
library(ggplot2)
library(languageserver)

per_data <- read.csv("tim_duncan_anthony_davis_per.csv")

per_data$Season <- as.factor(per_data$Season)

ggplot(per_data, aes(x = Season, y = PER, color = Player)) +
  geom_point(size = 3) +
  geom_line(aes(group = Player)) +
  labs(title = "PER of Tim Duncan and Anthony Davis by Season",
       x = "Season",
       y = "PER") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
