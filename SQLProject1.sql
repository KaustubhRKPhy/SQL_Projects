Select *
From CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From CovidVaccination
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select  location, date, total_cases, total_deaths, 100*(total_deaths/total_cases) as DeathPercentage
From CovidDeaths
Where location = 'India'
Order by 1,2

-- Looking at Total Cases vs Population

Select  location, date, total_cases, population, 100*(total_cases/population) as InfectedOverPopulation
From CovidDeaths
Where location = 'India'
Order by 1,2

-- Looking at Countries with highest Infection rate

Select location, population, MAX(total_cases) as HighestInfectionCount,  100*(MAX(total_cases/population)) as InfectedOverPopulation
From CovidDeaths
Group By location, population
Order by InfectedOverPopulation Desc

-- Showing countries with highest casualities over population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By location, population
Order by TotalDeathCount Desc


-- Showing CONTINENTS with highest casualities over population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount Desc


-- GLOBAL NUMBERS 

Select  date, SUM(new_cases) as ToalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- TOTAL GLOBAL DEATHS 

Select  SUM(new_cases) as ToalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Order by 1,2


-- Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as PeopleVaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as PeopleVaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as PeopleVaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
ORDER BY 2

--Creating View to store data for visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as PeopleVaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date



-- Since a view is created, it is permenant and can be called
Select * 
From PercentPopulationVaccinated 