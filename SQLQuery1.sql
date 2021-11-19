SELECT *
FROM PortfolioProject..CovidData
Where continent is not null
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4

--Data I will be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidData
order by 1, 2


-- Looking at Total Cases vs Total Deaths
--likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DataPercentage
From PortfolioProject..CovidData
Where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
--Shows percentage of population that contracted Covid
Select location, date, total_cases, Population, (total_cases/population) * 100 as PopulationPercentage
From PortfolioProject..CovidData
Where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population

Select location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentOfPopulationAffected
From PortfolioProject..CovidData
--Where location like '%states%'
Group by Location, Population
order by PercentOfPopulationAffected desc

-- Breaking Things Down By Continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDataCount
From PortfolioProject..CovidData
--Where location like '%states%'
Where continent is null


--Showing continents with the highest de. count per population
Group by continent
order by TotalDataCount desc

--Portraying Countries with Highest Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDataCount
From PortfolioProject..CovidData
--Where location like '%states%'
Where continent is null
Group by Location
order by TotalDataCount desc

--Showing continents with the highest de. count per population
Select continent, MAX(cast(total_cases as int)) AS TotalDataCount
From PortfolioProject..CovidData
--Where location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDataCount desc



-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DataPercentage
From PortfolioProject..CovidData
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1, 2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidData dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
 Where dea.continent is not null
Order by 2, 3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidData dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
 Where dea.continent is not null
--Order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

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
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidData dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Select continent, MAX(cast(Total_deaths as int)) as TotalDataCount 
From PortfolioProject..CovidData
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDataCount desc

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidData dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
