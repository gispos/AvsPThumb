import os.path
import subprocess
import sys

if sys.maxsize > 2**32:
    suffix = '.bk6'
    runFile = '"D:\Tools GPo (x64)\AvsThumb\AvsPThumb.exe" '
else:
    suffix = '.bk3'
    runFile = '"D:\Tools GPo (x86)\AvsThumb\AvsPThumb.exe" '

filename = avsp.GetSelectedText(index=None)
if not filename:
    filename = os.path.splitext(avsp.GetScriptFilename(propose='general'))[0]
    if not filename:
        return
    if os.path.isfile(filename+suffix):
             filename += suffix
    else:
        filename = avsp.GetScriptFilename(propose='general')

param = '"'+ filename + '"'
param = param.encode(sys.getfilesystemencoding())
subprocess.Popen(runFile + param, shell=True)
