select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidDeaths


--select *
--from PortfolioProject..CovidVacinations
--order by 3,4

--Select Data that we are going to be using

select Location, date, total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, new_cases,total_deaths, (total_deaths /total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

-- looking at Total Cases vs Population
-- Shows what percentage of population got covid

select Location, date, total_cases, population, new_cases,total_deaths,  (total_cases / population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compare to population
select Location,Population ,MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))*100  as HighestCasesPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location,Population
order by HighestCasesPercentage desc


-- LET's BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as HighestTotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
--where location like '%states%'
order by HighestTotalDeaths desc

-- Showing Countries with Highest Dearh Count per population

Select Location, MAX(cast(Total_deaths as int)) as HighestTotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
--where location like '%states%'
order by HighestTotalDeaths desc

-- Showing the contient with the highest death count per population

Select continent , MAX(cast(Total_deaths as int)) as HighestTotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
--where location like '%states%'
order by HighestTotalDeaths desc


-- GLOBAL NUMBERS

select SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast (new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by
dea.location,dea.date) as RollingPeopleVacinnated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM
        PortfolioProject..CovidDeaths dea
    JOIN
        PortfolioProject..CovidVacinations vac
    ON
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacinnations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
 SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM
        PortfolioProject..CovidDeaths dea
    JOIN
        PortfolioProject..CovidVacinations vac
    ON
        dea.location = vac.location
        AND dea.date = vac.date
    --WHERE
       -- dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM
        PortfolioProject..CovidDeaths dea
    JOIN
        PortfolioProject..CovidVacinations vac
    ON
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE
		dea.continent IS NOT NULL


Select *
from PercentPopulationVaccinated











