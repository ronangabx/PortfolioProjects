-- 1. Global Data

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as mortality_rate
From covid..CovidDeaths
where continent is not null 
order by 1,2


-- 2. Continental Data

Select location, SUM(cast(new_deaths as int)) as mortality_rate
From covid..CovidDeaths
Where continent is null 
AND location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by mortality_rate desc


-- 3. Indivdual Country Data

Select location, population, MAX(total_cases) as highest_infection_count,  MAX((total_cases/population))*100 as percent_population_infected
From covid..CovidDeaths
Group by Location, Population
order by percent_population_infected desc


-- 4. Daily Infection Rate per Country

Select location, population, date, MAX(total_cases) as highest_infection_count,  MAX((total_cases/population))*100 as percent_population_infected
From covid..CovidDeaths
Group by Location, Population, date
order by percent_population_infected desc






