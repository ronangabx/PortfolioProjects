-- Reference data
Select location, date, total_cases, new_cases, total_deaths, population
From covid..CovidDeaths
Where continent is not null
Order by 1,2


-- COVID Mortality Rate
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality_rate
From covid..CovidDeaths
Where continent is not null
Order by 1,2


-- Percent Population Infected with COVID
Select location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected
From covid..CovidDeaths
Where continent is not null
Order By 1, 2


-- Highest COVID Infection Rate
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as percent_population_infected
From covid..CovidDeaths
Where continent is NOT NULL
Group By location, population
Order by percent_population_infected DESC


-- Highest Death Count
Select location, MAX(cast(total_deaths as int)) as total_death_count
From covid..CovidDeaths
where continent is NOT NULL
Group By location
Order By total_death_count DESC;


-- COVID Deaths by Continent
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From covid..CovidDeaths
Where continent is not NULL
Group By continent
Order By total_death_count DESC;


-- GLOBAL DATA
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as mortality_rate
From covid..CovidDeaths 
Where continent is not NULL
Order By 1,2


-- Join CovidDeaths Table and CovidVaccination Table
Select *
From covid..CovidDeaths death
Join covid..CovidVaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date


-- Vaccination rate

-- Step 2 Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
daily_running_total_vaccination numeric
)


-- Step 1
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by death.location ORDER BY death.location, death.date) as daily_running_total_vaccination
From covid..CovidDeaths death
Join covid..CovidVaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
Order by 2,3

-- Step 3
Select *, (daily_running_total_vaccination/population)*100 as daily_vaccination_rate
From #PercentPopulationVaccinated



-- CREATE VIEW
Create View PercentPopulationVaccinated AS
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by death.location ORDER BY death.location, death.date) as daily_running_total_vaccination
From covid..CovidDeaths death
Join covid..CovidVaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
Where death.continent is not NULL


Select *
From PercentPopulationVaccinated

