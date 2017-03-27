# Overview of Things Done/To Do

## TODO Lists

### Server Setup for Access and Kdt_Output_Stripper
- [x] Set up Shiny proxy + authentication
- [x] Update mounted drive access
- [x] Upgrade RVM
- [x] Upgrade Ruby
- [x] Upgrade Gems
- [x] Upgrade Passenger
- [x] Upgrade Access to branch 1.1.0
- [ ] Re-configure SSL
- [ ] Ensure SSL-only access to both shiny sites and main Rails sites
- [ ] Fix LDAP oauth flow for Partners logins
- [ ] Allow Access to run on SSL and KDT tool to run at the same time

### Tasci Merger
- [x] Update core code with recent mappings
- [ ] Release new version of gem with updated inputs
- [ ] Update Access to use new version of gem
- [ ] Test on Tasci Locations on T, I, and X drives

### Access to Database and Data Requests
- [ ] Ensure Scott/Beth Partners accounts allow login to Access
- [ ] Determine location of data requested by John: database vs. files
- [ ] Download and compile database data for John
- [ ] Train Scott on use of Access tool for DB data downloads (and possibly revamp tool)

### Sleep Structure Manuscript
- [ ] Update figures to match Andrew's comments
- [ ] Target journal still Sleep?
- [ ] Set target submission date!


## Shiny Apps and Server Setup

### Resources
1. https://weihanglo.gitbooks.io/debian-server-for-r-computing/content/doc/other_nginx.html
2. http://docs.rstudio.com/shiny-server/
3. https://www.r-bloggers.com/add-authentication-to-shiny-server-with-nginx/
4. https://github.com/sleepepi/sleepepi/tree/master/virtual-machines
5. https://wiki.centos.org/TipsAndTricks/WindowsShares

The root for these apps is `/srv/`

The configuration file for shiny server is at:
```
/etc/shiny-server/shiny-server.conf
```

`scott kdttime`
`beth tascitime`

### Ruby Apps
The NGINX configuration can be found at `/usr/local/nginx/config`

## Work Log
Logged into `dsm2.dipr.partners.org`. This VM holds the NGINX and the Shiny Servers.

I need to figure out how to allow both Shiny and Ruby apps to run on the server.

1. Set up Shiny with authentication using this source: https://www.r-bloggers.com/add-authentication-to-shiny-server-with-nginx/
  a. Modified NGINX config to re-route /kdt/ requests to the Shiny port
  b. Modified Shiny Server config to only allow port access from localhost

2. Lots of RVM/Ruby/Gem/Passenger etc. updates
```
  passenger_root /PHShome/pwm4/.rvm/gems/ruby-2.1.1/gems/passenger-4.0.41;
  passenger_ruby /PHShome/pwm4/.rvm/wrappers/ruby-2.1.1/ruby;
```

3. Updated Ruby and Passanger. Had to re-configure NGINX. Followed setup from https://github.com/sleepepi/sleepepi/tree/master/virtual-machines. Integrated both Shiny and Normal webserver.

After setting everything up, ran into problems with SSL access to the ruby app. Received a 503 error for no reason.

4. Windows share mounts: https://wiki.centos.org/TipsAndTricks/WindowsShares
(These need to be updated periodically)

### Sleep Structure Manuscript
Andrew thoughs:

### Two sources of novelty
- Looking at sleep structure Forced Desynchrony protocols
- Finding wrt. what awakenings do to the structure of the sleep/wake NREM/REM cycle
  especially figure 8.

### Other Thoughts
- Another version of of figure 8:
  circadian phase of

  * instead of all possible bouts, use starting in circadian phases

- Figure 2/3 --> 2a and 2b to include information about FD

- Figure 1 --> supplement to show it looks the same
- Figure 5 and Figure 6 -> we need only one of them in main paper
 rest goes to supplemental

- Figure 4 --> can't link to narrative, would need to show it more

- Figure 7 --> use FD results?


Figures in:
- Figure 7 ->
  boxes around the panels and seperate the panels
  font bigger on axes
  label panel (a,b,c,d...)

- Figure 8 -> an alternative version in (restriction of circadian phases to circ day and circ night)
-
