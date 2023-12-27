select * from covid_db..covid_deaths$
order by 3, 4

--SELECTING DATA
select location, date, total_cases, total_deaths, new_cases, population 
from covid_db..covid_deaths$
order by 1, 2

--total cases vs total deaths
--SHOW LIKELIHOOD OF PEOPLE DYING

select location, date, total_cases, total_deaths, 
(cast(total_deaths as float)/cast(total_cases as float))* 100 as death_percentage 
from covid_db..covid_deaths$
--where location like '%states%'
order by 1, 2
----------------------------------------------------------------------------------------------------

-- LOOKING FOR COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO THE POPULATION	
select location, population, max(total_cases) as HighestInfectionCount, 
max(cast(total_cases as int)/(population))*100 as populationInfected 
from covid_db..covid_deaths$
group by location, population
order by populationInfected desc

-- LOOKING FOR HIGHEST DEATH COUNT	
select location, max(total_deaths) as HighestDeathCount  
from covid_db..covid_deaths$
--where continent is not null
group by location
order by HighestDeathCount desc

----------------------------------------------------------------------------------

--Breaking things by continent
--SHOWING CONTINENT WITH HIGHEST DEATH COUNT 
select continent, max(total_deaths) as HighestDeathCount  
from covid_db..covid_deaths$
where continent is not null
group by continent
order by HighestDeathCount desc


--Global numbers-- total no. of cases vs deaths overall
select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)* 100 as death_percentage 
from covid_db..covid_deaths$
where continent is not null
--group by date
order by 1, 2


--EXPLORING COVID_VACCINATION DATA

select * from covid_db..covid_vaccination$

----Joined tables Covid_deaths and covid_vaccination to explore data further

--Looking at total population vs vaccinations
select * from covid_db..covid_deaths$ dea
JOIN covid_db..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from covid_db..covid_deaths$ dea
JOIN covid_db..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid_db..covid_deaths$ dea
JOIN covid_db..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from covid_db..covid_deaths$ dea
JOIN covid_db..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 from PopvsVac 

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPeopleVaccinated

Create table #PercentPeopleVaccinated
(
Continent nvarchar(255), 
location nvarchar (255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from covid_db..covid_deaths$ dea
JOIN covid_db..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPeopleVaccinated

Drop view if exists PercentPeopleVaccinated

--Creating view to store data to use later for visualizationS

USE covid_db
GO
Create View PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from covid_db..covid_deaths$ dea
JOIN covid_db..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 
Select * from PercentPeopleVaccinated





