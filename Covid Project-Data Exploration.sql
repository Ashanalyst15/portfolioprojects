select * 
from ProjectPortfolio..CovidDeaths$
where continent is not NUll

select * 
from ProjectPortfolio..CovidVaccinations$
order by 3,4

Select location, date, total_cases, new_cases,total_deaths,population
from ProjectPortfolio..CovidDeaths$

--Looking at Total Cases VS Total Deaths
--shows the Likelihood of dying if you contract covid in your country 
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage 
from ProjectPortfolio..CovidDeaths$
where location like 'India'
order by 1,2

--looking at a Toal cases vs Population
--shows what percentage of the population got covid
Select location, date, total_cases,population,(total_cases/population)*100 as PercentPopulationinfected 
from ProjectPortfolio..CovidDeaths$
where location like 'India'
order by 1,2

--looking at countires with highest infection rate compared to the population 
select * 
from ProjectPortfolio..CovidDeaths$

Select location,population, max(total_cases)as HighestInfectioncount,max(total_cases/population)*100 as PercentPopulationinfected
from ProjectPortfolio..CovidDeaths$
group by location, population
order by PercentPopulationinfected desc

-- showing countries with highest Death count per population

Select location, max(cast (Total_Deaths as int )) as TotalDeathscount
from ProjectPortfolio..CovidDeaths$
where continent is not NUll
group by location
order by TotalDeathscount desc



--Let's Break things down by continent 

--Select location, max(cast (Total_Deaths as int )) as TotalDeathscount
--from ProjectPortfolio..CovidDeaths$
--where continent is  NUll
--group by Location
--order by TotalDeathscount desc


-- showing the continents with the highest death count per population 
Select continent, max(cast (Total_Deaths as int )) as TotalDeathscount
from ProjectPortfolio..CovidDeaths$
where continent is Not NUll
group by continent
order by TotalDeathscount desc

--Global Numbers 

Select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage 
from ProjectPortfolio..CovidDeaths$
--where location like 'India'
where continent is Not NUll
--group by date 
order by Deathpercentage

--looking at total population vs Vaccination



select *
from ProjectPortfolio..CovidVaccinations$ dea
 join ProjectPortfolio..CovidDeaths$ vac
  on dea.location = vac.location
  and dea.date =  vac.date
 
 select dea.location, dea.continent ,dea.date,population,vac.new_vaccinations,
 sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as as RollingPeopleVaccinated
 from ProjectPortfolio..CovidVaccinations$ dea
 join ProjectPortfolio..CovidDeaths$ vac
  on dea.location = vac.location
  and dea.date =  vac.date
  where dea.continent  is not null 
order by 2,3
 
 --use CTE

 with popvsVac(Continent, Location, Date,Population,new_vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.location, dea.continent ,dea.date,population,vac.new_vaccinations,
 sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
 from ProjectPortfolio..CovidVaccinations$ dea
 join ProjectPortfolio..CovidDeaths$ vac
  on dea.location = vac.location
  and dea.date =  vac.date
  where dea.continent  is not null 
--order by 2,3
)
select *
from popvsVac

--Temp Table
Drop Table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated

 select dea.location, dea.continent ,dea.date,population,vac.new_vaccinations,
 sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
 from ProjectPortfolio..CovidVaccinations$ dea
 join ProjectPortfolio..CovidDeaths$ vac
  on dea.location = vac.location
  and dea.date =  vac.date
 -- where dea.continent  is not null 
--order by 2,3

select *, (Rollingpeoplevaccinated/Population)*100
from #percentpopulationvaccinated

--Creating view to store data for later visualization

create view percentpopulationvaccinated as 
select dea.location, dea.continent ,dea.date,population,vac.new_vaccinations,
 sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
 from ProjectPortfolio..CovidVaccinations$ dea
 join ProjectPortfolio..CovidDeaths$ vac
  on dea.location = vac.location
  and dea.date =  vac.date
 where dea.continent  is not null 
--order by 2,3

select * from percentpopulationvaccinated
