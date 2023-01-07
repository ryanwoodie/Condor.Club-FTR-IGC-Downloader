#warn
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


global config := 0
loadCCDLconfig()
SetTimer, RemoveTooltip, 5000


start:
loop
{
clipboard := ""
longpause := 0
global time := A_now
global time2 := ""
global sleeprandom := 0
AllTracks := ""
while (clipboard = "")
  {
  ToolTip, Highlight`, or select all (ctrl+a)`, and copy (ctrl+c) Condor.Club Race Result rows to start download. Ctrl+i to change settings. ESC to exit
  sleep 100
  }

RegExMatch(clipboard,"http.*id=\K(\d*)",AllTracks)
  if (AllTracks != "")
  {
    clipboard :=
    runwait https://www.condor.club/comp/besttimes/0/?id=%AllTracks%
    sleep 3000
    send ^a
    sleep 1500
    send ^c
    sleep 100
  }

ClipboardGet_HTML( Data )
Clipboard1 := RegExReplace(Data,"http\S*analysis\S*res=", "¢",count)
Clipboard2 := RegExReplace(Data,"http\S*analysis\S*rank=", "¢",count2)
Clipboard1 := Clipboard1 . Clipboard2
if  (count < 1) and (count2 < 1)
 {
 MsgBox, 4,, A track was not found in copied data. Click "yes" and try again, or click "no" to exit app. If you copied the Condor URL, try to select all (Ctrl+a) and copy (ctrl+c) on the results page instead.
 IfMsgBox Yes
   goto start
   else
   exitapp
 }

If (Count2 = 0)
  count2 := ""
if (Count = 0)
  count := ""
MsgBox, 4,, Ready to download %count%%count2% tracks. Would you also like to copy the FTRs to your Condor FlightTrack folder (eg. to use as ghosts)?
IfMsgBox Yes
   global CopyFTR := 1
  else
   global CopyFTR :=
if (SaveToSubfolder = "No")
  FileDelete,%IGCandFTRFolder%\SCITemp\*.igc



Loop,parse,Clipboard1,¢
 {
   Global Result
   RegExMatch(A_LoopField,"^\d{4,7}",Result)
if (Result > 1000) and (Result < 1000000)
{
  ToolTip,Downloading %Result%.ftr
  rank :=
  if(count2 > 0)
      rank := "&rank=1&next=1"
  WinGetActiveTitle, OutputVar
  download_url := "https://www.condor.club/download2/0/?res=" . Result . Rank
  runwait, %download_url%,,HIDE
  sleep 500
  WinActivate, %OutputVar%
  if (longpause++ = 20)
    {
      random,sleeprandom,30000,120000
      longpause := 0
    }
    else
      random,sleeprandom,% DownloadSleepMilliSeconds - 1000,% DownloadSleepMilliSeconds + 1000
  sec := sleeprandom/1000
  Tooltip, Taking a %sec% second pause on downloading (to avoid getting blocked by Condor.Club)
  sleep %sleeprandom%
  unzip()
  time := A_Now
 }
 }



 MsgBox, 4,, Launch ShowCondorIGC and load tracks?
   IfMsgBox Yes
     LaunchSCI()
  else
    {
    if (SaveToSubfolder=1)
      run, explorer.exe "%IGCandFTRFolder%\%task%"
    else
      run, explorer.exe "%IGCandFTRFolder%"
    }
ToolTip, CC FTR & IGC Downloader will exit in 10 seconds. Hit Ctrl+r to keep it running or ESC to exit now.
sleep 10000
ExitApp
}

unzip()
{
global
wait := 0
StartTime := A_TickCount
while (wait=0)
{
ElapsedTime := A_TickCount - StartTime
if (ElapsedTime > 20000)
    {
     msgbox, If a track has finished downloading, but you get this message, please make sure that the folder that the tracks are being downloaded to is the same folder that is in the CCDLconfig.ini file, or delete CCDLconfig.ini to allow the setup to run again.
     StartTime := A_TickCount
   }
local Files
Files := ""
Loop, Files, %DownloadFolder%\*.zip
{
  if (A_LoopFileTimeCreated >= time)
    {
    Wait:=1
    time2 := A_Now
    Runwait, %7zip% x "%DownloadFolder%\%A_LoopFileName%" -o%IGCandFTRFolder% -y,,hide
    RegExMatch(A_LoopFileName,"(.*)(?=-.*-.*zip)",task)
    FileDelete, %DownloadFolder%\%A_LoopFileName%
    MakeFTR()
    }
  }
  sleep 100
  }
  return
}

