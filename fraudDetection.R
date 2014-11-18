## ##################################### ##
## Integral Ad Science Interviw Project  ##
## fraud site detection                  ##
## Task:                                 ##
## a. detect website receiving a substa  ##
##    -ntial amount of fraud traffic     ##
## b. identify which ip address hosting  ##
##    machines that are part of botnets  ##
##                                       ##
##                                       ##
## Author: Yi Zhang                      ##
## Date: Nov/18/2014                     ##
## ##################################### ##
library(plyr)
library(ggplot2)

## ######################################## ##
## ENVIRONMENT SETTING -----------------------
## ######################################## ##
dir        <- list()
dir$root   <- paste(getwd(), '/', sep = '')
dir$data   <- paste(dir$root, 'data/', sep = '')
dir$output <- paste(dir$root, 'output/', sep = '')

## ######################################## ##
## CUSTOM FUNCTION ---------------------------
## ######################################## ##
getDataPath <- function(filename, dir){
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
  res <- paste(dir, filename, sep = "")
  return(res)
}

timestamp4sec <- function(timestamp_str){
  ## ********************************** ##
  ## Convert "YYYY-mm-dd hh:mm:ss" to   ##
  ## seconds after removing date info   ##
  ##                                    ##
  ## Parameters:                        ##
  ## -----------                        ##
  ## timestamp_str: string              ##
  ##                                    ##
  ## Returns:                           ##
  ## -------                            ##
  ## res: integer                       ##
  ## ********************************** ##
  hhmmss_str <- strsplit(timestamp_str, split=" ")[[1]][2]
  hhmmss_vec <- strsplit(hhmmss_str, split=":")[[1]]
  hh         <- as.numeric(hhmmss_vec[1])
  mm         <- as.numeric(hhmmss_vec[2])
  ss         <- as.numeric(hhmmss_vec[3])
  res        <- hh * 3600 + mm * 60 + ss
  return(res)
}

impute4num_plugins <- function(browser_str, ref=ref_tab){
  ## *********************************** ##
  ## Impute missing value in num_plugins ##
  ## with meadian of browser type        ##
  ##                                     ##
  ## Paramters:                          ##
  ## ---------                           ##
  ## browser_str: string                 ##
  ##                                     ##
  ## Returns:                            ##
  ## -------                             ##
  ## res: integer                        ##
  ## *********************************** ##
  res <- ref_tab[ref_tab[, "browser"] == browser_str, 2]
  return(res)
}

## ######################################## ##
## LOAD DATA ---------------------------------
## ######################################## ##
df           <- read.csv(getDataPath('fraud.event', dir=dir$data), header=FALSE, sep = '\t', stringsAsFactors = FALSE)
colnames(df) <- c("timestamp", "ip_addr", "browser", "detected_agent_str", "host_url", "is_viewed", "num_plugins", "ad_pos_dim", "network_latency")

fsites           <- read.csv(getDataPath('fraud_list.txt', dir=dir$data), header=FALSE, sep = '\t', stringsAsFactors = FALSE)
colnames(fsites) <- "host_url"
## ############################ ##
## DATA EXPLORATION AND SUMMARY ##
## ############################ ##
## 1. timestamp: 
##   a. date: 2014-08-25
##   b. time: 00:00 - 23:59
## 2. ip_addr: #unique_ip_addr = 8,216
## 3. browser: "Safari/Webkit", "Unknown",  "Chrome", "Internet Explorer", "Firefox", "Opera" 
## 4. host_url: #uniq_values = 11,779
## 5. is_viewed:
##    (0: 51.17%, 1: 38.92%, NA: 9.91%)
## 6. num_plugins: min:1, max:61, median: 10, #mising: 72,779 (30.95%)
## 7. ad_pos_dim: #unque_value: 10,303 --> categorize window position (top_banner) and determine ad type (full, partial)
## 8. network_latency: #NA: 34,800 (14.80328)

## ############################ ##
## DATA PRECOSSING      ----------
## ############################ ##
## Missing Data
images   <- list()
miss_idx <- list()
outliers <- list()

set.seed(123456)
## Collecting missing value row numbers
miss_idx$is_viewed    <- which(is.na(df$is_viewed)) 
miss_idx$num_plugins  <- which(is.na(df$num_plugins))
miss_idx$work_latency <- which(is.na(df$network_latency))
## Collecting outlier

## ########################## ##
## Missing Value Imputation   ##
## ########################## ##
images$num_plugins_by_browser <- ggplot(df[-miss_idx$num_plugins, ], aes(x=num_plugins, fill=browser)) + geom_density(alpha=.3) 
ggsave(plot=images$num_plugins_by_browser, filename=getDataPath(filename="ggplot_num_plugins_hist.png", dir=dir$output))

## Impute mssing data
## 1. is_viewed
df$is_viewed[miss_idx$is_viewed]      <- sample(x=c(0, 1), size=length(miss_idx$is_viewed), replace=TRUE, prob=c(.57, .43))
df$num_plugins[miss_idx$num_plugins]  <- sample(x=unique(df$num_plugins), size=length(miss_idx$num_plugins), replace=TRUE, prob=c(.57, .43))

## 2. num_plugins, 
## Prepare reference imputation table
ref_tab           <- data.frame(cbind(c("Chrome", "Firefox", "Internet Explorer", "Opera", "Safari/Webkit", "Unknown")
                                , c(14, 11, 2, 9, 6, 2))
                                , stringsAsFactors = FALSE)
ref_tab[, 2]      <- as.numeric(ref_tab[, 2])
colnames(ref_tab) <- c("browser", "med")

df$num_plugins[miss_idx$num_plugins] <- sapply(df$browser[miss_idx$num_plugins], function(x) impute4num_plugins(browser_str=x, ref=ref_tab) )

## 3. collecting_work_latency
df$network_latency[miss_idx$work_latency] <- 0

## ########################## ##
## VARAIBLE TRANSFORMATION    ##
## ########################## ##
## 1. timestamp --> second_idx --> hh * 60 * 60 + mm * 60 + ss
df$sec_idx            <- sapply(X=df$timestamp, timestamp4sec)
## 2. network_latency --> nwk_lattency_log1p
df$nwk_lattency_log1p <- log1p(df$network_latency)

## ######################### ##
## FEATURE EXTRACTION        ##
## ######################### ##
## sapply(df$detected_agent_str, function(x) strsplit(x, split=" ")[[1]][1])

write.table(x=df, file=getDat)
## ######################### ##
## SUMMARIZE INFORMATION     ##
## ######################### ##
site_ranks <- ddply(df, .(host_url)
                    , function(db){
                      uniq_user     <- length(unique(db$ip_addr))
                      num_viewed    <- sum(is_viewed)
                      view_per_user <- num_viewed / uniq_user
                      
                      res <- c("uniq_user"       = uniq_user
                               , "num_viewed"    = num_viewed
                               , "view_per_user" = view_per_user
                               )
                      return(res)
                    })