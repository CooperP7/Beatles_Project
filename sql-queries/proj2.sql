SELECT * FROM songs;
# We are going to clean up this data before moving it to Tableau to make a dashboard. 

# STAGE 1 SET RAW DATA ASIDE

# We want to create a staging table of data that we will actually work with, 
# so we do not mess up original data.

# CREATES A STAGING TABLE, THE ONE I WILL WORK WITH
CREATE TABLE songs1 
LIKE songs;

INSERT songs1
SELECT * 
FROM songs;

SELECT * FROM songs1;


# STAGE 2 FIX/REMOVE DUPLICATES

# There may be duplicates in numerical columns like charts/tempo etc., or various categorical columns like moods/genre etc., the duplicates that matter are the titles or URIs of the songs. 

# Songs with same title, but different listening on Spotify
Select Title, COUNT(*) 
FROM songs1 
GROUP BY Title  HAVING COUNT(*) > 1
ORDER BY COUNT(*);

# There are none! Let's check URI just in case
Select URI, COUNT(*) 
FROM songs1 
GROUP BY URI  HAVING COUNT(*) > 1
ORDER BY COUNT(*);

# No duplicates! 

# STAGE 3, STANDARDIZE VALUES -> FIX ISSUES 

# We only care about the songs released during the Beatles' actual span as a band, 1962-1970
# We have 285 values, but there are only 213 official Beatles songs (according to Wikipedia) that were actually released in their span as a band
# How can we remove these straggler songs? First we can find songs not in that span of time and remove them


SELECT Title, Year
FROM songs1
WHERE Year NOT BETWEEN 1962 AND 1970
ORDER BY Year;

# We get 18 rows, we can remove these (8 of these have no year attached, but a quick search online tells us that these are clearly not canon Beatles songs that we want to analyze)

DELETE FROM songs1
WHERE Year NOT BETWEEN 1962 AND 1970;


# We also can group songs by album, as songs in "Live at the BBC", for example, probably do not belong in this

SELECT  Album, Year, COUNT(*)
FROM songs1
GROUP BY Album
ORDER BY Year;

# We have 23 different albums here, but we should only have 14 core catalogue albums (studio LPs plus past masters compilation) 
# Anthology albums, deluxes, live recordings can all be removed

DELETE FROM songs1
WHERE Album LIKE "%Deluxe%" OR Album = "Anthology%" OR Album = "Live at the BBC" OR 
Album = "On Air – Live at the BBC Volume 2" OR Album = "On Air - Live at the BBC (Vol.2)";

# There is also one slot with no album listed, let's find it

SELECT  Title
FROM songs1
WHERE Album = "";

# Let's remove this as well

DELETE FROM songs1
WHERE Album = "";

# We see that the white album has 31 songs when it should have 30, let's figure this out
SELECT  Title
FROM songs1
WHERE Album = "The Beatles";

# There is a demo still! Let's remove it

DELETE FROM songs1
WHERE Title = "Circles - Esher Demo";

# We also have an album called "Rock 'n' Roll Music", with a song called "Slow Down". We want to put that song in the Past Masters album. 

UPDATE songs1
SET Album = "Past Masters (Vols. 1 & 2 / Remastered)"
WHERE Album = "Rock 'n' Roll Music";

# COOL, Now we have 211 values. We are only missing two songs that the band did in German from 1964, but these are fine to not include. 

# "I Me Mine" was technically recorded in early 1970 (without John) but conceived of about a year earlier, so I am going to consider this a 1969 song
# because there are no other 1970 songs in this. 
UPDATE songs1
SET Year = "1969"
WHERE Title = "I Me Mine";

# There are several columns in this table that I consider most interesting to analyze. One of those is Genre.
# The Beatles played around with many genres in their music, but this column is far too cluttered and there are multiple genres listed
# for each song, which I dislike. I am simply going to strip everything after the first comma for each cell in this column so that 
# only one main genre for each song is listed. I will make a new column for this. 

SELECT Genre, Count(*) FROM songs1
GROUP BY Genre 
ORDER BY Count(*), Year;