MakeFTR()
{
global
SetWorkingDir %IGCandFTRFolder%
local Files
Loop, Files, *.ftr
{
  if (A_LoopFileTimeCreated >= time2)
  {
  runwait %CoFliCo% "%A_WorkingDir%\%A_LoopFileName%",,hide
  sleep 100
  igcfile := StrReplace(A_LoopFileName,".ftr", ".igc")
  fileread IGC, %igcfile%
  sleep 100
    RegExMatch(IGC, "(?<=HFCIDCOMPETITIONID:)(.*)",callsign)
    RegExMatch(IGC, "(?<=LCONFlightInfoDistanceFlown=)(.*)",distance)
    ;RegExMatch(IGC, "(?<=HFCIDCOMPETITIONID:)(.*)",name)
    RegExMatch(IGC, "(?<=LCONFPLLandscape=)(.*)",landscape)
    RegExMatch(IGC, "(?<=LCONFlightInfoAverageSpeed=)(.*)",speed)
    speed := StrReplace(speed,"km/h", "kph")
    FormatTime, modtime , %A_LoopFileTimeModified%, yyyy-MM-dd
  filelong = %Result% %callsign% %distance% %speed% %landscape% %modtime%
  sleep 100
  if (CopyFTR)
    filecopy,%A_LoopFileName%,%FlightTracksFolder%\%filelong%.ftr
  if (SaveToSubfolder="Yes")
    {
    if (task="")
      task := landscape . "-" . modtime
    FileCreateDir,%task%
    sleep 200
    SetWorkingDir %IGCandFTRFolder%\%task%
    scifile = %A_WorkingDir%\%filelong%.igc
    }
    else
    {
      FileCreateDir,SCITemp
      filecopy,%igcfile%,SCITemp\%igcfile%
      scifile = %A_WorkingDir%\SCITemp\%igcfile%
     }
    Filemove, %IGCandFTRFolder%\%igcfile%,%filelong%.igc,1
    Filemove, %IGCandFTRFolder%\%A_LoopFileName%,%filelong%.ftr,1
    }
  }
SetWorkingDir %A_ScriptDir%
Return
}

ClipboardGet_HTML( byref Data ) { ; www.autohotkey.com/forum/viewtopic.php?p=392624#392624
If CBID := DllCall( "RegisterClipboardFormat", Str,"HTML Format", UInt )
 If DllCall( "IsClipboardFormatAvailable", UInt,CBID ) <> 0
  If DllCall( "OpenClipboard", UInt,0 ) <> 0
   If hData := DllCall( "GetClipboardData", UInt,CBID, UInt )
      DataL := DllCall( "GlobalSize", UInt,hData, UInt )
        , pData := DllCall( "GlobalLock", UInt,hData, UInt )
    , Data := StrGet( pData, dataL, "UTF-8" )
    , DllCall( "GlobalUnlock", UInt,hData )
DllCall( "CloseClipboard" )
Return dataL ? dataL : 0
}

