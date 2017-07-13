############################################
############################################
##
## SEC XBRL Data Download
##
## 2017
##
## R Language programming by
## John Akwei, ECMp ERMp Data Scientist
##
## ContextBase, contextbase.github.io
## johnakwei1@gmail.com
##
############################################
############################################


############################################
############################################
## Required R packages

## Install Required Packages
# install.packages("XBRL")
# library(devtools)
# devtools::install_github("bergant/xbrlus")
# devtools::install_github("bergant/finstr")
# install.packages("XML")
# install.packages("httr")
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("pander")
# install.packages("htmlTable")
# install.packages("ggplot2")

## Load packages before running R script
library(XBRL)
library(xbrlus)
library(finstr)
library(XML)
library(httr)
library(dplyr)
library(tidyr)
library(pander)
library(htmlTable)
library(ggplot2)
############################################
############################################


############################################
############################################
## SECdownload() function

SECdownload <- function(year, month) {
  
  # Create SEC monthly download variable
  edgarFilingsFeed <- paste('http://www.sec.gov/Archives/edgar/monthly/xbrlrss-',
                            year, '-', month, '.xml', sep="")
  print(edgarFilingsFeed)
  
  # Define folders for download
  mainDir <- getwd()
  subDir <- paste('xbrlrss', year, month, sep="")
  searchDir <- paste(mainDir, "/", subDir, sep="")
  xmlDir <- paste('xml',year, month, sep="")
  
  # If download folder already exists, then exit
  if (subDir %in% dir()) {
    print("Local copy already exists")
    break
  } else {
    dir.create(file.path(mainDir, subDir))
    setwd(file.path(mainDir, subDir))
    print("Parsing website data...")
  }
  
  # Download and parse SEC website
  feedFile <- xmlTreeParse(rawToChar(GET(edgarFilingsFeed)$content))
  
  # Find .zip file addresses to download
  src <- xpathApply(xmlRoot(feedFile), "//item")
  
  # Create the rssData variable containing XBRL data
  for (i in 1:length(src)) {
    if (i==1) {
      df <- xmlSApply(src[[i]], xmlValue)
      rssDATA <- data.frame(t(df), stringsAsFactors=FALSE)
    }
    else {
      df <- xmlSApply(src[[i]], xmlValue)
      tmp <- data.frame(t(df), stringsAsFactors=FALSE)
      rssDATA <- rbind(rssDATA, tmp)
    }}
  
  # Remove unused variables
  rm(tmp,df,i)
  
  # Check for Globally Unique IDs
  if (ncol(rssDATA)==5) {
    print("SEC data doesn't contain Globally Unique IDs...")
    print(paste("Unable to download SEC data for the month:",
                month, "/", year))
    break

    } else {
      print(paste("Downloading SEC data for the month:",
                  month, "/", year))
    }
  
  # Download and unzip the SEC zip files
  for (i in 1:length(rssDATA$guid)) {
    
    print("Downloading SEC data for:")
    print(paste(rssDATA$title[i]))
    
    # define the url
    url <- paste(rssDATA$guid[i])
    file <- basename(url)
    
    # download the zip file and store in the "file" object
    download.file(url, file)
    
    # unzip the file and store in the subdirectory folder
    unzip(file, exdir = xmlDir)
    }
  
  print(paste("Download of SEC data for ", year, '-', month, "is finished."))
  
  }

# End SECdownload() function
############################################
############################################


############################################
############################################
# Running "SECdownload()"

# Step 1: Load required packages

# Step 2: Set the Working Directory:
getwd()
setwd("")

# Step 3: Input the 4 digit year and 2 digit month,
# (for example - "SECdownload("2014", "07")")

# Step 4: Run the SECdownload function:
SECdownload("2014", "07")

# Some months will not download, because of non-existence of
# guid (globally unique identifiers) data.

############################################
############################################


############################################
############################################
## Examples of how to reference specific taxonomy
## data points for a specific year, and month.

# Set the working directory to an "xml" directory
# verify with: 
# dir(getwd())[1]
# [1] "abc-20100331.xml

# Set working directory to downloaded xml folder

# Parse XBRL data
abc201005 <- xbrlDoAll(dir(getwd())[1])

# The list of dataframes within an XBRL file:
names(abc201005)

# All taxonomy element ids for a company and year
# chosen by the client.

# The dimensions of dataframes within the downloaded XBRL file:
str(abc201005, max.level = 1)

# List of XBRL Reports:
table(abc201005$role$type)

# Locate elements
ABCelements <- abc201005$fact$elementId

# First 100 elements
ABCelements[1:100]

# To extract operating expenses, join the facts (the numbers)
# with the context (periods, dimensions):

abc201005$fact %>%
  filter(elementId == "us-gaap_CommonStockValue") %>%
  left_join(abc201005$context, by = "contextId") %>%
  filter(is.na(dimension1)) %>%
  select(startDate, endDate, fact, unitId, elementId) %>% 
  (knitr::kable)(format = "markdown")

# A table with all the company names, company tickers, and the
# years the financial results were downloaded:

# See SECdownload() internal dataframe: "rssDATA"

dir(getwd()) %>% (knitr::kable)(format = "markdown")
############################################
############################################
