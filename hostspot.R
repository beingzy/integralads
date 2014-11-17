## ######################################## ##
## Integral Ad Science Interview Project:   ##
## Find HotSpot                             ##
##                                          ##
## Author: Yi Zhang                         ##
## Date: Nov/15/2014                        ##
## ######################################## ##
library(plyr)
library(ggplot2)

## ######################################## ##
## ENVIRONMENT SETTING -----------------------
## ######################################## ##
dir      <- list()
dir$root <- paste(getwd(), '/', sep = '')
dir$data <- paste(dir$root, 'data/', sep = '')

## ######################################## ##
## CUSTOM FUNCTION ---------------------------
## ######################################## ##
getDataPath <- function(path, dir){
  # ************************************* #
  # Return the complete path to data file #
  #                                       #
  # Parameter:                            #
  # ---------                             #
  # path: string,                         #
  # dir: string                           #
  #                                       #
  # Return:                               #
  # -------                               #
  # res: string                           #
  # ************************************* #
  res <- paste(dir, path, sep = "")
  return(res)
}

## ######################################## ##
## LOAD DATA ---------------------------------
## ######################################## ##
file01 <- read.csv(file = getDataPath('hotspot.event_1', dir$data), header = 0
                   , stringsAsFactors = FALSE, sep = '\t')
file02 <- read.csv(file = getDataPath('hotspot.event_2', dir$data), header = 0
                   , stringsAsFactors = FALSE, sep = '\t', skip=1)
## Combine rows
db           <- rbind(file01, file02)
colnames(db) <- c('timestamp', 'ip_address', 'domain_name', 'uri', 'user_agent_str')
rm(list = c('file01', 'file02'))
## ######################## ##
## Create new variables     ##
## ######################## ##
## 1. decompose ip_addr
temp <- sapply(db$ip_address, function(x) strsplit(x = x, split = ".", fixed = TRUE)[[1]] )
temp <- as.data.frame(matrix(unlist(temp), nrow=length(temp), byrow=T), stringsAsFactors = FALSE)

db$ip_c1 <- temp[, 1]
db$ip_c2 <- temp[, 2]
db$ip_c3 <- temp[, 3]
db$ip_c4 <- temp[, 4]

db <- db[, c('timestamp', 'ip_address', 'ip_c1', 'ip_c2', 'ip_c3', 'ip_c4'
             , 'domain_name', 'uri', 'user_agent_str')]

## ###################################### ##
## DATA SUMMARIZATION ----------------------
## ###################################### ##
## Unique User:
## Facts:
## a. an ip address could be shared by multiple user via proxy at same time
## b. an ip address could be dynamically assigned to different user at different time
## c. a single user could surface online via multiple OSs (PC, mobile)
## Assumption:
## (To simplification)
## a. a unique user could own the same IP and using same OS
##
sumn <- list()

sumn$ipcount_c12 <- ddply(db
                          , .(ip_c1, ip_c2)
                          , function(df){
                            ## ************************ ##
                            ## Unique ip address in the ##
                            ## group                    ##
                            ## ************************ ##
                            uniq_ip     <- length(unique(df$ip_address))
                            tot_profile <- nrow(unique(df[, c("ip_address", "user_agent_str")])) 
                            tot_records <- nrow(unique(df[, "ip_address"]))
                            res     <- c("uniq_ip" = uniq_ip
                                         , "tot_profile" = tot_profile
                                         , "tot_obs" = tot_obs)
                            return(res)
                          })

sumn$ipcount_c12 <- arrange(sumn$ipcount_c12, desc(tot_profile))

