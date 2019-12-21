import wx

self = avsp.GetWindow()

# Min script lines
def SetSplitter():
    self.mainSplitter.SetSashPosition(1)
    self.currentScript.lastSplitVideoPos = self.mainSplitter.GetSashPosition() - \
          self.mainSplitter.GetClientSize()[self.mainSplitter.GetSplitMode() == wx.SPLIT_HORIZONTAL]
    self.ShowVideoFrame(focus=False)

if self.mainSplitter.GetSplitMode() == wx.SPLIT_HORIZONTAL:
    if self.currentScript.GetSize().height  >  4:
        self.mainSplitter.SetMinimumPaneSize(23)
        SetSplitter()
else:
    if self.currentScript.GetSize().width > 2:
        self.mainSplitter.SetMinimumPaneSize(0)  
        SetSplitter()  

# Extended left move
if not self.extended_move:
    avsp.ExecuteMenuCommand('Video -> Toggle extended left move')

# Save view position on tab change
if not self.saveViewPos:
    avsp.ExecuteMenuCommand('Video -> Save view pos on tab change')