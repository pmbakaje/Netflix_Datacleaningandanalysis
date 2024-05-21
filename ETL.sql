select*from netflix_raw  where show_id='s5023'

--remove duplicate
select show_id,count(*) from netflix_raw 
group by show_id
having count(*)>1

--making show_id as primary key
--alter table netflix_raw  add  constraint spq primary key(show_id)

sp_help [netflix_raw]
--remove duplicate title of similar type
select*from netflix_raw  where concat(upper(title),type) in(
select concat(upper(title),type) from netflix_raw 
group by concat(upper(title),type)
having count(*)>1)
order by title

with cte as(
select*
,ROW_NUMBER() over(partition by type,title order by show_id) as rn
from netflix_raw)

select show_id,type,title,cast(date_added as date) as date_added,release_year,rating
,case when duration is null then rating else duration end as duration
,description into netflix
from cte where rn=1


--------------------------------------------------------------------
--new table for listed_in, director, country, cast

--director
select show_id, trim(value) as director
into netflix_director from
 netflix_raw cross apply string_split(director,',')

 select*from netflix_director

 --country
 select show_id, trim(value) as country
into netflix_country from
 netflix_raw cross apply string_split(country,',')

 select*from netflix_country

 --cast
  select show_id, trim(value) as cast
into netflix_cast from
 netflix_raw cross apply string_split(cast,',')

 select*from netflix_cast

 ---
select show_id, trim(value) as genre
into netflix_genre from
 netflix_raw cross apply string_split(listed_in,',')

 select*from netflix_genre



 ------------------------------------------------------------------------
 ---missimg values based on director previous film release we are adding country
 insert into netflix_country
 select show_id,m.country
 from netflix_raw nr
 join (select director,country from netflix_country nc
 join netflix_director nd on nc.show_id=nd.show_id
 group by director,country) m on nr.director=m.director
 where nr.country is null
 order by show_id

 select director,country from netflix_country nc
 join netflix_director nd on nc.show_id=nd.show_id
 group by director,country

 ---------------------------------------------------------------------------------------
 ---duration
 select*from netflix_raw where duration is null


 ----------------final table------------------------------------------
 select*from netflix



 ------SQL questions
 /*1  for each director count the no of movies and tv shows created by them in separate columns 
for directors who have created tv shows and movies both */

select director
,count(case when type='Movie' then n.show_id end) as no_of_movie
,count(case when type='TV Show' then n.show_id end) as no_of_tvshow
from netflix_director as nd
join netflix n on nd.show_id=n.show_id
group by director
having COUNT(distinct type)>1

--2 which country has highest number of comedy movies 
select top 1 nc.country,COUNT(n.show_id) as no_of_movies
from netflix n
join netflix_country nc on n.show_id=nc.show_id
join netflix_genre ng on n.show_id=ng.show_id
where ng.genre='Comedies' and n.type='Movie'
group by nc.country
order by no_of_movies desc

--3 for each year (as per date added to netflix), which director has maximum number of movies released
;with cte as(
select YEAR(date_added) as nyear,nd.director,COUNT(n.show_id) as no_of_movie from netflix n
join netflix_director nd on n.show_id=nd.show_id
where n.type='Movie'
group by YEAR(date_added),nd.director)
,cte2 as(
select*
,ROW_NUMBER() over(partition by nyear order by no_of_movie desc ,director) as rn
from cte)
select nyear,director,no_of_movie from cte2 where rn=1


----4 what is average duration of movies in each genre
select ng.genre,avg(cast(REPLACE(duration,' min','') as int)) as avg_duration from netflix_genre ng
join netflix n on ng.show_id=n.show_id
where n.type='Movie'
group by ng.genre


--5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 

select director
,count(case when genre='Comedies' then n.show_id end) as no_of_comedimovie
,count(case when genre='Horror Movies' then n.show_id end) as no_of_horrrormovie
from netflix_genre ng
join netflix_director nd on ng.show_id=nd.show_id
join netflix n on n.show_id=ng.show_id
where ng.genre in ('Comedies' , 'Horror Movies') and n.type='Movie'
group by director
having COUNT(distinct ng.genre)=2


select*from netflix_raw where director like '%Banjong Pisanthanakun%'
