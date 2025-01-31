# Load the bookmark file if the bookmark file exits else read from script if the script on the disk saved

import os.path
import subprocess
import sys

# user setting, you must set the path to AvsPthumb for 64 and/or 32 bit version
tool64 = 'D:\Tools GPo (x64)\AvsThumb\AvsPThumb.exe'
tool32 = 'D:\Tools GPo (x86)\AvsThumb\AvsPThumb.exe'

if sys.maxsize > 2**32:
    suffix = '.bk6'
    runFile = tool64
else:
    suffix = '.bk3'
    runFile =  tool32
if not os.path.isfile(runFile):
    avsp.MsgBox('%s\nnot found. You must set the file name in the macro' % runFile, _('Error'))
    return

filename =  os.path.splitext(avsp.GetScriptFilename(propose='general'))[0]
if not filename:
    avsp.MsgBox('You must save the script', _('Error'))
    return
if os.path.isfile(filename+suffix):
    filename += suffix
else:
    filename = avsp.GetScriptFilename(propose='general')

param = ' "'+ filename + '"'
param = param.encode(sys.getfilesystemencoding())
subprocess.Popen('"' + runFile + '"' + param, shell=True)
