Select *
From PortfolioProject01..CovidDeaths
Order by 3,4

Select *
From PortfolioProject01..CovidVaccinations
Order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject01..CovidDeaths
Order by 1,2

Select location,date,total_cases,total_deaths,population,(total_cases/population)*100 as InfectionRate,(total_deaths/total_cases)*100 as DeathRate
From PortfolioProject01..CovidDeaths 
--where location like '%kingdom%'
Order by 1,2

--Highest Infection Rate per population

Select location,population,Max(total_cases)as HigestInfectionNo,Max (total_cases/population)*100 as HighestInfectionRate
From PortfolioProject01..CovidDeaths 
Group by Location,Population
Order by HighestInfectionRate desc

--Highest Death Rate by continent and location

Select Continent,location,Max (cast (total_deaths as int))as HighestDeathCount,Max (total_deaths/total_cases)*100 as HighestCovidDeathRate
From PortfolioProject01..CovidDeaths 
Group by Continent,Location
Order by Continent,Location,HighestCovidDeathRate

--Vaccination over population 

Select vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location order by vac.location,vac.date) as Vacrunningtotal
--(Vacrunningtotal /vac.population)*100 as vaccinationrate
From PortfolioProject01..CovidVaccinations vac
  
  join PortfolioProject01..CovidDeaths dea
  on vac.continent = dea.continent
  and vac.date = dea.date
  Where vac.continent is not NULL
  group by vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations
  Order by vac.location,vac.date

  --CTE Use

  With POPvsVAC (continent,location,population,date,New_vaccinations,Vacrunningtotal)
  as
  (
  Select vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location order by vac.location,vac.date) as Vacrunningtotal
--(Vacrunningtotal /vac.population)*100 as vaccinationrate
From PortfolioProject01..CovidVaccinations vac
  
  join PortfolioProject01..CovidDeaths dea
  on vac.continent = dea.continent
  and vac.date = dea.date
  Where vac.continent is not NULL
  group by vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations
  --Order by vac.location,vac.date

  )
  Select *,(Vacrunningtotal/population)*100 as vaccinationrate
  from POPvsVAC

  --Temp Table
  Drop table if exists #popVSvac
  Create Table #popVSvac
  (continent varchar(255),
  location Varchar(255),
  population int,
  date datetime,
  New_vaccinations int,
  Vacrunningtotal int)

  Insert into #popVSvac

  Select vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations,
         Sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location order by vac.location,vac.date) as Vacrunningtotal
         --(Vacrunningtotal /vac.population)*100 as vaccinationrate
  From PortfolioProject01..CovidVaccinations vac
  
       join PortfolioProject01..CovidDeaths dea
       on vac.continent = dea.continent
       and vac.date = dea.date
       Where vac.continent is not NULL
  group by vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations
  --Order by vac.location,vac.date

  Select *,(Vacrunningtotal/population)*100 as vaccinationrate
  from #popVSvac

  --Creating View

  Create View PoplationVaccinated as
   Select vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations,
         Sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location order by vac.location,vac.date) as Vacrunningtotal
         --(Vacrunningtotal /vac.population)*100 as vaccinationrate
  From PortfolioProject01..CovidVaccinations vac
  
       join PortfolioProject01..CovidDeaths dea
       on vac.continent = dea.continent
       and vac.date = dea.date
       Where vac.continent is not NULL
  group by vac.continent,vac.location,vac.population,vac.date,vac.new_vaccinations
  --Order by vac.location,vac.date
  
 Select * from PoplationVaccinated