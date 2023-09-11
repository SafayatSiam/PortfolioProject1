SELECT *
FROM CovidDeaths$
WHERE continent is  null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4


SELECT location, DATE, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid 
SELECT location, DATE, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%States%' and continent is not null
ORDER BY 1,2 

-- Looking at the Total cases vs Population 

SELECT location, DATE, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths$
WHERE location like '%States%' AND continent is not null
ORDER BY 1,2 

-- Looking at countries with highest infection rate compared to population 

SELECT location, population, Max(total_cases) AS HighestinfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths$
--WHERE location like '%States%'
WHERE continent is not null
Group By Location,Population
ORDER BY PercentagePopulationInfected desc

--Showing Countires with highest death count

SELECT location, MAX(Cast(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%States%'
WHERE continent is not null
Group By Location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THIS DOWN BY CONTINENT


-- Showing continents with the highest death count 
SELECT continent, MAX(Cast(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%States%'
WHERE continent is not null
Group By continent
ORDER BY TotalDeathCount desc

-- Global Numbers 

SELECT  SUM(New_cases) AS TotalCases, SUM(cast(New_deaths as int)) AS TotalDeath , SUM(cast(New_deaths as int))/SUM(NEW_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--WHERE location like '%States%' 
WHERE continent is not null
--Group By date
ORDER BY 1,2 

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order By Dea.Location, Dea.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order By 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order By Dea.Location, Dea.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temp Table

DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated  
(
continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population Numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order By Dea.Location, Dea.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
	ON Dea.location = Vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--Order By 2,3
 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #percentPopulationVaccinated

-- Creating view to store data for visualizations 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location Order By Dea.Location, Dea.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3

SELECT *
FROM PercentPopulationVaccinated
