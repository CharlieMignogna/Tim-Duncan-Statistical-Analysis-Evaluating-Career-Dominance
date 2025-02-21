Charlie Mignogna

Methods Used:
Descriptive Statistics
Inferential Statistics
Data Visualization
Predictive Modeling

Technologies:
Python
R
pandas
ggplot2


# Tim Duncan vs. Anthony Davis Analysis - "You Have No Idea How Good Tim Duncan Was"



preface:

A video has started to go viral recently of a group of guys talking about basketball, one of them suggests that Anthony Davis is a better version of Tim Duncan and almost immeadiatly another guys yells out in pure dissapointment "You have no idea how good Tim duncan was"  - here I am going to try to prove that Tim Duncan is indeed better than this poor guy thinks he is, using data analytics and statistical analysis


"...now remove the points, lets talk just about their game - their offensive game. bro. Anthony Davis. 3 point shot, mid range, 
can put the ball on the floor, he can do turnarounds, he has one of the best footworks inside the NB-"

"YOU HAVE NO IDEA HOW GOOD TIM DUNCAN WAS OH MY GOD I CANT BELIEVE I AM HEARING THIS"



## I. Basic Stats

Starting out with the most basic of stats that I could pull from an api and do a simple analysis on - season averages
![SeasonAverages](Images/SeasonAverages.png)

We can go further however and plot these averages and compare visually each player agianst each other, and the rest of the NBA

![AvgPtsPerSeason](Images/AveragePointsPerSeason.png)
![AvgBlksPerSeason](Images/AverageBlocksPerSeason.png)
![AvgRebPerSeason](Images/AverageReboundPerSeason.png)
![AvgStealsPerSeason](Images/AverageStealsPerSeason.png)
![AvgAstPerSeason](Images/AverageAssistsPerSeason.png)

Numeriacal Averages:

## Tim Duncan's Average Stats per Season
- **Points:** 1394.53     
- **Assists:** 222.37
- **Rebounds:** 794.26
- **Blocks:** 158.9
- **Steals:** 53.95

## Anthony Davis's Average Stats per Season
- **Points:** 1328.7
- **Assists:** 141.6
- **Rebounds:** 590.33
- **Blocks:** 126.07
- **Steals:** 72.13


Statistical Comparison:
This basic data (per season stat averages) we see Tim Duncan has slightly higher averages than Anthony Davis in points, assists, rebounds, and blocks - and AD leads in steals.

It is crutial to understand that these are career averages. Duncans later years signifigantly impacted his scoring average, as Duncan aged he took a step back from being an offensive force (not to say he couldnt still be one) and focused on defencs, play-making, leadership, and mentoring younger players. His rebound and block numbers also somewhat declined in his later years but Duncan's defensive impact remained high throughout his career. Duncan's prime scoring averages would be notably higher than his career average.

Davis, being younger, is much closer to his prime. His career averages are less diluted by a signifigant decline in production due to age. However, his averages will likely decrease as he ages.

## Key take away (Season averages)
Duncan's career averages are a product of a long and highly successful career, including a period of decline in offensive output as he aged.  This "dilution" is particularly noticeable in his scoring average.  Davis's numbers are likely more representative of his prime, but it's important to remember that his career is still ongoing, and his stats could change significantly.  A true comparison requires looking at prime performance for both players, rather than just career averages


## I(a). Shooting

Now, I'm going to take a look at how each player performed when it came to making shots. To start well focus on, once again, season averages

## Tim Duncan
- **FG%:** 50%
- **FG3%:** 14%
- **FT%:** 70%

## Anthony Davis
- **FG%:** 53%
- **FG3%:** 30%
- **FT%%:** 78%

# brief analysis of career shooting averages
These reveal that Anthony Davis seems to be the more efficient scorer of the two, as he slightly higher averages in field goal percentage and free throw percentage and a signifigantly higher 3-point percentage. 


Davis appears to be the more efficient scorer overall, particularly due to his superior three-point and free-throw shooting. While Duncan was a highly efficient scorer in his own right, especially in the mid-range, Davis's ability to stretch the floor and convert free throws makes him statistically the more efficient scorer.  However, once again, it's important to remember that these are career averages.  Duncan's prime scoring efficiency was likely higher than his career average due to the decline in his athleticism and role later in his career.  Furthermore, context is important.  Duncan's role in the Spurs' system was different than Davis's role on his teams.  Duncan was often a facilitator and defensive anchor, whereas Davis has been more of a primary scoring option. I'll go more into detail on this later.

![FG%](Images/FG_PCT.png)
![FT%](Images/FT_PCT.png)
![FG3%](Images/FG3_PCT.png)


## II. Advanced Metrics 

Now I am going to go beyond the most basic stats of each player and gather a more nuanced view at each of their performances in the NBA.

# Player Efficency Rating (PER)
