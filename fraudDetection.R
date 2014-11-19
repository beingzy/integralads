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
temp     <- list()

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
                      num_viewed    <- sum(db$is_viewed)
                      view_per_user <- num_viewed / uniq_user
                      
                      res <- c("uniq_user"       = uniq_user
                               , "num_ad_viewed" = num_viewed
                               , "view_per_user" = view_per_user
                               )
                      return(res)
                    })
##
site_ranks             <- arrange(site_ranks, desc(view_per_user), desc(num_ad_viewed))
site_ranks$rank        <- 1:nrow(site_ranks)
site_ranks$url         <- sapply(site_ranks$host_url, function(x) strsplit(x, split = "//")[[1]][2])
site_ranks$fraud_label <- 0

site_ranks$fraud_label[which(site_ranks$url %in% fsites$host_url)] <- 1
site_ranks$fraud_label <- as.integer(site_ranks$fraud_label)

images$sites_plot <-  ggplot(site_ranks, aes(log(uniq_user), log(view_per_user), color=fraud_label)) + 
                        geom_point(alpha = .5, aes(size=fraud_label * 3 + 10 ))
ggsave(filename = getDataPath("sites_plot.png", dir = dir$output), plot = images$sites_plot
       , width = 10, height = 8)
## ################################### ##
## CONSTRUCT VISITIMG TEMPORAL PATTERN ##
## ################################### ##
site_ts <- ddply(df, .(host_url, sec_idx)
                 , function(ds){
                   uniq_user <- nrow(ds$ip_addr)
                   tot_user  <- sum(ds$is_viewed)
                   res       <- c("uniq_user"    = uniq_user
                                  , "tot_viewed" = tot_user)
                   return(res)
                 })

## time series
temp$userGT100                 <- subset(site_ts, host_url %in% subset(site_ranks, uniq_user >= 100)$host_url)
temp$userGT100$factor_host_url <- as.factor(temp$userGT100$host_url)
temp$userGT100$url             <- sapply(temp$userGT100$host_url, function(x) strsplit(x, split = "//")[[1]][2])
temp$userGT100$fraud_label     <- 0

temp$userGT100$fraud_label[temp$userGT100$url %in% fsites$host_url] <- 1


images$sites_ts <- ggplot(data = temp$userGT100, aes(x = sec_idx, y = tot_viewed, group = host_url)) + 
                    geom_line(alpha = .3, aes(colors = factor_host_url)) + facet_wrap( ~ host_url)
  
ggsave(filename = getDataPath("sites_uniquserGT100_ts.png", dir = dir$output), plot = images$sites_ts
       , width = 25, height = 8)

## ############################# ## 
## PLOT 
## ############################# ##
temp$fraudsite                 <- site_ts
temp$fraudsite$url             <- sapply(temp$fraudsite$host_url, function(x) strsplit(x, split = "//")[[1]][2])
temp$fraudsite                 <- subset(temp$fraudsite, url %in% fsites$host_url)
temp$fraudsite$factor_host_url <- as.factor(temp$fraudsite$host_url)

images$fraud_sites <- ggplot(data = temp$fraudsite, aes(x = sec_idx, y = tot_viewed, group = host_url)) + 
                    geom_line(alpha = .7, aes(colors = factor_host_url)) + facet_wrap( ~ host_url)
ggsave(filename = getDataPath("fraud_sites_ts.png", dir = dir$output), plot = images$sites_ts
       , width = 25, height = 8)

## ############################ ##
## botnet IP Address Detection  ##
##                              ##
## INVESTIGATE:                 ## 
## fraudster visits pattern     ##
##                              ##
## ############################ ##
ip_sum <- list()

df$url <- sapply(df$host_url, function(x) strsplit(x, split = "//")[[1]][2])
fdf    <- subset(df, url %in% fsites$host_url)

## ###################################### ##
## SUMMARIZE Visitor IP-wise information  ##
## of Fraud sites                         ##
## ###################################### ##
ip_sum <- ddply(subset(df, ip_addr %in% unique(fdf$ip_addr) )
                , .(ip_addr)
                , function(db){
                  num_sites_visited <- length(unique(db$host_url))
                  num_ad_viewed     <- sum(db$is_viewed)
                  num_visits        <- nrow(db)
                  ad_viewed_rate    <- num_ad_viewed / num_visits
                  res               <- c("num_sites_visited" = num_sites_visited
                                         , "num_ad_viewed"   = num_ad_viewed
                                         , "num_visits"      = num_visits
                                         , "ad_viewed_rate"  = ad_viewed_rate )
                  return(res)
                })

all_ip_sum <- ddply(df
                    , .(ip_addr)
                    , function(db){
                      num_sites_visited <- length(unique(db$host_url))
                      num_ad_viewed     <- sum(db$is_viewed)
                      num_visits        <- nrow(db)
                      ad_viewed_rate    <- num_ad_viewed / num_visits
                      res               <- c("num_sites_visited" = num_sites_visited
                                             , "num_ad_viewed"   = num_ad_viewed
                                             , "num_visits"      = num_visits
                                             , "ad_viewed_rate"  = ad_viewed_rate )
                      return(res)
                    })

ip_sum     <- arrange(ip_sum,     desc(ad_viewed_rate))
all_ip_sum <- arrange(all_ip_sum, desc(ad_viewed_rate))

all_ip_sum$log_num_ad_viewed                                 <- log(all_ip_sum$num_ad_viewed)
all_ip_sum$high_viewed_rate                                  <- 0
all_ip_sum$high_viewed_rate[all_ip_sum$ad_viewed_rate >= .9] <- 1
## Label IP address which visited the fraudsite
all_ip_sum$visited_fsite                                          <- 0
all_ip_sum$visited_fsite[all_ip_sum$ip_addr %in% ip_sum$ip_addr ] <- 1

## Plot ad_viwed_rate
## ggplot(all_ip_sum, aes(x = ad_viewed_rate, group=high_viewed_rate)) + geom_histogram(alpha=.5)
## ggplot(all_ip_sum, aes(x = ad_viewed_rate, y = log_num_ad_viewed) )+ 
##       geom_point(alpha = .3, aes(size =  5 + 10 * num_sites_visited, color = visited_fsite))
hist(all_ip_sum$ad_viewed_rate, main = "Histogram of Ad View Rate per IP")
hist(log(all_ip_sum$num_ad_viewed), border = 'black')

## median #ad visited per IP: 2
high_risk_ip <- subset(all_ip_sum, num_ad_viewed >= 2 & ad_viewed_rate > .95)[, c("ip_addr", "num_sites_visited", "num_ad_viewed", "ad_viewed_rate")] 
high_risk_ip <- arrange(high_risk_ip, desc(num_ad_viewed))
write.table(high_risk_ip, file = getDataPath(filename = "high_risk_ip.csv", dir = dir$output)
            , col.names = TRUE, row.names = TRUE, sep = ",")