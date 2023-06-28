Select *
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From CovidPortfolioProject..CovidVaccinations
--Order By 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Order By 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%states%' AND continent is not null
Order By 1,2

--Looking at Total Cases vs Population
--Shows percentage of population in US that contracted Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
Where location like '%states%' AND continent is not null
Order By 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount desc

-- Let's Break Things Down By Continent 



--Showing Continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) Total_Cases, SUM(cast(new_deaths as int)) Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Take these out as they are not inluded in the above queries and to stay consistent
-- European Union is part of Europe

Select location Continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
, (RollingVaccinationCount/dea.population)*100
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Use CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingVaccinationCount/Population)*100
From PopVsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *, (RollingVaccinationCount/Population)*100
From #PercentPopulationVaccinated




--Creating Views to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


Select *
From PercentPopulationVaccinated

-- Total Cases, Deaths, and Death Percentage

Create View DeathPercentage as 
Select SUM(new_cases) Total_Cases, SUM(cast(new_deaths as int)) Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
--Order By 1,2

Select*
From DeathPercentage

-- Total Deaths by Continent

Create view TotalDeathCount as
Select location Continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
--order by TotalDeathCount desc

Select * 
From TotalDeathCount

-- Percent Population Infected by Country

Create View PercentPopulationInfected as
Select location as Country, Population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
--Order By PercentPopulationInfected desc

Select *
From PercentPopulationInfected


-- Percent Population Infected by Country and Date

Create View DatePercentPopulationInfected as
Select location as Country, Population, Date, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By location, population, date
--Order By PercentPopulationInfected desc

Select *
From DatePercentPopulationInfected