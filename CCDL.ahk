#warn
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

global config := 0
msg1 :=
loadCCDLconfig()
SetTimer, ttip, 500

start:
  loop
  {
    clipboard := ""
    longpause := 0
    longerpause := 0
    global time := A_now
    global time2 := ""
    global sleeprandom := 0
    dlcount := 0
    AllTracks := ""
    while (clipboard = "")
    {
      msg = Highlight`, or select all (ctrl+a)`, and copy (ctrl+c) Condor.Club Race Results/Best Performances page rows to start download.`nCtrl+i to change settings.`nESC to exit
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
    if (count < 1) and (count2 < 1)
    {
      MsgBox, 4,, A track was not found in copied data. Are you signed into Condor.Club? The last column of the table with the little square icon must be copied when selecting rows. Or just select all (Ctrl+a) and copy (ctrl+c) to get all tracks on a race results/best performances page.`n`nClick "yes" and try again, or click "no" to exit app.
      IfMsgBox Yes
        goto start
else
exitapp
    }

    If (Count2 = 0)
      count2 := ""
    if (Count = 0)
      count := ""
    if (count > 80) or (count2 > 80)
      longwarning := "There will be a long 5 minute pause after downloading 80 tracks to try to avoid getting blocked by Condor.Club. "
    else
      longwarning := ""
    MsgBox, 4,, Ready to download %count%%count2% tracks. %longwarning%`n`nWould you also like to copy the FTRs to your Condor FlightTrack folder (ie. to use as ghosts)?
    IfMsgBox Yes
      global CopyFTR := 1
else
  global CopyFTR :=
    MsgBox, 4,, Would you also like to DL the Condor.Club generated IGC files?
    IfMsgBox Yes
      global DL_IGC := 1
else
  global DL_IGC :=
    if (SaveToSubfolder = "No")
      FileDelete,%IGCandFTRFolder%\SCITemp\*.igc

    Loop,parse,Clipboard1,¢
    {
      Global Result
      RegExMatch(A_LoopField,"^\d{4,7}",Result)
      if (Result > 1000) and (Result < 10000000)
      {
        msg = Downloading %Result%.ftr
        rank :=
        if(count2 > 0)
          rank := "&rank=1&next=1"
        ; WinGetActiveTitle, OutputVar
        download_url := "https://www.condor.club/download2/0/?res=" . Result . Rank
        runwait, %download_url%,,HIDE
        dlcount++
        WinWait,Save As,,1,
        if (errorlevel = 0)
        {
          if (dlcount = 1)
          {
            winactivate,Save As
            sleep 50
            ControlGetText, dlfile , Edit1, Save As
            sleep 50
            ControlSetText , Edit1, %DownloadFolder%, Save As
            sleep 50
            ControlSend,Edit1,{enter}
            sleep 50
            ControlSetText , Edit1, %dlfile%, Save As
            msg = You must save the file this folder (%DownloadFolder%).
          }
          else
          {
            winactivate,Save As
            sleep 50
            ControlSend,Edit1,{enter}
          }
          WinWaitClose,Save As
        }
        ; WinActivate, %OutputVar%
        if DL_IGC
        {

          download_url := "https://www.condor.club/download2/0/?res=" . Result . rank . "&format=2"
          msg = Downloading %download_url%
          sleep 200
          runwait, %download_url%,,HIDE
          WinWait,Save As,,1,
          if (errorlevel = 0)
          {
            if (dlcount = 1)
            {
              winactivate,Save As
              sleep 50
              ControlGetText, dlfile , Edit1, Save As
              sleep 50
              ControlSetText , Edit1, %DownloadFolder%, Save As
              sleep 50
              ControlSend,Edit1,{enter}
              sleep 50
              ControlSetText , Edit1, %dlfile%, Save As
              msg = You must save the file this folder (%DownloadFolder%).
            }
            else
            {
              winactivate,Save As
              sleep 50
              ControlSend,Edit1,{enter}
            }
            WinWaitClose,Save As
          }
        }

        if (longpause++ = 20)
        {
          random,sleeprandom,30000,120000
          longpause := 0
          if (longerpause = 80)
          {
            sleeprandom := 300000
            longerpause := 0
          }
        }
        else
          random,sleeprandom,% DownloadSleepMilliSeconds - 1000,% DownloadSleepMilliSeconds + 1000
        longerpause++
        sec := round(sleeprandom/1000)
        sleeprandom := sleeprandom/2
        msg = Taking a %sec% second pause on downloading (to avoid getting blocked by Condor.Club)
        sleep %sleeprandom%
        unzip()
        sleep %sleeprandom%
        time := A_Now
      }
    }

    MsgBox, 4,, Launch ShowCondorIGC and load tracks?
    IfMsgBox Yes
      LaunchSCI()
else
{
  if (SaveToSubfolder="Yes")
    run, explorer.exe "%IGCandFTRFolder%\%task%"
  else
    run, explorer.exe "%IGCandFTRFolder%"
}
    msg = CC FTR & IGC Downloader will exit in 10 seconds. Hit Ctrl+r to keep it running or ESC to exit now.
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
      if (ElapsedTime > 10000)
      {
        msgbox, It's been 10 seconds since attempting to download from Condor.Club`, and the zip file hasn't shown up yet in %DownloadFolder%. Here are some things to check:`n`nIf you get a "Task Not Found" message, please reload the Condor.Club results page (make sure you are logged in) and restart this tool.`n`nYou must save files to %DownloadFolder%. If a track has finished downloading`, but you get this message, please make sure that the folder that the ZIP files are being saved to is %DownloadFolder%., or press ctrl+i to change which folder this tool watches for downloads (and restart this tool afterwards).`n`nIf you have your browser set to ask where to save every file (not recommended)`, and you just need more time`, close this message to resume processing after saving the file.
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
          ; msgbox filename %A_LoopFileName%
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

        if DL_IGC
        {
          FileCreateDir,CC_IGC
          sleep 100
          local Files
          Files := ""
          Loop, Files, %DownloadFolder%\*.igc
          {
            if (A_LoopFileTimeCreated >= time)
            {   
             
              sleep 1000
              Filemove, %DownloadFolder%\%A_LoopFileName%,%A_WorkingDir%\CC_IGC\%A_LoopFileName%,1
            }
          }
        }

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
      MsgBox, 4,Condor.Club FTR & IGC Downloader,To download all available IGC and FTR files from a Condor.Club "race results" or "best performances" page, select all (Ctrl+A) and copy (Ctrl+C) for full results OR highlight race results rows with your mouse and Ctrl+c to download only those results.`n`nAfter downloading the temporary ZIP files from Condor.Club, IGC and FTR files will be extracted to a folder that you choose, and are optionally organized automatically into subfolders for each task. You will also be given the option to copy the FTR files to your Condor FlightTracks folder (for use as ghosts) and to load the IGC files in ShowCondorIGC for analysis.`n`nNote that this tool requires 7-Zip and the CoFliCo track converter (available at https://condorutill.fr/). If you are running this program for the first time, you will be taken through setup and file/folder selection steps. You can update your settings in the future by pressing ctrl+i.`n`nWould you like to display this message again the next time the program runs?

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
        DLdefault := GetDownloadPath()
        FileSelectFolder, Folder,*%DLdefault%,,Select folder that FTR zip files download to. IMPORTANT: Choose your browser's default download folder, unless your browser is set to ask where to save each file before downloading. Zip files will be deleted after downloading.
        if (errorlevel = 0)
          IniWrite %Folder%, CCDLconfig.ini,Settings, DownloadFolder
      }

      IniRead,IGCandFTRFolder,CCDLconfig.ini,Settings,IGCandFTRFolder,%A_space%
      if (IGCandFTRFolder="") or (config = 1)
      {
        FileSelectFolder, Folder2,,1,Select folder that IGC and FTR files will be extracted to and stored in.
        if (errorlevel = 0)
          IniWrite %Folder2%, CCDLconfig.ini,Settings, IGCandFTRFolder
      }

      IniRead,SaveToSubfolder,CCDLconfig.ini,Settings,SaveToSubfolder,%A_space%
      if (SaveToSubfolder="") or (config = 1)
      {
        MsgBox, 4,, Would you like FTR and IGC files to be organized into subfolders per each task? (Recommended)
        IfMsgBox Yes
          IniWrite Yes,CCDLconfig.ini, Settings, SaveToSubfolder
else
  IniWrite No,CCDLconfig.ini, Settings, SaveToSubfolder
      }

      IniRead,7zip,CCDLconfig.ini,Settings,7zip,%A_space%
      if (7zip="") or (config = 1)
      {
        FileSelectFile, 7zip,1,C:\Program Files\7-Zip\7z.exe,Find your 7zip 7z.exe file,*.exe
        IniWrite %7zip%, CCDLconfig.ini,Settings,7zip
      }

      IniRead,CoFliCo,CCDLconfig.ini,Settings,CoFliCo,%A_space%
      if (CoFliCo="") or (config = 1)
      {
        FileSelectFile, CoFliCo,1,%A_ScriptDir%\CoFliCo.exe,Find your CoFliCo.exe file,*.exe
        if (errorlevel = 0)
          IniWrite %CoFliCo%, CCDLconfig.ini,Settings, CoFliCo
      }

      IniRead,FlightTracksFolder,CCDLconfig.ini,Settings,FlightTracksFolder,%A_space%
      if (FlightTracksFolder="") or (config = 1)
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
      if (DownloadSleepMilliSeconds="") or (config = 1)
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
    while WinExist("SCI4C3")
    {
      WinActivate, ShowCondorIGC
      msgbox, Please close any previous instances of ShowCondorIGC and then hit OK to continue.
    }
    run, %SCIexe%
    tt = SCI4C3
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
      WinMenuSelectItem, SCI4C3,,Favorites
    WinWait, Favorites
    IfWinNotActive, Favorites,, WinActivate, Favorites
      ControlFocus,Load Folder (IGC),Favorites
    ControlSend, Load Folder (IGC),{enter},Favorites
    msg = Next select the type of task (and min time if AAT task). After you select and hit OK, please wait up to 10 seconds for tracks to load.
    WinWaitClose,Task
    WinWait,Open
    sleep 100
    ControlSetText,Edit1,%scifile%,Open
    sleep 100
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
    msg := ""
  return

  ttip:
    if (msg1=msg)
      ToolTip, %msg%
    else
    {
      ; SetTimer, RemoveTooltip, 10000
      msg1 := msg
    }
  return

  ESC::
  exitapp

  ^r::goto start
