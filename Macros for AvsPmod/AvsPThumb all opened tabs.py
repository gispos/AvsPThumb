# Open all initialiced tabs (read from bookmark file or read from saved script)

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
    
self = avsp.GetWindow()
param = ''
for index in xrange(self.scriptNotebook.GetPageCount()):
    script = self.scriptNotebook.GetPage(index)
    if not script.AVI:
        continue
    filename = os.path.splitext(script.filename)[0] + suffix
    if os.path.isfile(filename):
        param += '"'+ filename +'" '      
    elif script.filename and os.path.isfile(script.filename):
        if self.OnMenuBookmarksFromScript(script=script, getOnlyCount=True) > 0:
            param += '"'+ script.filename +'"' + ' '    

param = param.strip()
if not param:
    return

param = param.encode(sys.getfilesystemencoding())
subprocess.Popen('"'+ runFile + '" ' + param, shell=True)