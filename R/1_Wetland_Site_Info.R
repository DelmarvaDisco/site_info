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
library(mapview)
library(readxl)
library(sf)
library(tidyverse)

#load core data directory
syn<-read_xlsx('data/DISCO_core_data.xlsx', sheet = 'Synoptic Sampling Sites')
jl<-read_xlsx('data/DISCO_core_data.xlsx', sheet = 'Jackson Lane Catchment')
bc<-read_xlsx('data/DISCO_core_data.xlsx', sheet = 'Baltimore Corner Catchment')

#load wetland shape from DMV_spatial analysis
wetlands<-st_read('data/wetlands.shp')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2.0 Tidy core site directory --------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Synoptic Sampling
syn<-syn %>% 
  select(
    site_id = `Site ID`, 
    wetland_name = 'Wetland Name', 
    lat = Latitude, 
    lon = Longitude, 
    property = Property) %>% 
  mutate(project_component = 'synoptic')

#Jackson Lane
jl<-jl %>% 
  select(
    site_id = SiteID, 
    wetland_name = 'Wetland Name', 
    lat = Latitude, 
    lon = Longitude) %>% 
  mutate(
    property = 'Jackson Lane',
    project_component = 'experimental catchment')
    
#Big Catchment
bc<-bc %>% 
  select(
    site_id = Site_ID, 
    wetland_name = 'Wetland Name', 
    lat = Latitude, 
    lon = Longitude) %>% 
  mutate(
    property = 'Baltimore Corner',
    project_component = 'Primary Catchment')

#combine
df<-bind_rows(syn, jl, bc)

#create simple feature
df<-st_as_sf(df, coords = c("lon", "lat"), crs = '+proj=longlat +datum=WGS84 +no_defs')

#Add coordinates to simple feature's tibble
df<-df %>% 
  mutate(
    x = st_coordinates(.)[,1],
    y = st_coordinates(.)[,2],
  )

#reproject to UTM Zone 17N (https://spatialreference.org/)
df<-st_transform(df, crs = '+proj=utm +zone=17 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ' )

#plot for funzies
mapview(wetlands) + mapview(df)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#3.0 Overlay wetland features --------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Organize wetlands data
wetlands<-wetlands %>% 
  filter(spawned==0) 

#Reduce to overlapping shapes
df<-st_buffer(df, dist=10) %>% select(wetland_name, property)
df<-df[wetlands,]
wetlands<-wetlands[df,]

#Overlay shapes
df<-st_join(wetlands, df) %>% 
  select(
    wetland_name, 
    property,
    subshed_area_m2 =  sbsh__2, 
    watershed_area_m2 = wtrs__2,
    wetland_storage_volume_m3 = volm_m3, 
    wetland_hsc_cm = wtlnd__, 
    watershed_hsc_cm = wtrsh__, 
    perimeter_m = prmtr_m, 
    area_m2 = area_m2, 
    p_a_ratio = p_a_rat, 
    hand_m = hand_m, 
    mean_elevation_m = mn_lvt_, 
    wet_order = wet_rdr)
 
#Plot
m<-mapview(df)

#Export results
df %>% st_drop_geometry %>% distinct() %>%  write.csv(., "docs/wetland_info.csv")

# setwd("docs/")
# mapshot(m, "wetlands.html")
