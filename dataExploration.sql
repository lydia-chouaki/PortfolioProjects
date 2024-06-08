select location, date, total_cases,new_cases,total_deaths,population
from ProjectPortfolio22..CovidDeaths$
order by 1,2
-- shows the likelyhood of dying if you contact covid in your country
select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio22..CovidDeaths$
where location like '%states%'
order by 1,2
-- looking at the total cases vs population
-- shows what pourcentage of population got covid
select location, date,total_cases, population, (total_cases/population)*100 as CasePercentage
from ProjectPortfolio22..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countries with highest  infection rate compared to population
select location, Population, max(total_cases) as highestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from ProjectPortfolio22..CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

--looking for highest death count per populaion
--we have an issue with nvarchar tpe of total_death column so we have to cast it to int
select location,max(cast(total_deaths as int)) as highestDeathCount
from ProjectPortfolio22..CovidDeaths$
where continent is not null
group by location
order by highestDeathCount  desc

--let's break things down by continent
--showing the continent with highest death count
select location,max(cast(total_deaths as int)) as totalDeathCount
from ProjectPortfolio22..CovidDeaths$
where continent is  null
group by location
order by totalDeathCount  desc

--global numbers

select date,sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectPortfolio22..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- check on vaccination table

select * 
from ProjectPortfolio22..CovidDeaths$ dea
join  ProjectPortfolio22..CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date

-- looking at total population vs vaccinations
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from ProjectPortfolio22..CovidDeaths$ dea
 join  ProjectPortfolio22..CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- now we want to add the percentage of total_vaccinated people per population, 
-- so we need to devide RollingPeopleVaccinated calculated before by population
--but we cant use a column that we just created to create a next one


--solutoin 1: use  a CTE common table expression
with Popvsvac(continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--,((cast (RollingPeopleVaccinated as int)/population)*100) as percPopvsVac
from ProjectPortfolio22..CovidDeaths$ dea
 join  ProjectPortfolio22..CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

)
select *,((RollingPeopleVaccinated /population)*100) as percPopvsVac 
from Popvsvac

-- create a temp table : using drop if exists
--sol3: use views
create view PercentageVaccinatedPeople as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--,((cast (RollingPeopleVaccinated as int)/population)*100) as percPopvsVac
from ProjectPortfolio22..CovidDeaths$ dea
 join  ProjectPortfolio22..CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * 
from  PercentageVaccinatedPeople