SELECT Genre AS orig, TRIM(substring_index(Genre, ",", 1)) AS newGenre, COUNT(*)
FROM songs1
GROUP BY newGenre
ORDER BY Count(*);
# See the difference between these two queries? The newGenre column is much more simple and concise. 

# The descriptive categorical columns like genre, styles, moods, themes, are all like this and have this issue. Let's change
# all of them in this same way. 
ALTER TABLE songs1
ADD newGenre TEXT AFTER Moods, ADD newMood TEXT AFTER Moods, ADD newTheme TEXT AFTER Moods, ADD newStyle TEXT AFTER Moods;

UPDATE songs1
SET newGenre = substring_index(Genre, ",", 1),
 newMood = substring_index(Moods, " ", 1),
 newStyle = substring_index(Styles, ",", 1),
 newTheme = substring_index(Themes, ",", 1);

# Looks way better! We will likely get rid of the old columns later. 

# Let's fix the wonky songwriters column. We will make a new column that looks for the primary songwriter of the songs. 
# So, a song labeled "Lennon, with McCartney" will just be deemed a Lennon song. 


ALTER TABLE songs1
ADD primaryWriter TEXT AFTER `Songwriter(s)`;

UPDATE songs1
SET primaryWriter = `Songwriter(s)`;


UPDATE songs1
SET primaryWriter = "Other"
WHERE Cover = "Y";

# How does it look now? 
SELECT primaryWriter, COUNT(*)
FROM songs1
GROUP BY primaryWriter
ORDER BY COUNT(*);


# How about we remove everything after the comma for the column in cases where the word "with" is included (i.e. to isolate the main songwriter).
UPDATE songs1
SET primaryWriter = substring_index(`Songwriter(s)`, ",", 1)
WHERE `Songwriter(s)` LIKE "%with%";

# It looks way better now, there is a mistake with a straggling "Lennon with McCartney" song with no comma. 
UPDATE songs1
SET primaryWriter = "Lennon"
WHERE primaryWriter = "Lennon with McCartney";

# Let's also make a primaryVocals column

ALTER TABLE songs1
ADD primaryVocals TEXT AFTER `Lead vocal(s)`;
UPDATE songs1
SET primaryVocals = `Lead vocal(s)`;

#Check how it looks initially
SELECT Title, primaryVocals, COUNT(*)
FROM songs1
GROUP BY primaryVocals
ORDER BY primaryVocals;

# We can fix the issues in the following ways.
UPDATE songs1
SET primaryVocals = CASE 
    WHEN `Lead vocal(s)` = 'Starkey (Best)' THEN 'Starkey'
    WHEN `Lead vocal(s)` = "" THEN 'None'
    WHEN `Lead vocal(s)` LIKE '%with%' THEN SUBSTRING_INDEX(`Lead vocal(s)`, ',', 1)
	WHEN `Lead vocal(s)` LIKE '% %' AND `Lead vocal(s)` != "Lennon and McCartney" THEN "More than 2 vocalists"
    ELSE `Lead vocal(s)`
END;
# Looks good now.

# Let's make a calculated column for Duration to make it in terms of minutes rather than second count. 
ALTER TABLE songs1
ADD durationMin DOUBLE AFTER Duration;

UPDATE songs1 
SET durationMin = ROUND(Duration / 60.0, 2);

# Let's map the Key to actual musical keys rather than numbers. 
# I first confirmed online which numbers corresponded to which musical keys. 
# I will do the same thing for minor and major keys.

UPDATE songs1
SET `Key` = CASE `Key`
    WHEN '0' THEN 'C' WHEN '1' THEN 'C#/Db' WHEN '2' THEN 'D' WHEN '3' THEN 'D#/Eb' WHEN '4' THEN 'E' WHEN '5' THEN 'F' 
    WHEN '6' THEN 'F#/Gb' WHEN '7' THEN 'G' WHEN '8' THEN 'G#/Ab' WHEN '9' THEN 'A' WHEN '10' THEN 'A#/Bb' WHEN '11' THEN 'B'
    ELSE `Key` 
END; 
UPDATE songs1
SET `Mode` = CASE `Mode`
    WHEN '0' THEN 'Minor' 
    WHEN '1' THEN 'Major' 
    ELSE `Mode` 
END; 

# STAGE 4: REMOVE COLUMNS IF NEED BE

