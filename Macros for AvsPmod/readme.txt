With these macros AvsPThumb can be started from AvsPmod.
Copy the macros to the AvsPmod macros directory or a subdirectory and adjust the path to AvsPThumb in the macro, see below.
Do not change the quotes

if sys.maxsize > 2**32:
    suffix = '.bk6'
    runFile = '"D:\Tools GPo (x64)\AvsThumb\AvsPThumb.exe" '
else:
    suffix = '.bk3'
    runFile = '"D:\Tools GPo (x86)\AvsThumb\AvsPThumb.exe" '