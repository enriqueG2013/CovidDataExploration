--ENRIQUE GONZALEZ - COVID 19 DATA EXPLORATION

select * from dbo.covid_deaths;

--DATA EXPLORATION

--1) Total Cases, New Cases & Total Deaths
select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project].dbo.covid_deaths
order by 1,2;

--2)Total Cases vs Total Deaths in the US
--shows likelihood of dying if you contract covid in the US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from [Portfolio Project].dbo.covid_deaths
where location like '%States%'
order by 1,2;

--3) Total Cases vs Population
--shows percentage of population with covid in the US
select location, date, population, total_cases, (total_cases/population)*100 as 'Population Infected Percentage'
from [Portfolio Project].dbo.covid_deaths
where location like '%States%'
order by 1,2;

--4) Countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as 'Population Infected Percentage'
from [Portfolio Project].dbo.covid_deaths
group by location, population
order by 4 desc;

--5) Countries with Highest Death Count per Population
select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, 
	MAX((total_deaths/population)*100) as 'Population Death Percentage'
from [Portfolio Project].dbo.covid_deaths
where continent is not null
group by location, population
order by 2 desc;

--6) Continent with Highest Death Count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.covid_deaths
where continent is not null
group by continent
order by 2 desc;

--7) Continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount, 
	MAX((total_deaths/population)*100) as 'Population Death Percentage'
from [Portfolio Project].dbo.covid_deaths
where continent is not null
group by continent
order by 2 desc;


--8) Global Numbers
select sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.covid_deaths
where continent is not null
order by 1,2;

--9) Look at total population vs vaccinations
select a.continent, a.location, a.date, a.population, b.new_vaccinations,
	sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date)
	as RollingPeopleVaccinated
from [Portfolio Project].dbo.covid_deaths a
join [Portfolio Project].dbo.covid_vaccs b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
order by 2, 3;

--10) Create CTE for above

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select a.continent, a.location, a.date, a.population, b.new_vaccinations,
	sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date)
	as RollingPeopleVaccinated
from [Portfolio Project].dbo.covid_deaths a
join [Portfolio Project].dbo.covid_vaccs b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 from PopvsVac;


--11) Create Temp Table for above
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #percentPopulationVaccinated

select a.continent, a.location, a.date, a.population, b.new_vaccinations,
	sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date)
	as RollingPeopleVaccinated
from [Portfolio Project].dbo.covid_deaths a
join [Portfolio Project].dbo.covid_vaccs b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null

select *, (RollingPeopleVaccinated/population)*100 from #percentPopulationVaccinated;


--DATA VISUALIZATIONS


--1. Data Visulization 1 - Global Case vs Death Percentage
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercentage
from [Portfolio Project].dbo.covid_deaths
where continent is not null
order by 1,2;


--2. Data Visualization 2 - Total Death Count per Continent
select location, sum(cast(new_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.covid_deaths
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc;

--3. Data Visialization 3 - Global Infection rate
select location, population, max(total_cases) as HighestInfectionRate, max(total_cases/population) * 100 as PercentPopulationInfected
from [Portfolio Project].dbo.covid_deaths
group by location, population
order by PercentPopulationInfected desc;

--4. Data Visualization 4 - Percent Population Infected from Feb 2020 - Feb 2022
select location, population, date, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project].dbo.covid_deaths
group by location, population, date
order by PercentPopulationInfected;