# This is quite a convoluted dataset with 45 columns and 285 rows. We want to pinpoint what the 
# important columns are, clean up the important ones, remove the useless ones, etc.
SELECT * FROM songs1;
# We can remove the URI, Album debut, Other releases, Genre, Styles, Themes, Moods, Instrumentalness, Liveness, Speechiness, Duration at the very least
# These columns are either useless or have been made better with newer columns
ALTER TABLE songs1 
DROP COLUMN URI, DROP COLUMN `Album debut`, DROP COLUMN `Other releases`, DROP COLUMN Genre, DROP COLUMN Styles, DROP COLUMN Themes,DROP COLUMN Moods,
DROP COLUMN Instrumentalness, DROP COLUMN Liveness, DROP COLUMN Speechiness, DROP COLUMN Duration;

# STAGE 5: NULL/BLANK VALUES

# First, in the Cover column, non-covers should have "N" because covers have "Y". 
UPDATE songs1
SET Cover = "N"
WHERE Cover = "";

# The final cleaning we will do is to put 0 in for empty cells in the Weeks columns. 

UPDATE songs1 SET `Weeks on chart in UK (The Guardian)` = "0" WHERE `Weeks on chart in UK (The Guardian)` = "";
UPDATE songs1 SET `Weeks at No1 in UK (The Guardian)` = "0" WHERE `Weeks at No1 in UK (The Guardian)` = "";
UPDATE songs1 SET `Weeks at No1 (Billboard)` = "0" WHERE `Weeks at No1 (Billboard)` = "";





# CLEANING IS DONE, Let's do some analytical queries. 

SELECT * FROM songs1;
# The goal here is to pick apart some metrics that I will later focus on while visualizing this in Tableau. This includes exploring who the more prolific songwriter(s) were, 
# how the band's musical stylings changed year by year, what their biggest hits were, how they innovated and explored different genres, etc. 


# How did their music change year by year?
SELECT 
    Year,
    COUNT(*) AS song_count,
    ROUND(AVG(Valence), 2) AS happy,
    ROUND(AVG(Energy), 2) AS energy,
    ROUND(AVG(Acousticness), 2) AS acoustic,
    ROUND(AVG(Popularity), 2) AS avgPopular,
	ROUND(AVG(durationMin), 2) AS avgTime
FROM songs1
GROUP BY Year
ORDER BY Year ASC;

# Songs tended to get sadder, less acoustic, less energetic, and longer in duration. 

# Which writer wrote the most and wrote the biggest hits?
SELECT 
	primaryWriter, 
	COUNT(*) AS written, 
	ROUND(AVG(Popularity), 1) AS avgPopular, 
	SUM(CASE WHEN `Weeks at No1 (Billboard)` > 0 THEN 1 ELSE 0 END) AS num1hits, 
	SUM(`Weeks at No1 (Billboard)`) AS num1weeks
FROM songs1
GROUP BY primaryWriter
ORDER BY written DESC;

# Paul wrote the bigger hits generally. 


# What keys/modes were most common? 
SELECT `Key`, Mode, COUNT(*) AS songCount
FROM songs1
GROUP BY `Key`, Mode
ORDER BY songCount DESC;

#Major clearly more used than minor keys. 


# Biggest hits by chart success? 
SELECT Title, `Weeks at No1 (Billboard)`
FROM songs1
WHERE `Weeks at No1 (Billboard)` > 0
ORDER BY `Weeks at No1 (Billboard)` DESC;

# Biggest hits by Spotify streams? 
SELECT Title, Popularity
FROM songs1
ORDER BY Popularity DESC
LIMIT 20;

# Charts does not equal streams! Songs are received now differently than they were in the 60s.

# Genre Breakdown
SELECT newGenre, COUNT(*) AS songCount, ROUND(AVG(Energy), 2) AS energy, ROUND(AVG(Loudness), 2) AS loud, ROUND(AVG(Acousticness), 2) AS acoustic
FROM songs1
GROUP BY newGenre
HAVING COUNT(*) >= 3
ORDER BY songCount DESC;

# Clearly rock is the dominant general genre, with explorations into folklore and psychedelia. 


# All done, time to move it to Tableau. 
