: makemkvcon -r info iso:"Z:\ISOs\ATTACK_OF_THE_CLONES_disc1.iso"

: Set the Input variable to an empty string
set Input=""

: Declare the folders
set ISOFolder=""
set OutputFolder=""
set "CompletedFolder=""

:Main

: Check whether ISO folder was configured
if "!Input!" == "1" set "ISOFolder=!TempFolder!"
: Check whether Output folder was configured
else if "!Input!" == "2" set "OutputFolder=!TempFolder!"
: Check whether Completed folder was configured
else if "!Input!" == "3" set "CompletedFolder=!TempFolder!"

: Display the Main Menu
cls
echo/
echo Welcome to the Bulk MKV converter for MakeMKV!
echo/
echo Please configure the folder paths for processing.
echo NOTE: MKV files will be stored in folders per each ISO. i.e. C:\...\Output\ISO_Filename\*
echo/

echo/
echo "1) ISO folder: \"!ISOFolder!\""
echo "2) Output folder: \"!OutputFolder!\""
echo "3) Completed folder \"!CompletedFolder!\""
echo "4) Run Program"
echo/

: Prompt user for option selection
set /P "Input=Select an option [1,2,3,4]: "

: Configure folder options (then return to main menu)
if "!Input!" == "1" (
    set TempDescription="ISO storage"
    goto FolderPrompt
)
else if "!Input!" == "2" (
    set TempDescription="MKV Output"
    goto FolderPrompt
)
else if "!Input!" == "3" (
    set TempDescription="Completed ISOs"
    goto FolderPrompt
)
else if "!Input!" == "4" (
    goto Execute
)
: User selection was not within the available options
else goto Main

: FolderPrompt function taken from https://stackoverflow.com/questions/41645811/how-to-ask-user-of-batch-file-for-a-folder-name-path
:FolderPrompt
cls
echo/
echo "Please type the !TempDescription! folder path and press ENTER."
echo/
echo Or alternatively drag ^& drop the folder from Windows
echo Explorer on this console window and press ENTER.
echo/

: Set TempFolder as empty string
set TempFolder=""
: Prompt for a file path to be entered
set /P "TempFolder=Path: "
: Remove double quotes from TempFolder value
set "TempFolder=!TempFolder:"=!"
: Check against empty string
if "!TempFolder!" == "" goto FolderPrompt
: Substitute '/' with '\' for Windows path structure
set "TempFolder=!TempFolder:/=\!"
: Ensure last character is not '\'
if "!TempFolder:~-1!" == "\" set "TempFolder=!TempFolder:~0,-1!"
: Check against empty string
if "!TempFolder!" == "" goto FolderPrompt
echo/

: Check that the Folder exists (not empty)
if not exist "!TempFolder!\*" (
    echo There is no folder "!TempFolder!\".
    echo/
    choice /C YN /M "Do you want to enter the path once again "
    if errorlevel 2 goto ExitBatch
    goto FolderPrompt
)
: Return to the main menu, for configuration & execution
goto Main

: Compile list of all ISOs
:Detect

goto Main

: Scan all ISOs for their titles and such
:Scan

goto Main

: Convert all ISOs into MKV Files
:MakeMKV

goto ExitBatch




:ExitBatch
endlocal