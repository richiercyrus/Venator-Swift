![](https://github.com/richiercyrus/Venator-Swift/blob/master/VenatorSwift.png)

Author: [@rrcyrus](https://twitter.com/rrcyrus)

Major Contributor: [@Airzero24](https://twitter.com/Airzero24)

Venator-Swift is a Swift tool used for gathering data for the purpose of proactive macOS detection. Support for 10.13 and above. Happy Hunting!

Accompanying blog post: https://posts.specterops.io/introducing-venator-a-macos-tool-for-proactive-detection-34055a017e56

**The tool needs root permissions to run, or else you will get the error message below.**

![](https://github.com/richiercyrus/Venator-Swift/blob/master/images/Screen%20Shot%202020-06-26%20at%209.35.45%20AM.png)

Venator-Swift has a number of different features including the ability to upload host data to an Amazon S3 Bucket and enrich data using Virustotal.
![](https://github.com/richiercyrus/Venator-Swift/blob/master/images/Screen%20Shot%202020-06-26%20at%209.36.57%20AM.png)

- By default, the resulting file will created in the `/tmp` directory. You can specify an alternate path by using the `-o` flag.
- When uploading to S3 `-r` or `--region` refers to the region your bucket is in. Regions that are supported are specified [here](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints). 
- To obtain a Virustotal API key to be used with Venator-Swift, refer to the following documentation: https://developers.virustotal.com/reference
- You can also specify modules you would like to run as opposed to the default action (which is to run all modules). A list of modules are below: 
```
launchagents
launchdaemons
sip
gatekeeper
cronjobs
apps
bashhistory
zshhistory
loginitems
firefoxExtension
chromeExtension
installhistory
periodicscripts
connections
startupscripts
eventtap
kext
```
