SELECT *
  FROM [portfolio].[dbo].[total death]
  where continent is not null
  ORDER BY 1,2

  SELECT [location]
      ,[date]
      ,[population]
      ,[new_cases]
      ,[total_deaths]
	  ,total_cases_per_mill,
	  (1000000*(total_deaths/total_cases_per_mill)) AS deathpercentge
  FROM [portfolio].[dbo].[total death]
  WHERE [location] like '%israel%' and continent is not null

  --ORDER BY 2 desc


  ----  SELECT [location]
  ----    ,[date]
	 ---- , population
	 ---- ,(1000000*total_cases_per_mill/population/100) as DeathPercentege
  ----    ,[total_deaths]
	 ---- ,(total_cases_per_mill*1000000) as total_cases
  ----FROM [portfolio].[dbo].[total death]
  ----WHERE [location] like '%israel%'
  ----ORDER BY 2 

  --highest infections with countries

  --select MAX(total_cases_per_mill) as max_total_cases_per_mill,AVG(total_cases_per_mill) as AVG_total_cases_per_mill FROM portfolio..[total death]
  
 --SELECT  Location, population,total_cases_per_mill ,total_cases_per_mill ,(1000000*total_cases_per_mill/population)*100 AS percentPopulationInfected
 --FROM [portfolio]..[total death]


 SELECT  location, population, MAX(1000000*total_cases_per_mill) as HighestInfectionCount,  MAX((1000000*total_cases_per_mill/population)*100) AS PercentPopulationInfected
 FROM [portfolio]..[total death]
 where continent is not null
 GROUP BY location, population 
 ORDER BY PercentPopulationInfected DESC

 --countries with the highest death count per population
 CREATE VIEW CountriesHighesDeaths AS
  SELECT  location, MAX( cast(total_deaths as int)) as TotalDeathsCount
 FROM [portfolio]..[total death]
 where continent is not null
 GROUP BY location
 --ORDER BY TotalDeathsCount desc
 

 --by content 
  CREATE VIEW ContinentvsTotaldeathsCount2 AS

   SELECT  location , MAX( cast(total_deaths as int)) as TotalDeathsCount
 FROM [portfolio]..[total death]
 where continent is null --and continent  like '%income'
 GROUP BY location
-- ORDER BY TotalDeathsCount desc

 CREATE VIEW ContinentvsTotaldeathsCount AS
    SELECT  continent , MAX( cast(total_deaths as int)) as TotalDeathsCount
 FROM [portfolio]..[total death]
 where continent is  not null --and continent  like '%income'
 GROUP BY continent
 --ORDER BY TotalDeathsCount desc



 --global numbers

   SELECT  [date] ,sum(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths,
   100*SUM(CAST(new_deaths AS int))/sum(new_cases) as DeathPercentage --total_cases_per_mill,
   --(1000000*(total_deaths/total_cases_per_mill)) AS deathpercentge
  FROM [portfolio].[dbo].[total death]
  WHERE continent is not null
  GROUP BY [date]
ORDER BY 1


--total population vs vaccnation 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) 
AS RolingPeopleVaccinated
FROM portfolio..[total death] as dea 
JOIN portfolio..[covid vaccs] as vac
ON dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- use CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations, RolingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) 
AS RolingPeopleVaccinated
FROM portfolio..[total death] as dea 
JOIN portfolio..[covid vaccs] as vac
ON dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
) 
SELECT *, (RolingPeopleVaccinated/population)*100
FROM PopvsVac



--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RolingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) 
AS RolingPeopleVaccinated
FROM portfolio..[total death] as dea 
JOIN portfolio..[covid vaccs] as vac
ON dea.location = vac.location and
dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (RolingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--creating view for viss

create view  PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) 
AS RolingPeopleVaccinated
FROM portfolio..[total death] as dea 
JOIN portfolio..[covid vaccs] as vac
ON dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3