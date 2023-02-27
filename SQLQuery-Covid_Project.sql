--Covid Deaths/Covid Vaccinations SQL Project 
-- Selecting data

Use Covid_Death_Project
Go
select *
from dbo.Coviddeaths
where continent is not null
order by 3,4

Use Covid_Death_Project
Go
select *
from dbo.Covidvaccinations
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from Coviddeaths
where continent is not null
order by 1,2


--Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Coviddeaths
where continent is not null
and location like '%states%'
order by 1,2


-- Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Coviddeaths
where continent is not null
and location like '%states%'
order by 1,2

--Countries with Highest Rate Infection compared to Population

select location, population, Max(total_cases) as HighInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from Coviddeaths
Group by location, population
where continent is not null
order by PercentPopulationInfected desc


--Countries with the Highest Death Count per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from Coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Countries with the Highest Death Count per Population (by continent)

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from Coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Death Percentage

select sum(new_cases) as total_cases, sum(cast(new_deaths as Int)) as total_deaths, sum(cast(new_deaths as Int))/Sum(New_cases)* 100 as DeathPercentage
from Coviddeaths
where continent is not null
--Group by date
order by 1,2

--Global Death Percentage by date

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as Int)) as total_deaths, sum(cast(new_deaths as Int))/Sum(New_cases)* 100 as DeathPercentage
from Coviddeaths
where continent is not null
Group by date
order by 1,2

--Joining Covid Deaths Table and Covid Vaccinations Table

-- Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Covid_Death_Project..Coviddeaths dea
Join Covid_Death_Project..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3

--Total Population Vs Vaccinations using Rolling Count of Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from Covid_Death_Project..Coviddeaths dea
Join Covid_Death_Project..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Analyze data Using CTE
With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From Covid_Death_Project..Coviddeaths dea
Join Covid_Death_Project..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercenatageVaccinated
From PopvsVac



-- Analyze Date using a Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccintations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from Covid_Death_Project..Coviddeaths dea
Join Covid_Death_Project..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercenatageVaccinated
From #PercentPopulationVaccinated

--Create View for future visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from Covid_Death_Project..Coviddeaths dea
Join Covid_Death_Project..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null