SELECT *
From CovidDeath cd
where continent is not null
order by 3,4

/*SELECT *
FROM CovidVaccine cv 
order by 3,4*/

-- Data we are going to be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
From  CovidDeath cd 
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths	
-- Shows likelihood of dying in your country
SELECT Location, date, total_cases, total_deaths, {total_deaths/total_cases}*100 as DeathPercentage
From  CovidDeath cd 
Where location like '%states%'
AND continent is not null
order by 1,2

-- Total Cases vs Population 
-- Shows Percentage of population was infected
SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From  CovidDeath cd 
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, Cast(Max(total_cases)as float)/Max(population)*100 as InfectedPercentage
From  CovidDeath cd 
--Where location like '%states%'
Group by continent 
order by InfectedPercentage DESC 

--BREAKING THINGS DOWN BY CONTINENT

--Showing Countries with Highest Death Count per population
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
From  CovidDeath cd 
--Where location like '%states%'
Where continent IS NOT NULL 
Group by continent 
order by TotalDeathCount DESC


--Showing continents with the highest death counts per population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
From  CovidDeath cd 
--Where location like '%states%'
Where continent IS NOT NULL 
Group by continent 
order by TotalDeathCount DESC



--Global Numbers

SELECT Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From  CovidDeath cd 
--Where location like '%states%'
where continent is not null
--group by date 
order by 1,2

-- Total Populations vs Vaccinations 

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
, (RollingPeopleVacciinated/population)*100
From CovidDeath cd 
Join CovidVaccine cv 
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVacciinated/population)*100
From CovidDeath cd 
Join CovidVaccine cv 
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *, CAST(RollingPeopleVaccinated as float)/population*100
From PopvsVac

--Temp Table


Create Temp Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVacciinated/population)*100
From CovidDeath cd 
Join CovidVaccine cv 
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select *, CAST(RollingPeopleVaccinated as float)/population*100
From PercentPopulationVaccinated


-- Creating View to store for later visualtions

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, Sum(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVacciinated/population)*100
From CovidDeath cd 
Join CovidVaccine cv 
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3


Select*
From PercentPopulationVaccinated ppv 