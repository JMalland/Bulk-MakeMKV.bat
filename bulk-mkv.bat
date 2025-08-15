@ECHO OFF
setlocal enabledelayedexpansion
: makemkvcon -r info iso:"Z:\ISOs\ATTACK_OF_THE_CLONES_disc1.iso"

: Set the configuration file
set ConfigFile=%~dp0\config-bulk-mkv.bat
: Set the Input variable to an empty string
set Input=""

: Run the configuration file
call "%ConfigFile%"

:Main

: Add extra checks for previous executions (Detect, Scan, Convert) to log found results

: Display the Main Menu
cls
echo/
echo %Input%
echo %TempFolder%
echo Welcome to the Bulk MKV converter for MakeMKV!
echo/
echo Please configure the folder paths for processing.
echo NOTES:
echo    MKV files will be stored in folders per each ISO. i.e. C:\...\Output\ISO_Filename\*
echo    Detected ISO files will be recorded to a text file: %DetectFile%
echo    Scanned ISO data will be recorded to a text file: %ScanFile%
echo/
echo/
echo 1) Configuration
echo 2) Detect ISOs
echo 3) Convert ISOs
echo 4) Exit
echo/

: Prompt user for option selection
set /P "MInput=Select an option [1,2,3,4]: "

: Go to the configuration menu
if "%MInput%" == "1" goto Configure 
: Process the ISO files
if "%MInput%" == "2" goto Detect
if "%MInput%" == "3" goto Process
: Exit the program, and save the configuration file
if "%MInput%" == "4" goto ExitBatch

: User selection was not within the available options
goto Main

:Configure

: Check whether ISO folder was configured
if "%CInput%" == "1" set "ISOFolder=%TempFolder%"
: Check whether Output folder was configured
if "%CInput%" == "2" set "OutputFolder=%TempFolder%"
: Check whether Completed folder was configured
if "%CInput%" == "3" set "CompletedFolder=%TempFolder%"

cls
echo/
echo Welcome to the configuration menu!
echo/
echo Here you can configure the input/output folders for using MakeMKV.
echo/
echo/
echo 1) ISO folder: %ISOFolder%
echo 2) Output folder: %OutputFolder%
echo 3) Completed folder: %CompletedFolder%
echo 4) Back to Main Menu

set /P "CInput=Select an option [1,2,3,4]: "

: Configure folder options (then return to configuration menu)
if "%CInput%" == "1" call :FolderPrompt "ISO storage"
if "%CInput%" == "2" call :FolderPrompt "MKV Output"
if "%CInput%" == "3" call :FolderPrompt "Completed ISOs"
: Exit to Main Menu
if "%CInput%" == "4" goto Main

: Repeat the configuration menu until a valid option is selected
goto Configure

: FolderPrompt function taken from https://stackoverflow.com/questions/41645811/how-to-ask-user-of-batch-file-for-a-folder-name-path
:FolderPrompt
cls
echo/
echo Please type the %1 folder path and press ENTER.
echo/
echo Or alternatively drag ^& drop the folder from Windows
echo Explorer on this console window and press ENTER.
echo/

: Set TempFolder as empty string
set TempFolder=""
: Prompt for a file path to be entered
set /P "TempFolder=Path: "
: Remove double quotes from TempFolder value
set "TempFolder=%TempFolder:"=%"
: Check against empty string
if "%TempFolder%" == "" goto FolderPrompt
: Substitute '/' with '\' for Windows path structure
set "TempFolder=%TempFolder:/=\%"
: Ensure last character is not '\'
if "%TempFolder:~-1%" == "\" set "TempFolder=%TempFolder:~0,-1%"
: Check against empty string
if "%TempFolder%" == "" goto FolderPrompt
echo/

: Check that the Folder exists
if not exist "%TempFolder%\" (
    echo There is no folder "%TempFolder%\".
    echo/
    choice /C YN /M "Do you want to enter the path once again "
    if errorlevel 2 goto Configure
    goto FolderPrompt
)
: Return to the configuration menu
goto Configure

: Compile list of all ISOs
:Detect

: Clear the screen
cls

: Delete the DetectFile if it exists
if exist "%DetectFile%" (
    echo/
    echo Deleting %DetectFile%
    del %DetectFile%
    echo Deleted file.
)

: Create the DetectFile if it doesn't exist
if not exist "%DetectFile%" (
    echo\
    echo Creating %DetectFile%...
    type nul > "%DetectFile%"
    echo Successfully created file.
    echo\
)

: Go through each ISO file in the ISO storage folder
for /r %ISOFolder% %%f in (*.iso) do (
    echo %%~nxf >> %DetectFile%
)

: Count the number of lines in %DetectFile%
for /f "tokens=*" %%f in ('"find /v "" /c < %DetectFile%"') do (
    set FoundISOs=%%f
)

echo Found %FoundISOs% ISO files.

pause

goto Main

: Convert all ISOs into MKV Files
:Process
: Count the number of lines in the DetectFile
set /a lines=0
for /F "usebackq tokens=* delims=" %%a in (%DetectFile%) do (
    echo LINE
    set /a lines+=1
    set "ISOFilename[!lines!]=%%a"     
)

: Go through each line in the DetectFile
for /L %%i in (1,1,%lines%) do (
    if not "!ISOFilename[%%i]!" == "" (
        : Call the MakeMKV action
        call :MakeMKV "!ISOFilename[%%i]!"     
    )
)

pause

goto Main

:MakeMKV
: Reset conversion skip
set TempSkip="false"

: Store the ISO name
set "TempISO=%~n1"

echo\
echo Handling file: %TempISO%.iso
echo\

    : Verify any existing files
if exist "%OutputFolder%\%TempISO%\*" (
    : Prompt user to overwrite existing conversion
    choice /C YN /M "Overwrite existing %TempISO% conversion? "

    : Configure the conversion to be skipped
    if errorlevel == 2 (
        set TempSkip="true"
    )
)

: Create the MKV output directory if it doesn't exist
if not exist "%OutputFolder%\%TempISO%" (
    mkdir %OutputFolder%\%TempISO%
    echo Created output folder: '%OutputFolder%\%TempISO%'
)

: This file should be converted
if "%TempSkip" == "false" (
    echo Converting %TempISO% to MKV files (stored in '%OutputFolder%\%TempISO%')
    echo makemkvcon --minlength=120 --messages=-stderr --noscan mkv iso:"%ISOFolder%\%TempISO%.iso" all "%OutputFolder%\%TempISO%"
    call makemkvcon --minlength=120 --messages=-stderr --noscan mkv iso:"%ISOFolder%\%TempISO%.iso" all "%OutputFolder%\%TempISO%"
    echo Finished converting file.

    if not "%errorlevel%" == "0" (
        : MakeMKV exited with an error
        echo Something went wrong processing %TempISO%.
        pause
    ) 
    
    if "%errorlevel%" == "0" (
        : Everything went okay, now move the ISO to the CompletedFolder
        echo Moving %TempISO% to %CompletedFolder%
        move "%ISOFolder%\%TempISO%.iso" "%CompletedFolder%\%TempISO%.iso"
        echo Finished moving file.
    )
)

: Break from the MakeMKV call
exit /b

:ExitBatch

: Re-Write configuration file
(
    echo set ISOFolder=%ISOFolder%
    echo set OutputFolder=%OutputFolder%
    echo set CompletedFolder=%CompletedFolder%
    echo\
    echo set DetectFile="%%~dp0detected_isos.txt"
    echo set ScanFile="%%~dp0scanned_isos.txt"
) > "%ConfigFile%"

endlocal