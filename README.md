## Bulk-MakeMKV Converter (Windows Only)
  This program is my first-ever Batch program, so please excuse any improper programming conventions and bugs. 
  I built it to work to my needs, and so far it has done that.

  This was programmed and tested on Windows 11 and Windows 11 IOT Enterprise

## Installing
  When downloading the program, make sure `bulk-mkv.bat` and `config-bulk-mkv.bat` are in the same folder. 

## Executing
  Open `cmd.exe` or `powershell.exe`, open the Bulk-MakeMKV directory, and execute `bulk-mkv.bat`

  1)  Upon first running the `bulk-mkv.bat` program, select Option 1 and configure the ISO input folder, MKV output folder, and processed ISOs folder.

  2)  To scan all `.iso` files, select Option 2. The program will scan all `.iso` files in the input folder, saving their file paths to a text file used in the conversion process.
    
  3)  To convert the ISO files, select Option 3. After scanning the ISOs, you can convert them all into MKV files. During conversion, the MKV files will be stored in a subdirectory of the MKV output folder, named based on the ISO filename.

## Notes
  If MakeMKV encounters any errors during conversion, the program will pause to let you review the output. Providing further input resumes the program. 

  The program will also prompt you to overwrite any existing MKV conversions. Nothing will be overwritten unless the user gives consent. 
  
