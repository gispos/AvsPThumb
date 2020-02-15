With these macros (except Fire up) AvsPThumb can be started from AvsPmod.
Copy the macros to the AvsPmod macros directory or a subdirectory and adjust the path to AvsPThumb in the macro, see below.
Do not change the quotes !

if sys.maxsize > 2**32:
    suffix = '.bk6'
    runFile = '"D:\Tools GPo (x64)\AvsThumb\AvsPThumb.exe" '
else:
    suffix = '.bk3'
    runFile = '"D:\Tools GPo (x86)\AvsThumb\AvsPThumb.exe" '

Note:
AvsPThumb.py  does send the current tab.
AvsPThumb all tabs.py doese send all tabs.
AvsPThumb bm tabs.py does send only tabs if bookstream file (bk3, bk6) has found.
--------------------------------------------------------------------------------------------

Fire up.py
If you run this macro AvsPmod does set:

1.) Video window to maximum size
2.) Enables 'Extended left move'
3.) Enables 'Save view pos on tab change' 

Copy Fire up.py to AvsPmod macros folder or a subdir eg. 'macros\Extra\Fire up.py'
Whe assume the folder 'Extra' is the 3th menu in the macro menu
Write this lines to AvsPCommand.txt:
Fire up=4,2

You can now run this macro in the AvsPThumb popup menu 'Command'

