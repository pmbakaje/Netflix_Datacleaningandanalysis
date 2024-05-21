# Netflix_Datacleaningandanalysis
Netflix_Datacleaningandanalysis

Netflix csv file is loaded in sql using right click on database in sql-->task-->import flat file-->loaded data and made changes to table based on requirement.

Title column containg other than english and special charcter hence data type consided as nvarchar.

Based on data created multiple table for country, director, listed_in and cast.

Handled missing value and duplicate values

Below Analysis done using netflix data
 1)  For each director count the no of movies and tv shows created by them in separate columns for directors who have created tv shows and 
     movies both
 2)  Which country has highest number of comedy movies
 3)  For each year (as per date added to netflix), which director has maximum number of movies release
 4)  What is average duration of movies in each genre
 5)  Find the list of directors who have created horror and comedy movies both.
     display director names along with number of comedy and horror movies directed by them 
