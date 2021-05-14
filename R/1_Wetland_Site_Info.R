#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Title: Initial Wetland Info
#Date: 5/13/2021
#Coder: Nate Jones (cnjones7@ua.edu)
#Purpose: Create spreadsheet of site characteristics
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#1.0 Setup workspace -----------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Clear memory
remove(list=ls())

#load relevant packages
library(readxl)
library(sf)
library(tidyverse)

#load core data directory
syn<-read_xlsx('data/DISCO_core_data.xlsx', sheet = 'Synoptic Sampling Sites')
jl<-read_xlsx('data/DISCO_core_data.xlsx', sheet = 'Jackson Lane Catchment')
bc<-read_xlsx('data/DISCO_core_data.xlsx', sheet = 'Baltimore Corner Catchment')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2.0 Tidy core site directory --------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Synoptic Sampling
syn<-syn %>% 
  select(
    site_id = `Site ID`, 
    lat = Latitude, 
    lon = Longitude, 
    property = Property) %>% 
  mutate(project_component = 'synoptic')

#Jackson Lane
jl<-jl %>% 
  select(
    site_id = SiteID, 
    lat = Latitude, 
    lon = Longitude) %>% 
  mutate(
    property = 'Jackson Lane',
    project_component = 'experimental catchment')
    
#Big Catchment
bc<-bc %>% 
  select(
    site_id = Site_ID, 
    lat = Latitude, 
    lon = Longitude) %>% 
  mutate(
    property = 'Baltimore Corner',
    project_component = 'Primary Catchment')

#combine
df<-bind_rows(syn, jl, bc)

#create simple feature
df<-st_as_sf(df, coords = c("lon", "lat"), crs = '+proj=longlat +datum=WGS84 +no_defs')

#-------------------------------------------------------------------------------
#