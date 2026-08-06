# Beatles_Project
> *A Deep Dive into the Legendary Beatles Discography.*

---

## ⚙️ Concepts Used

- [X] Exploratory Data Analysis (EDA)
- [X] SQL Analysis / Querying
- [X] Dashboard / Data Visualization
- [ ] Data Pipeline / ETL
- [ ] Predictive Modelling / Machine Learning
- [X] Data Cleaning / Wrangling
- [X] End-to-End (multiple of the above)
- [ ] Other: ___________

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Objectives](#2-objectives)
3. [Project Tools](#3-project-tools)
4. [Repository Structure](#4-repository-structure)
5. [Data Workflow](#5-data-workflow)
6. [Data Model & Schema](#6-data-model--schema)
7. [Insights/Recommendations](#7-insights)
8. [Assumptions, Limitations, & Enhancements](#8-limitations--enhancements)
9. [Deliverables](#9-deliverables)
10. [Author](#10-author)

---

## 1. Project Overview

I was thinking of ideas for a data project, and figured that I love the Beatles. Why not explore their music more deeply? 
Over the course of basically 7 years, the band dropped hundreds of songs (many of them considered classics), 12+ albums (with at least half being some of the greatest albums ever), and pioneered
many things that we take for granted in music. The band made pop music into an art form, and in my opinion, are the greatest thing to ever happen to pop culture. 

First, I searched for a free dataset on Kaggle that I could clean and use for EDA. I found several, but I landed on one that provided many interesting metrics as well as opportunities for cleaning.

I based the exploration around the question, what tangible statistics live under the magic of the Beatles discography? Here is the final dashboard I ended up with.
[`Final Dashboard`](https://public.tableau.com/views/BeatleProj/BeatlesDeepDive?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

But how did I get here?
I cleaned the data thoroughly in MySQL. I expand on this in the Data Workflow section, but this included fixing duplicate values, certain weird/null/empty values, and removing useless columns.

Once the cleaning section was over and the data had no issues, I spent time thinking about which metrics were most relevant to analyze. I was particularly interested in songwriters and their respective contributions to the band (e.g. Paul vs John), which albums were most popular, which songs were critically acclaimed the most, what genres they most often used, etc. Maybe most of all, I was interested
in exploring how their music changed year by year. 

I discovered some pretty cool stuff from the data. These are expanded upon in the Insights section, but they boil down to the following: 1. Their music became less happy, less energetic, and mostly
less acoustic over time. 2. Every Songwriter was important, but McCartney wrote the most hits by most metrics. Some may argue that Lennon or Harrison's tunes were musically more mature though,
it is subjective. 3. There is a mythology to the Lennon-McCartney partnership (that they were constantly writing face to face), but in reality most songs were written separately from one another with minor additions by the other at times. 4. Their music was always artistically fresh, and they somehow always retained their massive fan base. 

---

## 2. Objectives


- **Primary Objective:** Uncover the most interesting statistics of the Beatles' discography.
- **Secondary Objective 1:** Explore which songwriter had the greatest work in the band.
- **Secondary Objective 2:** Explore how their music changed over the course of the 60s.
- **Secondary Objective 3:** Explore which songs/albums are/were most popular and which songs were most lauded critically.

---

## 3. Project Tools

### Tools & Technologies

| Category | Tool(s) Used |
|----------|-------------|
| Data Storage | [MySQL, CSV files] |
| Data Processing | [SQL] |
| Analysis | [SQL, Tableau] |
| Visualization | [Tableau] |
| Version Control | [Git / GitHub] |
| Documentation | [Markdown, Comments in MySQLWorkbench] |

---

## 4. Repository Structure

```
[project-root]/
│
├── data/                            # Data files
│   ├── raw/                         # Original, unmodified source data, folder contains file with raw data
│   ├── cleaned/                     # Cleaned and transformed data, folder contains file with cleaned data
│   
│
├── sql-queries/                     # SQL files 
│   ├── proj2.sql                    # A complete MySQL file containing in-depth comments, data cleaning, and data exploration queries
│   ├── README.md                    # More info about the SQL section
│   
│
├── dashboard /                      # Tableau section
│   ├── beatle_dash_screenshot.png   # Screenshot of the final dashboard
│   ├── README.md                    # Link to the interactive Tableau dashboard and more info
│   ├── Tableau_Embed_Code           # The Tableau embed code to open the dash in an external webpage
│
│
│
└── README.md                        # You are here
```


---

## 5. Data Workflow


1. **Source:** Data came from Kaggle, specifically [here](https://www.kaggle.com/datasets/devedzic/the-beatles-songs-dataset?select=The+Beatles+songs+dataset+285x45+v0.csv).
2. **Ingestion:** I took this dataset, downloaded it as a CSV file, and put it into MySQL, specifically MySQLWorkbench. The dataset started as 285 rows, one row for each Beatles song. 
3. **Cleaning:** For full thought processes, see the proj2.sql file in the sql-queries folder. First and foremost, I wanted to only analyze songs between 62-70 (or really 62-69 in terms of recording), and only songs that were on studio albums, singles, or on Past Masters (i.e. no demos, deluxe songs, other takes, etc.). This took up a lot of the cleaning to whittle this down. Other than that, I removed columns that were unhelpful, remade certain columns to be more broad, and did many other granular changes. See the SQL File with comments for more explanations and motivations.
6. **Analysis:** I did preliminary analysis with SQL queries, but the bulk of the analysis came with the ability to visualize things in depth with Tableau. This is where I played around with dimensions, measures, filters, and marks to bring the data alive. 
7. **Output:** The results boil down to a cleaned and queried data table, with an interactive and concise dashboard to toy with and draw conclusions from. 

---

## 6. Data Model & Schema

### Most Relevant Columns

### Dataset / Table: `students_staging1`

| Field Name | Data Type | Description | 
|------------|-----------|-------------|
| `Title` | string | Unique Song Title |
| `Year` | string | Year of Recording | 
| `Popularity` | int | Spotify Stream Metric | 
| `Valence` | float/double | Happy-sounding metric | 
| `primaryWriter` | string | Who was the main/sole songwriter? | 
| `newGenre` | int | Main genre of given song | 
| `Top50____` | int | Ranking in several Top 50 Lists |

### Most other columns are self-explanatory

> **Row count (approx.):** 285 raw, 211 clean.

Note: The only other table I worked with in SQL was the initial raw data (called 'songs'). I turned this into songs1 immediately upon starting the processing. 



---

## 7. Insights


**Insight 1: Their music changed a ton in a short amount of time.**
Looking at their style evolution, we see that energy and positivity mostly dropped over the course of their time as a band. Songs became more introspective, more complex, 
and more sentimental. Acousticness sways a bit, mostly dropping but also rebounding especially with the White Album in 1968 (as many of the songs were written acoustically in India). 


**Insight 2: Every songwriter matters!**
McCartney typically wrote the bigger songs both in terms of modern streams and chart success back in the day. When looking at critical acclaim though, each of the three 
main songwriters have several songs atop many lists. Even Harrison wrote iconic tunes like Here Comes the Sun and Something. Notice also how songwriters like Harrison
tried different genres than someone like McCartney for instance, with McCartney's songs usually being more positive and pop-esque while Harrison was exploring Indian and 
Psychedelic music more often. 

**Insight 3: The Lennon-McCartney moniker was mostly inaccurate.**
A decision was made early on to label every song by the main songwriting duo as "Lennon-McCartney" as they often wrote together. This quickly became inaccurate, as the 
vast majority of songs were written mainly by one of them, and then either added on or not by the other. So songs like Yesterday, Let it Be, Hey Jude, and Blackbird are 
McCartney staples, while songs like Strawberry Fields Forever, Come Together, Lucy in the Sky with Diamonds, and In My Life are Lennon staples. It was interesting to explore 
this notion in the data, and I even did outside research to confirm who the primary songwriter was on certain songs. There were only maybe 15-20 true Lennon AND McCartney songs
written face to face. It also helps as a slicer/filter on the data to isolate the dashboard by songwriter to see how their styles differed person to person. 

**Insight 4: Their discography is wildly consistent, inventive, and daring.**
People argue endlessly about what their best album or song is. What is clear objectively is how consistently great their music was (especially in the later half in my opinion). The data shows
us that in terms of popularity and genre, their albums were consistently unique while remaining popular to mass audiences. With the likes of Abbey Road, Revolver, Sgt. Pepper's, Rubber Soul, and The White Album ("The Beatles"), their later music was varied, explored different genres, and never seemed stale. But their earlier years were not too shabby either, with classics like A Hard Day's Night and Please Please Me. All this in 7 years! Just unbelievable. 


---

## 8. Limitations, & Enhancements

### Limitations and Enhancements
- The dataset from Kaggle was good but certainly confusing at times. The entire analysis was done at the whim of how accurate/thorough the dataset was. 
- Using Tableau Public is potentially limited, as the paid app has more expansive features. It ultimately did its job though quite well. 
- In my opinion this is not really a limitation, but some would argue that I should have used more of the songs (e.g. Deluxe songs, demos, songs released after the band broke up), but I felt
  it muddied up the data a bit. It was easier sticking to a canon of songs that are inarguably songs of theirs.  


---

## 9. Deliverables

| Deliverable | Location |
|-------------|-------------|
| Full SQL File  | [`SQL File`](sql-queries/proj2.sql) |
| Final Tableau Dashboard | [`Final Dashboard`](https://public.tableau.com/views/BeatleProj/BeatlesDeepDive?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) |
| Full Tableau Workbook | [`Full Workbook`](dashboard/BeatleProj.twb) |
| Dashboard Image | [`Dashboard Image`](dashboard/beatle_dash_screenshot.png) |
| Cleaned Dataset | [`Cleaned Dataset`](data/cleaned/cleaned_beatle_data.csv) |

---

## 10. Author

**[Cooper Phillips]**
[Data Analyst]

- 🔗 [www.linkedin.com/in/cooper-phillips-a84404328]
- 💼 [(https://github.com/CooperP7)]
- 📧 [cooperjp1221@gmail.com]

---

*Last updated: [August 2026]*