loadCCDLconfig()
{
global
IniRead,FirstRun,CCDLconfig.ini,Settings,FirstRun,%A_space%
if (FirstRun!="no") or (config=1)
{
MsgBox, 4,Condor.Club FTR & IGC Downloader,To download all available IGC and FTR files from a Condor.Club "race results" page, you can either copy (Ctrl+C) the page URL or highlight rows in the race results table and copy (Ctrl+C) to download only the selected rows.`n`nThe IGC and FTR files will be saved to the folder specified in the CCDLconfig.ini file. You will also be given the option to save the FTR files to your Condor FlightTracks folder (for use as ghosts) and to load the IGC files in ShowCondorIGC for analysis.`n`nNote that this tool requires 7-Zip and the CoFliCo track converter (available at https://condorutill.fr/). If you are running this program for the first time, you will be taken through setup and file/folder selection steps. You can update your settings in the future by deleting the CCDLconfig.ini file.`n`nWould you like to display this message again the next time the program runs?

IfMsgBox Yes
    IniWrite Yes,CCDLconfig.ini, Settings, FirstRun
else
    IniWrite No,CCDLconfig.ini, Settings, FirstRun
  }

loop,3
{

IniRead,DownloadFolder,CCDLconfig.ini,Settings,DownloadFolder,%A_space%
  if (DownloadFolder="") or (config = 1)
  {
  DLdefault :=  GetDownloadPath()
  FileSelectFolder, Folder,*%DLdefault%,,Select the folder where your default web-browser downloads files. IMPORTANT: This tool will not work if you do not choose the same folder that your web-browser downloads to.
  if (errorlevel = 0)
  IniWrite %Folder%, CCDLconfig.ini,Settings, DownloadFolder
  }

IniRead,IGCandFTRFolder,CCDLconfig.ini,Settings,IGCandFTRFolder,%A_space%
  if (IGCandFTRFolder="")  or (config = 1)
  {
  FileSelectFolder, Folder2,,1,Select folder to save IGC and FTR files to.
  if (errorlevel = 0)
  IniWrite %Folder2%, CCDLconfig.ini,Settings, IGCandFTRFolder
  }

IniRead,SaveToSubfolder,CCDLconfig.ini,Settings,SaveToSubfolder,%A_space%
  if (SaveToSubfolder="")  or (config = 1)
  {
  MsgBox, 4,, Would you like FTR and IGC files from the same race/task to be put into a new subfolder in %Folder2% that is named after the task? (Recommended)
  IfMsgBox Yes
      IniWrite Yes,CCDLconfig.ini, Settings, SaveToSubfolder
  else
      IniWrite No,CCDLconfig.ini, Settings, SaveToSubfolder
      }

IniRead,7zip,CCDLconfig.ini,Settings,7zip,%A_space%
  if (7zip="")  or (config = 1)
  {
  FileSelectFile, 7zip,1,C:\Program Files\7-Zip\7z.exe,Find your 7zip 7z.exe file,*.exe
  IniWrite %7zip%, CCDLconfig.ini,Settings,7zip
  }

IniRead,CoFliCo,CCDLconfig.ini,Settings,CoFliCo,%A_space%
  if (CoFliCo="")  or (config = 1)
  {
  FileSelectFile, CoFliCo,1,%A_ScriptDir%\CoFliCo.exe,Find your CoFliCo.exe file,*.exe
  if (errorlevel = 0)
  IniWrite %CoFliCo%, CCDLconfig.ini,Settings, CoFliCo
  }

IniRead,FlightTracksFolder,CCDLconfig.ini,Settings,FlightTracksFolder,%A_space%
  if (FlightTracksFolder="")  or (config = 1)
  {
  FileSelectFolder, Folder,*%A_MyDocuments%\Condor\FlightTracks,,Select your Condor FlightTracks folder download folder
  if (errorlevel = 0)
  IniWrite %Folder%, CCDLconfig.ini,Settings,FlightTracksFolder
  }

  if (config = 1)
    {
    FileSelectFile,SCIexe,1,*c:\condor2\ShowCondorIgc.exe,Locate your ShowCondorIGC.exe file. Cancel if you don't have ShowCondorIGC
    if (errorlevel = 0)
    IniWrite %SCIexe%, CCDLconfig.ini,Settings,SCIexe
    }

IniRead,DownloadSleepMilliSeconds,CCDLconfig.ini,Settings,DownloadSleepMilliSeconds,%A_space%
  if (DownloadSleepMilliSeconds="")  or (config = 1)
  {
  InputBox, DownloadSleepMilliSeconds, Pause time (ms) between downloads, If Condor Club detects downloads happening too quickly it might block your IP address for 24 hours. Specify a longer pause time (in milliseconds) if you run into this issue. (default 3000) ,,,,,,,,3000
  if (errorlevel = 0)
  IniWrite %DownloadSleepMilliSeconds%, CCDLconfig.ini,Settings,DownloadSleepMilliSeconds
  }

config := 0
}
return
}

launchSCI()
{
global
IniRead,SCIexe,CCDLconfig.ini,Settings,SCIexe,%A_space%
if (SCIexe="")
  {
  FileSelectFile,SCIexe,1,*c:\condor2\ShowCondorIgc.exe,Locate your ShowCondorIGC.exe file
  if (errorlevel = 0)
  IniWrite %SCIexe%, CCDLconfig.ini,Settings,SCIexe
  }
run, %SCIexe%
tt = ShowCondorIGC
WinWait, %tt%
IfWinNotActive, %tt%,, WinActivate, %tt%

WinMenuSelectItem, ShowCondorIGC,,Favorites
WinWait, Favorites
IfWinNotActive, Favorites,, WinActivate, Favorites
ControlFocus,Load Folder (IGC),Favorites
ControlSend, Load Folder (IGC),{enter},Favorites
WinWaitClose,Task
WinWait,Open
sleep 50
ControlSetText,Edit1,%scifile%,Open
sleep 50
ControlSend,Edit1,{enter},Open
Return
}

GetDownloadPath() {
	RegRead, v, HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, {374DE290-123F-4565-9164-39C4925E467B}
	return ComObjCreate("WScript.Shell").ExpandEnvironmentStrings(v)
}

^i::
{
  global config := 1
  loadCCDLconfig()
  return
}

RemoveTooltip:
  ToolTip
  settimer,RemoveTooltip,off
  return

ESC::
exitapp

^r::goto start
