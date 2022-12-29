# Condor.Club FTR & IGC Downloader
A small utility to simplify downloading multiple IGC and FTR tracks from Condor.Club

This was created with AutoHotKey, you can copy/download the AHK file above, or if you don't have AHK, there is an exe version in releases.

To download all available IGC and FTR files from a Condor.Club "race results" page, you can either copy (Ctrl+C) the page URL or highlight rows in the race results table and copy (Ctrl+C) to download only the selected rows. If the URL copy doesn't work, try select all (Ctrl+A) then copy (Ctrl+C).

The IGC and FTR files will be saved to the folder specified in the CCDLconfig.ini file that is created when first run. You will also be given the option to save the FTR files to your Condor FlightTracks folder (for use as ghosts) and to load the IGC files in [ShowCondorIGC](https://virtualsoaring.eu/download#:~:text=showcondorigc%202.62c%20for%20c2) for analysis.

**Important**: You must select the correct download folder (the one your default web-browser uses) for this tool to work.

Note that this tool requires [7-Zip](https://www.7-zip.org/download.html) and the [CoFliCo](https://condorutill.fr/) track converter. If you are running this program for the first time, you will be taken through setup and file/folder selection steps. You can update your settings in the future with Ctrl+i, or by deleting the CCDLconfig.ini file.
