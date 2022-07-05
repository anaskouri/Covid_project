


--Looking closer into the CovidDeaths table

select *
from CovidDeaths
where continent is null
order by 3,4;

--looking closer into the CovidVaccinations table

select * 
from CovidVaccinations
order by 3,4

-- Select the Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2 desc;

-- Looking the total cases vs Total Deaths 
-- Likelihood of daying if you contract covid in The United States

select location, date, total_cases, total_deaths, 
                round((total_deaths/total_cases)*100,2) as pecentage_of_deaths
from CovidDeaths
where location = 'United States'
order by 1,2 desc;

-- Looking at Total Cases vs Population

select location, date, total_cases, population, 
                round((total_cases/population)*100,2) as pecentage_of_deaths_per_population
from CovidDeaths
where location = 'United States'
order by 1,2 desc;

-- Looking at Countries with highest infection rate compared to population
copy
(select location,round(population,2) as population,
       round(Max(total_cases),2) as HighestInfectionCount,
       Max(round((total_cases/population)*100,2)) as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc)
TO '/Users/anaskouri/Desktop/Covid-Project/tableau3.csv' DELIMITER ',' CSV HEADER;

copy
(select location,round(population,2) as population, date,
       round(Max(total_cases),2) as HighestInfectionCount,
       Max(round((total_cases/population)*100,2)) as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location, population,date
order by location,date)
TO '/Users/anaskouri/Desktop/Covid-Project/tableau5.csv' DELIMITER ',' CSV HEADER;

--shwoing countries with the highest death count per population

select location,
       Max(total_deaths) as TotalDeathcount
from CovidDeaths
where total_deaths is not null and continent is not null 
group by location
order by TotalDeathcount desc;

-- Lets break things down by continent 
-- showing the continents with the highest death count per population
select continent,
       Max(total_deaths) as TotalDeathcount
from CovidDeaths
where continent is not null 
group by continent
order by TotalDeathcount desc;

-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
       round((SUM(new_deaths)/SUM(new_cases))*100,2) as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2 desc;

---Total cases, Total_deaths, deathpercentage

COPY  
(select round(SUM(new_cases),0) as total_cases, round(SUM(new_deaths),0) as total_deaths,
       round((SUM(new_deaths)/SUM(new_cases))*100,2) as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2 desc)
TO '/Users/anaskouri/Desktop/Covid-Project/cases_deaths_world.csv' DELIMITER ',' CSV HEADER;

-- Total deaths group by continent

COPY  
(select location, round(sum(new_deaths),0) as TotalDeathsCount
from CovidDeaths
where continent is  null 
and location not in ('World','European Union','International','Low income',
					 'Lower middle income','High income','Upper middle income')
group by location
order by TotalDeathsCount desc)
to '/Users/anaskouri/Desktop/Covid-Project/totalDeaths_continent1.csv' DELIMITER ',' CSV HEADER;

-- Order by location 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) over (partition by dea.location)
from CovidDeaths as dea
join CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
where vac.new_vaccinations is not null and dea.continent is not null
order by 2,3;

-- Order by date and location 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
	   as RolllingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
where vac.new_vaccinations is not null and dea.continent is not null
order by 2,3;

--- Population vs vaccination 

with Popvsvac( continent, location,date, population, new_vaccinations,RolllingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
	   as RolllingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
where vac.new_vaccinations is not null and dea.continent is not null
order by 2,3
)
select *,round((RolllingPeopleVaccinated/population)*100,2) as percentage
from Popvsvac;


--Creating a view

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
	   as RolllingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
order by 2,3;

select * 
from PercentPopulationVaccinated


			  


