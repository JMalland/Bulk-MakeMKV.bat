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
: Check whether ISO folder was configured
if "%Input%" == "1" set "ISOFolder=%TempFolder%"
: Check whether Output folder was configured
if "%Input%" == "2" set "OutputFolder=%TempFolder%"
: Check whether Completed folder was configured
if "%Input%" == "3" set "CompletedFolder=%TempFolder%"

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
echo 1) ISO folder: %ISOFolder%
echo 2) Output folder: %OutputFolder%
echo 3) Completed folder %CompletedFolder%
echo 4) Detect ISOs
echo 5) Scan ISOs
echo 6) Convert ISOs
echo/

: Prompt user for option selection
set /P "Input=Select an option [1,2,3,4,5,6]: "

: Configure folder options (then return to main menu)
if "%Input%" == "1" (
    set TempDescription="ISO storage"
    goto FolderPrompt
)
if "%Input%" == "2" (
    set TempDescription="MKV Output"
    goto FolderPrompt
)
if "%Input%" == "3" (
    set TempDescription="Completed ISOs"
    goto FolderPrompt
)
: Begin processing the files
if "%Input%" == "4" goto Detect
if "%Input%" == "5" goto Scan
if "%Input%" == "6" goto MakeMKV

: User selection was not within the available options
goto Main

: FolderPrompt function taken from https://stackoverflow.com/questions/41645811/how-to-ask-user-of-batch-file-for-a-folder-name-path
:FolderPrompt
cls
echo/
echo Please type the %TempDescription% folder path and press ENTER.
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
    if errorlevel 2 goto Main
    goto FolderPrompt
)
: Return to the main menu, for configuration & execution
goto Main

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
    echo %%f >> %DetectFile%
)

: Count the number of lines in %DetectFile%
for /f "tokens=*" %%f in ('"find /v "" /c < %DetectFile%"') do (
    set FoundISOs=%%f
)

echo Found %FoundISOs% ISO files.

pause

goto Main

: Scan all ISOs for their titles and such
:Scan

: Create the ScanFile if it doesn't exist
if not exist "%ScanFile%" (
    echo\
    echo Creating %ScanFile%...
    type nul > "%ScanFile%"
    echo Successfully created %ScanFile%
    echo\
)

goto Main

: Convert all ISOs into MKV Files
:MakeMKV

goto ExitBatch

:ExitBatch

: Re-Write configuration file
(
    echo set ISOFolder=%ISOFolder%
    echo set OutputFolder=%OutputFolder%
    echo set CompletedFolder=%CompletedFolder%
    echo\
    echo set DetectFile="%%~dp0/detected_isos.txt"
    echo set ScanFile="%%~dp0/scanned_isos.txt"
) > "%ConfigFile%"

endlocal