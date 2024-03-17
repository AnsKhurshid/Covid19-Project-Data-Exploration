-- Selecting Data that we gonna use here

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2


-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Pakistan%'
order by 1, 2


-- Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentagePerPopulation
from CovidDeaths
order by 1, 2


-- Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as percentageHighestInfection
from CovidDeaths
where total_cases is not null
group by location, population
order by percentageHighestInfection desc

-- Countries with Highest Death Count per Population

Select location, Max(total_deaths) as TotalDeathCount
from CovidDeaths
where total_cases is not null
group by location
order by TotalDeathCount desc

-- By Continent

Select continent , Max(total_deaths) as TotalDeathCount
from CovidDeaths
where total_cases is not null
	and continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as totalCases, SUM(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2

Select date, SUM(new_cases) as totalCases, SUM(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2


-- Total Population vs Vaccinations

With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date)
	as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccination v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
Select * , (RollingPeopleVaccinated/population)*100 
From popvsvac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date)
	as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccination v
	on d.location = v.location
	and d.date = v.date

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


-- Creating View for later use

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date)
	as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccination v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null





