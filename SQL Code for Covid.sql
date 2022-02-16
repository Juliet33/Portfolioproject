-- Preview the CovidDeath and CovidVaccinations table
Select *
From Portfolioproject..CovidDeaths$

Select * 
From Portfolioproject..CovidVaccinations$



-- Sort the table and select the columns you want to use.
Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..CovidDeaths$
Where continent is not null
order by 1,2

-- We'll be focusing on Countries first.

-- Total Deaths Vs Total Cases.
-- (Determine the percent of infected persons who are likely to die from Covid in Nigeria).

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrcentage
From Portfolioproject..CovidDeaths$
Where location like '%nigeria%'
and continent is not null
order by 1,2

-- Total Cases Vs Population
-- (Shows the percent of the population infected)

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths$
--Where location like '%nigeria%'
order by 1,2

-- Determine the countries with the Highest Infection Rates compared to the Population.

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths$
--Where location like '%nigeria%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Determine the countries with the Highest Death Count per Population.

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths$
--Where location like '%nigeria%'
Where continent is not null
Group by Location 
order by TotalDeathCount desc

-- Now, let's look at the Continents.

-- Determine the Continent with the highest Death Counts.

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths$
--Where location like '%nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers of Infected  Cases and Deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths$
--Where location like '%nigeria%'
where continent is not null 
--Group By date
order by 1,2


--Total Populatin Vs Vaccinations.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$  dea
Join Portfolioproject..CovidVaccinations$  vac
		On dea.location = vac.location
	    and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



