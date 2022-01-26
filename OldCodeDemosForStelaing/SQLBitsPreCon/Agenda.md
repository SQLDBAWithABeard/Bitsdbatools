I really want to give people a lot to take away from this.

I think we do more demos and less presentations and we must remember to keep going back to the abstract as that is a fair bit of what people will judge us on.
We say we will take people from beginner to expert so we should start with that early and tell people thats what we will do and we will ramp up as the day goes on

 As I hae written out the below, it doesnt look like a lot and like it will be tough to fill 8 hours but I really dont think so if we give lots of detail and repeat a lot of things ( I watched Bucks presentation skills talk from Bits a few years ago last week and he said Tell them what you are going to tell them, tell them and then tell them what you told them (Intro, Demo, Summary))

We have an Azure Lab or they can follow along. We will try to set variables at the top for ComputerName, Instance and Database but wont go over board trying to help them. Lab machine can basically be the one I had for Singapore which has 3 instances on it a Linux HyperV, SQL on DOcker and SQL on LInux so we can easily pull up a few instances to play with no bother. Set that up with all the things we want to test and Bob is your fathers brother.

# Proposed combo with assignments
- Introductions - C&R
- What we expect from each other - Rob
- Intro to PowerShell - Rob
- Intro to dbatools - Chrissy
- Intro to Pester - 2 parts Rob - one part Chrissy
   - Mention Pester for DBAs - Rob
   - Mention Pester for Developers - Mention appveyor? - Rob
   - Mention Pester for Audits - Chrissy
   - Perhaps in-depth organizing via tags
- Writing Pester Tests (most of work)
   - Writing Pester Tests for DBAs (green is good eamples, touch on tagging) - Rob
   - Writing Pester Tests for Developers (dbatools repo, touch on tagging) - Rob for Unit, Chrissy for Integration
   - Writing Pester Tests for Audits (DISA USA, GDPR EU, touch on tagging) - Chrissy
- Crowdsourced Pester Test Writing (love the idea!) - Chrissy & Rob & Crowd
   - Decide the information you wish to test
   - Understand how to get it with PowerShell
   - Understand what makes it pass and what makes it fail
   - Write the test
- Tools we use - Rob
   - Appveyor
   - VSTS
   - PowerBI
   - Tagging for collaboration
- Introducing the dbachecks module (1.5 hours since it brings things together?) - C&R
   - Bring all of this together
   - Prerequisites
   - Installing
       - "Offline" installs
   - Getting started
   - Making server lists
       - Other ways to execute checks against specific servers
   - Check and ExcludeCheck
   - Reporting on the data (Rob)
       - Power BI
       - Mail
       - Other
   - Advanced usage
   - Setting a global SQL Credential
   - Create your own repo or add to ours
       - Add a check to one of ours
       - Create a new super custom check and add repo
       - Rob can talk about the unit testing he did to ensure tests conform
   
   
# Rob's Agenda
Putting this in here as a brain dump whilst I am in a flow!

- Introductions
- What we expect from each other
- What is dbatools - Super quick overview as it is the base for all of the goodness
- OK lets learn PowerShell and get us all up to speed. Also an introduction to how to get things with dbatools - also test things (like connections with Test-DBAConnection because I showed someone that today :-) Slowly build up the knowledge from nothing to kind of ok - Drews presentation at PASS is a good example of some of the things
- And then an intro to Pester - not the green is good but something similar more like the Write your first Pester Test - we shall write a few adn get interaction - get people to help
 - Decide the information you wish to test
 - Understand how to get it with PowerShell
 - Understand what makes it pass and what makes it fail
 - Write a Pester Test
 - Test 
- Then your audit story because it is awesome and fantastic and if it can be done with demos 
-   
- Then collaboration, teamwork using Tag - outputting results - This is the appveyor bit
- Maybe - Some VSTS build with the results etc
- 
- Building up to the Restore SQL Servers to their correct state prior and post deployment, the fancy PowerBi (if it looks good with our examples) and the age old question of Can I take Action on the tests which is a No but also a Yes
- 
- Q and A

# Chrissy's Agenda with Rob's Agenda's input
- Intro to dbatools
- Intro to Pester
   - Mention Pester for DBAs
   - Mention Pester for Developers
   - Mention Pester for Audits (or do we keep it only in the second section? I think audits will be huge)
   - Perhaps in-depth organizing via tags
- Writing Pester Tests (most of work)
   - Writing Pester Tests for DBAs (green is good eamples, touch on tagging)
   - Writing Pester Tests for Developers (dbatools repo, touch on tagging)
   - Writing Pester Tests for Audits (DISA USA, GDPR EU, touch on tagging)
- Crowdsourced Pester Test Writing (love the idea!)
- Tools we use
   - Appveyor
   - VSTS
   - PowerBI
   - Tagging for collaboration, like you say
- Introducing the XYZ module
   - Bring all of this together
   - Tagging
