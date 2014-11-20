### Overall Discussion
#### Task01: Sites having substantial amount of fraudulent traffic:
a. Scatterplot of the rate of #ad_viwed per user vs. number of unique users (fraud site highlighted with blue bubbles)
![log(ad_veiwed_per_user) vs. log(uniq_user)](/output/sites_plot.png)
*Discussion*: 
  (1) Fraud sites tends to have a high ads viwed rate (#ad_viewed / #unique users)
  (2) The website having a larger visitor base is less likely to carry substantail fraudulent visits

b. Ad view temproal pattern for websites having the total of unique visitor >= 100
![#Ad_Viewed vs. Time (in seconds)](/output/sites_uniquserGT100_ts.png)
*Dicussion*:
  (1) According to the function/content of websites, temporal pattern of visites would reveal a particular type pattern
      For example, finance.yahoo.com (and Pandora.com) has very intensified traffice during daytime and been at peak during noon. And, it has very few traffic during 12:00AM - 6:00AM. It may indicate that yahoo fiance had most of visitors within US market;
      In contrast, ebay.com has very constant visitor pattern. It makes sense that there are very large user base spreading all over the world.

c. Ad view temproal pattern for websites known as fraud traffic
![#Ad_Viewed vs. Time (in seconds)](/output/fraud_sites_ts.png)
*Discussion*
   (1) The temporal pattern of 7 sites had been plotted, with 5 having traffic spike;
   (2) One (dailyparent.com) has abnormal traffic concentrations;
   (3) Beyond the charts, it had been summarized that the know fraud sites feacturing: relative few unique users and high ad view rate 

d. Histogram of #plugin grouped by Browser type
![Histogram of #plugin](/output/ggplot_num_plugins_hist.png)
*Dicussion*:
  (1) #Plugin is highly correlated with type of browsers
  (2) Higher number of plugins might indicate the user of the browser which is more tech-savvy and 
  	  more likely to be fraud traffic creator;
  (3) The OS system and platform would alse be indicative..., windows is notoriously easily to be 
  	  hacked and muled.

#### Task02: Detect IP Address home to the machine which is a part of botnets
a. By Manully check the ip address attached to the known fraud website, some of visitor had very high ads views.
b. This type of botnet machine, they could be characterized: ads_viwes within short time frame and high ads veiew rate.
*Dicussion*: I think the IP address home to botnets is relatively reasy to detect by creating a filter constisted of two 
paramters/threshold: >= minimum ads viwed and >= mimmum ads view rate. And, any IP address meeting those two conditions could 
be labelled as risky IP. In order to detect if a website carrying a substantial amountof fraudulent traffic, by looking up if there are large number of risky IP (based on previous logic), we can design other rule to incooporate the percentage of risky IPs out of all visitor IPs as part of logic. A list of risky ip had been provided ([link](high_risk_ip.csv))