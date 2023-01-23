# Condor.Club FTR & IGC Downloader
A small utility to simplify downloading multiple IGC and FTR tracks from Condor.Club.

Here are the steps for using:
- Download exe file [here](https://github.com/ryanwoodie/Condor.Club-FTR-IGC-Downloader/releases), or copy the AutoHotKey file above.
- Required: Install [7-Zip](https://www.7-zip.org/download.html) and [CoFliCo](https://condorutill.fr/CoFliCo/CoFliCoV111.zip) FTR-to-IGC file converter.
- Recommended: Install [ShowCondorIGC*](https://virtualsoaring.eu/download#:~:text=showcondorigc%202.62c%20for%20c2) for analysis.
- Recommended: If your browser is set to "Ask where to save each file before downloading", disable this in your browser settings.
- Run Condor.Club FTR & IGC Downloader. On the first run, it will have some configuration steps to locate the files and folders it requires. **Important**: This tool uses your default web browser to download the files, so make sure to pick the folder where your web browser normally downloads files (especially if you disabled per-file save as per above step)
- Login into Condor.Club and go to any task's "race results" or "best performances" page. Hit ctrl+a then ctrl+c to download all tracks on that page. Alternately, highlight with your mouse only the rows/tracks you want (the little chart icons ![](https://www.condor.club/i/graph2.gif) in the last column are what need to be highlighted to be exact). This tool will download (and later delete) the ZIP file, extract its FTR file, create an IGC copy, rename them to more detailed filenames, and save them in a subfolder named after the task. Optionally, it will also put a copy of the FTR files in your Condor FlightTracks folder for use as ghosts.
- After it finishes downloading, you will have to option to open all the tracks in ShowCondorIgc.
- Ctrl + I or edit the CCDLconfig.ini file to change settings.

*If you haven't used ShowCondorIGC before, it is an excellent tool for Condor flight analysis and comparison. Much better than SeeYou (in my opinion) and worth the learning curve.

You will need subscription Condor.Club to download more than 5 tracks a month.

Note, there is a chance you or your IP address could get blocked from Condor.Club for 24 hours. I only got blocked when downloading from large task with 90+ tracks, and have added an (untested) 5 minute delay when it hits 80 tracks because of this.
