SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--looking at TOTAL Cases VS total Deaths
--shows the likelyhood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--looking at the total case VS population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE (total_cases is not NULL
AND
population IS NOT NULL
)
--location like '%states%')
ORDER BY 1,2


--LOOKING AT COUNTRIES WITH THE HIGHEST INFRECTIONRATE COMPARED TO POPULATION


SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE (total_cases is not NULL
AND
population IS NOT NULL
)
--location like '%states%')
GROUP BY Location,population
ORDER BY PercentOfPopulationInfected desc

--showing the countries with the Highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE (continent IS NOT NULL
)
--location like '%states%')
GROUP BY Location
ORDER BY TotalDeathCount desc

--lets break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL
--location like '%states%')
GROUP BY continent
ORDER BY TotalDeathCount desc


--showing th continents with highest deathcount per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL
--location like '%states%')
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Number


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
ORDER BY 1,2

--looking aat total population vs vaccinations
with PopvsVac(continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac




--temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER
USE PortfolioProject
go
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated