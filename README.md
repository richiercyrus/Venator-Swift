<p align="center">
<img src="https://github.com/richiercyrus/Venator-Swift/blob/master/VenatorSwift.png">
</p>

Venator is a python tool used for gathering data for the purpose of proactive macOS detection. Support for High Sierra & Mojave using native macOS python version (2.7.x). Happy Hunting!

Accompanying blog post: https://posts.specterops.io/introducing-venator-a-macos-tool-for-proactive-detection-34055a017e56

***You may need to specify `/usr/bin/python` at command line instead of "python." if you have alternative versions of python installed.**

![](https://github.com/richiercyrus/Venator/blob/master/images/Screen%20Shot%202019-04-26%20at%203.51.35%20PM.png)

S3 upload functionality is live: `python Venator.py -a <BUCKET_NAME>:<AWS_KEY_ID>:<AWS_KEY_SECRET>:<AWS_REGION>`

**The script needs root permissions to run, or else you will get the error message below.**
![](https://github.com/richiercyrus/Venator/blob/development/images/Screen%20Shot%202019-03-30%20at%201.59.31%20PM.png)



Below are the Venator modules and the data each module contains. Once the script is complete, you will be provide a JSON file for futher analysis/ingestion into a SIEM solution. You can search for data by module in the following way within the JSON file:
`module:<name of module>`


If the script is run with the '-v' flag, then the hash will be sent to VirusTotal for comparison with their database. This uses their Public API but still requires the use of an API key. You can obtain one from their site, and include it in the Venator command line (or script if appropriate):

```text
sudo VTKEY=<YOUR API KEY HERE> /usr/bin/python2.7 Venator.py -v
```

The calls to VirusTotal do add some running time due to public API key throttling.

When ran with this option a new stanza will appear where appropriate: `virustotal_result`, with possible values ```This file is OK.```, ```This file has no VirusTotal entry.``` or ```POSITIVE VT SCAN - See link_to_virustotal_entry```.
