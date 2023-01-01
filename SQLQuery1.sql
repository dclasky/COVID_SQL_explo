SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--total cases vs total death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like'%states%'
ORDER BY 1,2

SELECT location, MAX(total_cases) as HighestInfection, population, MAX((total_cases/population))*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC
--

--Countries by death count
SELECT location, MAX(cast(total_deaths AS INT)) as totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY totalDeathCount DESC

--continents by death count
SELECT location, MAX(cast(total_deaths AS INT)) as totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY totalDeathCount DESC

--global numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST (new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS RollingVaxTotal
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--CTE
WITH PopvsVac (continent, location, date, population, new_vaccs, rollingVaxTotal) AS(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS RollingVaxTotal
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT * , (rollingVaxTotal/population)
*100 AS rollingVaxPerc
FROM PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PercPeopleVacc
CREATE TABLE #PercPeopleVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingVaxTotal numeric,
)

INSERT INTO #PercPeopleVacc
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS RollingVaxTotal
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
SELECT * , (rollingVaxTotal/population)
*100 AS rollingVaxPerc
FROM #PercPeopleVacc

--creating views
CREATE VIEW PercPeopleVacc AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS RollingVaxTotal
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
