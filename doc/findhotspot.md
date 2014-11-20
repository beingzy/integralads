<p><strong>Data limitation</strong>: the data collection covers a short time window, which is not sufficient to be utilized to re-construct the traffic pattern for an IP address block.</p>
<p><strong>Assumption: </strong></p>
<ol style="list-style-type: lower-alpha">
<li><p>IP address bock reservation scheme:</p>
<ul>
<li><p>xxx.xxx.-.- style IP address reservation: (e.g. all ip address starting with 123.234 are reserved for a particular organization and considered as hotspot)</p></li>
<li><p>[xxx.xxx.xxx.- , xxx.xxx.xxx.-] style IP address reservation: (e.g. all ip addresses falling on the range between 123.234.115.001 – 123.234.120.254 are reserved and considered as hotspot)</p></li>
</ul></li>
<li><p>Unique user identifier:</p>
<ul>
<li><p>Ip_address + user_agent_str is a proxy for unique user identifier</p>
<p>An IP address could be assigned to different users at different time point. However, during a day, it is also possible that a single user could be assigned with multiple IP addresses if dynamic scheme is adopted after rebooting system.</p>
<p>Limitation:</p></li>
</ul></li>
</ol>
<ol style="list-style-type: lower-alpha">
<li><p>This proxy could overstate the number of unique users, with respect to some user could surfing internet with computer and mobile devices simultaneously. In this situation, using ip_address + user_agent_str as proxy for unique user identifier could overstate the number of unique users;</p></li>
<li><p>In some organization, multiple user scould use same public IP address. At this situation, using ip_address + user_agent_str could understate the number of unique users. Therefore, utilizing the internet visiting patterns regarding the domain name could be capable of separating individuals (In this study, the approach coping with this situation is not discussed).</p></li>
</ol>
<ol style="list-style-type: lower-alpha">
<li><p>OS distributions of user computers within a IP address block:</p>
<p>Within a cooperate organization, it is very likely that the distribution of Computer OSs concentrates on a particular type of OSs system. However, the concentration or diversity of OSs could vary according to the business and culture of the corporate. And, it is also possible for some IT service company’s OS distributions could be as diversified as the nation-wide OS distribution. In contrast, within a public hotspot, e.g. Starbucks, the OS distribution of internet terminals supposed to resonate the benchmark OS distribution within its geographic area (Be caution, customer bases highly focusing on segment of residents. Therefore, such claim may not be true for them).</p></li>
<li><p>Daily traffic pattern and Weekly traffic pattern:</p>
<p>The internet surfing traffic within an organization should align with work hour schedule or reveal some opposite pattern. Using an industrial cooperate as an example, during weekdays, the traffic should be at high-level during work hours. And, in contrast, it stays at low-level during non-work hours. At weekends, the traffic remains at relatively low level in general. For non-cooperate organization, the traffic could reveal different patterns. For example, Starbuck chain store could generate high traffic beyond cooperate work hours (7:30AM – 8:30 AM, 5:00PM – 7:00PM during weekdays). And daily total users could be at highest level for weekend days.</p></li>
</ol>
<p>In conclusion, a hotspot should reveal a regular pattern with respects to users profile, visits information and the nature of the organization.</p>
<p><strong>PART I: Data preparation:</strong></p>
<p>In this section, the data process, including feature extraction and transformation, are discussed in details.</p>
<p>Raw data (time_stamp, ip_address, uri, complete uri, user_agent_str)</p>
<p><strong>Feature Extraction:</strong></p>
<ol style="list-style-type: lower-alpha">
<li><p>Extract user_agent_str, to extract OS information and encode it with a set of binary variables: is_windows, is_mac, is_linux, is_mobile (Android + iOS)</p></li>
<li><p>Re-encode time_stamp with their weekday (1, 2, … and 7) and hours</p></li>
<li><p>Decompose IP(ipv4) address into 4 components.</p></li>
</ol>
<p><strong>Aggregate Information:</strong></p>
<ol style="list-style-type: lower-alpha">
<li><p>Grouping records/rows by first two components of IP address, weekday, hour</p></li>
<li><p>Computing aggregate information <em>at hourly level</em>:</p>
<ol style="list-style-type: decimal">
<li><p>#unique_user: the number of unique combinations of IP address and user_agent_str</p></li>
<li><p>#windows, #mac, #linux, #mobile</p></li>
</ol></li>
<li><p>Computing aggregate information to ip_address block (first components of IP address) over a week</p>
<ol style="list-style-type: decimal">
<li><p>Compute windows_pct, mac_pct, linux_pct, mobile_pct of entire weekly data:</p>
<p>(e.g. windows_pct = #windows / sum(#windows, #mac, #linux, #mobile) )</p>
<ol style="list-style-type: lower-roman">
<li><p><strong>dominating_os_pct:</strong> max(windows_pct, mac_pct, linux_pct, mobile_pct)</p></li>
<li><p><strong>inequality_idx:</strong> sum(windows_pct^2, mac_pct^2, linux_pct^2, mobile_pct^2): the metric would emphasize the unevenness of OS distribution</p></li>
</ol></li>
<li><p>Compute the daily total unique user over a week</p></li>
</ol></li>
</ol>
<table>
<thead>
<tr class="header">
<th align="left"><p>ip_block (first 2 components)</p></th>
<th align="left"><p>mon_user_total</p></th>
<th align="left"><p>tue_user_total</p></th>
<th align="left"><p>…</p></th>
<th align="left"><p>sat_user_total</p></th>
<th align="left"><p>sun_user_total</p></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><p>123.245</p></td>
<td align="left"><p>2399</p></td>
<td align="left"><p>2194</p></td>
<td align="left"></td>
<td align="left"><p>200</p></td>
<td align="left"><p>181</p></td>
</tr>
</tbody>
</table>
<ol style="list-style-type: decimal">
<li><p>Compute workhour_pattern_ind, weekday_high_ind and weekend_high_ind,</p>
<ol style="list-style-type: lower-roman">
<li><p>workhour_pattern_ind: create a binary variable based on the <em>hourly aggregate</em>, <strong>the value equals to 1</strong> if the distribution hourly user total are concentrated within a window of consecutive hours (de-localization, no necessary to convert time stamp to local time zone); <strong>Otherwise,</strong> <strong>0</strong> if hourly user totals are evenly distributed over a day;</p>
<p><strong>Calculation demonstration (for an IP address block):</strong></p></li>
</ol></li>
</ol>
<table>
<thead>
<tr class="header">
<th align="left"><p>Hour</p></th>
<th align="left"><p>00:00AM</p></th>
<th align="left"><p>…</p></th>
<th align="left"><p>7:00AM</p></th>
<th align="left"><p>8:00AM</p></th>
<th align="left"><p>9:00AM</p></th>
<th align="left"><p>…</p></th>
<th align="left"><p>4:00PM</p></th>
<th align="left"><p>5:00PM</p></th>
<th align="left"><p>6:00PM</p></th>
<th align="left"><p>…</p></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><p>hourly_user_total</p></td>
<td align="left"><p>15</p></td>
<td align="left"></td>
<td align="left"><p>30</p></td>
<td align="left"><p>120</p></td>
<td align="left"><p>200</p></td>
<td align="left"></td>
<td align="left"><p>320</p></td>
<td align="left"><p>200</p></td>
<td align="left"><p>45</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><p>user_total_change_pct*</p></td>
<td align="left"><p>-</p></td>
<td align="left"></td>
<td align="left"><p>10%</p></td>
<td align="left"><p>300%</p></td>
<td align="left"><p>66.67%</p></td>
<td align="left"></td>
<td align="left"><p>10%</p></td>
<td align="left"><p>60%</p></td>
<td align="left"><p>344%</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"><p>Jump_ind</p></td>
<td align="left"><p>-</p></td>
<td align="left"></td>
<td align="left"><p>0</p></td>
<td align="left"><p>1</p></td>
<td align="left"><p>0</p></td>
<td align="left"></td>
<td align="left"><p>0</p></td>
<td align="left"><p>0</p></td>
<td align="left"><p>1</p></td>
<td align="left"></td>
</tr>
</tbody>
</table>
<p><strong>Formula: </strong></p>
<p>user_total_change_pct = abs( #user_(t+1) - #user_(t) ) / min(#user_(t+1), #user_(t))</p>
<p><strong>Return:</strong></p>
<p>Workhou_pattern_ind = 1, if sum(jump_ind over t) &gt;= 2; Otherwise, 0</p>
<ol style="list-style-type: lower-roman">
<li><p><strong>weekday_high_ind:</strong> based on daily user total, <strong>equals to 1</strong> if the average of daily user total for weekdays is substantially larger than the counterpart of weekends; Otherwise, it is 0;</p></li>
<li><p><strong>weekend_high_ind:</strong> based on daily user total, equals to 1 if the average of daily user total for weekdays is substantially larger than the counterpart of weekdays; Otherwise, it is 0:</p>
<p>(For ip address reveals no weekday effects, it means that the daily user totals are evenly distributed. In this situation, weekday_high_ind = 0 and weekend_high_ind)</p></li>
<li><p><strong>weekday_effect_ind</strong>: <strong>weekday_high_ind</strong> or <strong>weekend_high_ind</strong></p></li>
</ol>
<p><strong>Final Aggregate Profile of an IP Address block:</strong></p>
<ol style="list-style-type: lower-alpha">
<li><p><em>Row identifier</em><strong>: ip_address_block</strong> (e.g. 123.201)</p></li>
<li><p><em>Columns about user counts:</em> <strong>average_user_total</strong>, weekday_daily_user_total, weekend_daily_user_total</p></li>
<li><p><em>Columns about OS distribution:</em> <strong>dominating_os_pct, os_gini_coefficient (to depict the overall dispersenty</strong> , windows_os_pct, mac_os_pct, linux_oc_pct, mobile_os_pct</p></li>
<li><p><em>Columns about traffic distribution</em>: <strong>workhour_pattern_ind,</strong> <strong>weekday_effect_ind</strong>, weekday_high_ind, weekend_high_ind, weekday</p></li>
</ol>
<p><strong>PART II: Hot-Spot detection:</strong></p>
<p><strong>Assumption: </strong></p>
<ol style="list-style-type: lower-alpha">
<li><p>xxx.xxx.-.- : style 1 IP address block;</p></li>
<li><p>[xxx.xxx.xxx.- , xxx.xxx.xxx.-]: style 2 IP address block;</p></li>
</ol>
<p><strong>Step01: </strong></p>
<p>Categorize IP address blocks of grouping by 1<sup>st</sup> and 2<sup>nd</sup> components of IP addresses into either a) style 1 IP address block or 2) possible style 2 address block (the first 2 components ip address can be fully split into multiple style-2 ip address blocks).</p>
<p>Categorization rule based on the <strong>daily average user</strong>:</p>
<ol style="list-style-type: lower-alpha">
<li><p>If daily average user is very large: Possible style 2 address blocks, the part of addresses are subject to re-assignment and other part of addresses reserved for organizations. Therefore, as whole address block, it could include a huge number of unique users and large diversity of OSs. This address blocks (xxx.xxx.-.-) is recommended to fully split to (xxx.xxx.xxx.- , xxx.xxx.xxx.-). And sub-blocks should be used against to aggregate data in the same fashion as described above to evaluate if the sub-block can be considered as a hotspot.</p></li>
<li><p>If daily average user is relatively large, it could be style 1 ip address block and should be evaluated by processes described in the step 02.</p></li>
</ol>
<p><strong>Step02: training classifier for </strong></p>
<ol style="list-style-type: lower-alpha">
<li><p>Frame the study as non-supervise learning, using the aggregate data described above to do clustering analysis or naïve bayes decision to segment the ip address block.</p></li>
<li><p>Frame the study as semi-supervise learning, if some ip blocks’ hot-spot status can be known. Using this given label to train a classifier.</p></li>
</ol>
