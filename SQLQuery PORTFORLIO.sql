SELECT*
FROM [portfolio project 1].dbo.CovidDeaths$
ORDER BY 3, 4 

--checking the datasets i will be working with
SELECT *
FROM Vaccinations$
ORDER BY 3, 4 

--SELECTING THE DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [portfolio project 1].dbo.CovidDeaths$
ORDER BY location, date

-- TOTAL CASES Vs TOTAL DEATHS
 --percentage shows the likelihood of dying if you got infected with covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [portfolio project 1].dbo.CovidDeaths$
WHERE location like'%uganda%'
ORDER BY location, date

--TOTAL CASES Vs POPULATION
--percentage showing what % of the population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infection_Percentage
FROM [portfolio project 1].dbo.CovidDeaths$
WHERE location like'%uganda%'
ORDER BY location, date

--COUNTRIES WITH HIGHEST INFECTION RATE VS POPULATION
SELECT location, MAX(total_cases) AS Highest_total_cases, population, MAX((total_cases/population))*100 AS Infection_Percentage
FROM [portfolio project 1].dbo.CovidDeaths$
GROUP BY location, population
ORDER BY Infection_Percentage DESC

 --BREAK DOWN BY CONTINENT
SELECT location,MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM [portfolio project 1].dbo.CovidDeaths$
WHERE continent is null
GROUP BY location
order by Total_Death_Count desc

--Continents with highest death rate per population
SELECT continent,MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM [portfolio project 1].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc

 --GLOBAL NUMBERS
SELECT date, sum(new_cases)as Totalnewcases, sum(cast(new_deaths as int)) as totoalnewdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage--total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [portfolio project 1]..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

 
SELECT sum(new_cases)as Totalnewcases, sum(cast(new_deaths as int)) as totoalnewdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage--total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [portfolio project 1]..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

--POPULATION VS VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
FROM [portfolio project 1]..CovidDeaths$ dea
join [portfolio project 1]..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USING CTE
WITH populationvsvaccination( continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
from [portfolio project 1]..CovidDeaths$ dea
join [portfolio project 1]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
)
select*, (rollingpeoplevaccinated/population)*100
from populationvsvaccination

--TEMP TABLE

create table #Percentpopulationvaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric)

insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
from [portfolio project 1]..CovidDeaths$ dea
join [portfolio project 1]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
select*, (rollingpeoplevaccinated/population)*100
from #Percentpopulationvaccinated


--creating view for  visualisations
CREATE VIEW PercentPeopleVaccinated
AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
from [portfolio project 1]..CovidDeaths$ dea
join [portfolio project 1]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


--DROP VIEW PercentagePeopleVaccinated
SELECT*
FROM PercentPeopleVaccinated
