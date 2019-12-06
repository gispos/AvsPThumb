import os.path
import subprocess
import sys

self = avsp.GetWindow()
param = ''

if sys.maxsize > 2**32:
    suffix = '.bk6'
    runFile = '"D:\Tools GPo (x64)\AvsThumb\AvsPThumb.exe" '
else:
    suffix = '.bk3'
    runFile = '"D:\Tools GPo (x86)\AvsThumb\AvsPThumb.exe" '

for index in xrange(self.scriptNotebook.GetPageCount()):
    script = self.scriptNotebook.GetPage(index)
    filename = os.path.splitext(script.filename)[0] + suffix
    if os.path.isfile(filename):
        param += '"'+ filename +'"' + ' '
    #elif script.filename and os.path.isfile(script.filename):
        #param += '"'+ script.filename +'"' + ' ' 
       
if not param:
    return

param = param.encode(sys.getfilesystemencoding())
subprocess.Popen(runFile + param, shell=True)
