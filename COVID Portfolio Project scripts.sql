SELECT *
FROM [PortoflioProject 1]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM [PortoflioProject 1]..CovidVaccinations
--ORDER BY 3,4;

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortoflioProject 1]..CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [PortoflioProject 1]..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 1,2;


-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population )*100 AS PercentPopulationInfected
FROM [PortoflioProject 1]..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 1,2;


-- Looking at Countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population ))*100
				AS PercentPopulationInfected
FROM [PortoflioProject 1]..CovidDeaths
-- WHERE location LIKE '%kingdom%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM [PortoflioProject 1]..CovidDeaths
-- WHERE location LIKE '%kingdom%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;


-- GLOBAL NUMBERS

SELECT  --date,
		SUM(new_cases) AS total_cases,
		SUM(CAST(new_deaths AS INT)) AS total_deaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM [PortoflioProject 1]..CovidDeaths
WHERE continent	IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations

SELECT  dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location
			, dea.date) AS RollingPeopleVaccinated,
		--(RollingPeoleVaccinated/population)*100
FROM [PortoflioProject 1]..CovidDeaths Dea
JOIN [PortoflioProject 1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3
;


-- USE CTE

WITH PopvsVac (contintent, location, date, population, New_vaccinations, Rollingpeoplevaccinated) AS (
	SELECT  dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location
			, dea.date) AS RollingPeopleVaccinated
FROM [PortoflioProject 1]..CovidDeaths Dea
JOIN [PortoflioProject 1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, Rollingpeoplevaccinated/population*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
	SELECT  dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location
			, dea.date) AS RollingPeopleVaccinated
	FROM [PortoflioProject 1]..CovidDeaths Dea
	JOIN [PortoflioProject 1]..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3



SELECT *, Rollingpeoplevaccinated/population*100
FROM #PercentPopulationVaccinated;




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS 
SELECT  dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location
			, dea.date) AS RollingPeopleVaccinated
	FROM [PortoflioProject 1]..CovidDeaths Dea
	JOIN [PortoflioProject 1]..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated;