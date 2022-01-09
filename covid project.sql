--covid 19 data exploration

--Skills used: joins,CET's,Temp Table,Windows Functions,Aggregate Functions,Creating Views,Converting Data types.


select *
from coviddeaths
where continent is not null
order by 3,4


--select the data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths 
where continent is not null
order by 1,2


--total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeaths 
where continent is not null 
--and location like '%india%'
order by 1,2


--total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 as pecentpopulationinfected
from coviddeaths 
--where location like '%india%'
order by 1,2


--countries with highest infection rate compared to population

select location,population,max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from coviddeaths 
--where location like '%india%'
group by location,population
order by percentpopulationinfected desc


--countries with highest death count per population

select location,max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
where continent is not null
--and location like '%india%'
group by location 
order by totaldeathcount desc


--breaking things down by continent

--showing contintents with the highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths 
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
order by 1,2


--total population vs vaccination
--percentage of population recieved atleast one does

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
from coviddeaths dea
 join    covidvaccinations vac
	  on dea.location=vac.location
	  and dea.date=vac.date
	  where dea.continent is not null
	  order by 2,3
	  

--using cte to perform calculation on partition by in perious query

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
 join    covidvaccinations vac
	  on dea.location=vac.location
	  and dea.date=vac.date
	  where dea.continent is not null
	  --order by 2,3
	  )
select *,(rollingpeoplevaccinated/population)*100
from popvsvac


--using temp table to perform calculation on parttion by in previous query

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
 join    covidvaccinations vac
	  on dea.location=vac.location
	  and dea.date=vac.date
	 -- where dea.continent is not null
	  --order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
 join    covidvaccinations vac
	  on dea.location=vac.location
	  and dea.date=vac.date
	  where dea.continent is not null
	  --order by 2,3
	  



