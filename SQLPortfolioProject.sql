SELECT *
FROM PortFolioProject..CovidDeaths
ORDER BY date


--SELECT *
--FROM PortFolioProject..CovidVaccinations
--ORDER BY date


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortFolioProject..CovidDeaths
Order By 1,2


--Looking for total cases vs total deaths
-- Shows likelyhood of dying if you contact covid in India
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- Looking for total cases vs Population
-- Shows likelihood of percentage of population effected by Covid in india
SELECT location, date, total_cases, population, (total_cases/population)*100 as AffectedPopulationPercentage
FROM PortFolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Looking at countries whcih has highest infected rate in comparision to population

SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as MaxAffectedPopulationPercentage
FROM PortFolioProject..CovidDeaths
GROUP BY location, population
ORDER BY MaxAffectedPopulationPercentage DESC

SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as MaxAffectedPopulationPercentage
FROM PortFolioProject..CovidDeaths
GROUP BY location, population
ORDER BY location, population

--Looking at countries which have hoghest death rates per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortFolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Lets break things by continent

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortFolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortFolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int))
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER By 1, 2



SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER By 1, 2

SELECT SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
ORDER By 1, 2


SELECT *
FROM PortFolioProject..CovidVaccinations

SELECT *
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date

 --Looking at total populations vs vaccinations

 SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 order by 2,3


 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE 

With PopvsVac( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- USing Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


---Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3