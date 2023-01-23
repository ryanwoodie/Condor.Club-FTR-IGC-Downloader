# Condor.Club FTR & IGC Downloader
A small utility to simplify downloading multiple IGC and FTR tracks from Condor.Club.

Here are the steps for using:
- Download [here](https://github.com/ryanwoodie/Condor.Club-FTR-IGC-Downloader/releases), or copy the AutoHotKey file above.
- Recommended: install [ShowCondorIGC](https://virtualsoaring.eu/download#:~:text=showcondorigc%202.62c%20for%20c2) for analysis.
- Install [7-Zip](https://www.7-zip.org/download.html) and [CoFliCo](https://condorutill.fr/CoFliCo/CoFliCoV111.zip) tracker converter.
- Recommended: Go to your browser settings, search for downloads, and disable "Ask where to save each file before downloading".
- Run Condor.Club FTR & IGC Downloader. On the first run, it will have some configuration steps to locate the files and folders it requires. **Important**: This tool uses your default web browser to download the files, so pick the folder where your web browser normally downloads files (especially if you disabled per-file save as per above step)
- Login into Condor.Club and go to "race results" or "best performances" page. Hit ctrl+a then ctrl+c to download all available tracks on that page. Alternately, highlight only the rows you want (the very last column with the little graph icon is what matters)

This was created with AutoHotKey, you can copy/download the AHK file above, or if you don't have AHK, there is an .exe version in 

To download all available IGC and FTR files from a Condor.Club "race results" page, highlight rows in the race results table and copy (Ctrl+C) to download only the selected rows. If the URL copy doesn't work, try select all (Ctrl+A) then copy (Ctrl+C).

The IGC and FTR files will be saved to the folder specified in the CCDLconfig.ini file that is created when first run. You will also be given the option to save the FTR files to your Condor FlightTracks folder (for use as ghosts) and to automatically load the IGC files in [ShowCondorIGC](https://virtualsoaring.eu/download#:~:text=showcondorigc%202.62c%20for%20c2) for analysis.

If you haven't used ShowCondorIGC before, it is an excellent tool for Condor flight analysis and comparison. Much better than SeeYou (in my opinion) and worth the learning curve.

**Important**: You must select the correct download folder during setup (the one your default web-browser uses) for this tool to work.

Note that this tool requires a subscription to Condor.Club, and that you have [7-Zip](https://www.7-zip.org/download.html) and the [CoFliCo](https://condorutill.fr/) track converter on your computer. If you are running this program for the first time, you will be taken through setup and file/folder selection steps. You can update your settings in the future with Ctrl+i, or by deleting the CCDLconfig.ini file.
