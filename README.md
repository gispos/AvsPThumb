# AvsPThumb 2.0.8
AvsPmod bookmark reader

- Reads bookmarks saved with AvsPmod in avs script. Also reads a bookmarks list (cr.txt).  
- You can save the read as a stream, to open quickly with AvsPThumb.  
- Can send commands to AvsPmod.  
- Can create single clip (one script) from all clips (tabs) with new calculated bookmarks. Save avisynth memory usage.  
- Does not make entries in the registry or file system. If not liked, just delete.  

How to do
---------------
Navigate AvsPmod to another bookmark: Just click on the thumbnail.  

The AvsPmod display can be moved on the thumbnail: Press left mouse button and move the mouse.  

AvsPmod one frame ahead or back: Press left mouse button and use the mouse wheel.  

Copy thumbnail to favorites: Hold down the left and right mouse buttons and perform a drag and drop movement  

Copy Thumbnail to Basket: Press CTRL and hold down left and right mouse button and perform a drag and drop movement  

Go to the AvsPmod Current Bookmark: Press the middle mouse button  

Remove from Favorites or Basket: Just do a drag and drop operation (In 'Basket' CTRL must be pressed)  

Information
----------------
If the file has already been saved with 'Save to Stream' and the favorites have been changed, the changes can be saved with 'Save Favorites'.  

If the bookmarks have changed in the avs file, an update can be made with 'Update Bookmarks'. Only the not yet existing bookmarks are read.
And when saving again, the quality of the other thumbnails is not changed. And the existing favorites are retained. 
The existing favorites are retained even if the bookmarks are read again with 'ReOpen Size'. 

Finds the AvsPmod window even if the avs is present in an AvsPmod tab. So you can find single AvsPmod Instances or one Instance with multiple tabs.  

Constraints
----------------
In AvsPmod you have to disable 'Video preview always on top' (Options menu).
In AvsPmod 'On first script load bookmarks from script' and 'Tabs changing load bookmarks from script' must be enabled.  

AvsPThumb needs write permission in the own directory.  

When a saved stream is opened, AvsPThumb finds the AvsPmod window only:
The stream (.bk3, .bk6) filename must be the same as the avs file. 'Stars.mkv.avs' = 'Stars.mkv.bk6'

Please also use to save the avs files and the bk6 files always the name of the source incl. Extension.
AvsPThumb will automatically suggest the file name in the save dialog.

Save multiple streams, so you can have different thumbnail sizes from the same avs file:
Permitted addition for e.g. 'Stars.mkv.avs' is an underscore with a number: Stars.mkv_2.bk6, Stars.mkv_3.bk6 and so on.
AvsPThumb will then search for 'Stars.mkv.avs'.  

After finding the AvsPmod window or sending a command, AvsPThumb waits a maximum of 31 seconds for a response from AvsPmod. AvsPThumb can not be closed during this time. There will be an hint when closing.  

Clips to clip
---------------
This function can be found under Extras. The function creates a single clip (script) from all tabs.
Advantages is the minimized memory requirement of Avisynth. 

Prerequisite:  
1.) Each tab must be an opened (bk6, bk3) file and the avs file must be in the same directory.  
2.) The video and audio parameters of the clips must match.  

What is being done:  
All bookmark positions of the individual clips are corrected and a bk6 file with the corrected values is created.
An avs file with all clips as functions is created and the new calculated bookmarks is written to the 2th line in the avs file.
Some parameters for each clip are deactivated in the new avs file:
Prefetch, SetMemoryMax and MCTemporalDenoise 'GPU=True' is changed to 'GPU=False'.

Limitation:  
AvsPmod can store a maximum of 1000 bookmarks in the menu. 
If this is exceeded, a message is displayed and no further clips are added. 

Bug:  
The AvsPmod editor shows no text that is longer than ~ 1000 characters. 
So it may be that the line with the new bookmarks is not displayed. The remedy is to activate the line break.  
 
Note:  
The function is not intended to open 10 or more 1.5 hour films!
Tested with 18 Full HD clips each 100 to 600 MB. With some filters for each clip Avisynth memory usage ~ 5000 MB  

Split Clip
-------------
You can split a clip into several tabs. Useful for 'Clips to clip' or a scene division.  
To much? You can hide the menu under 'Options'->'Hide Clip menu' ;)  
With 'Auto Split' you can expand the saved splits ('Save current splits') to several tabs  
If the clip has been split, the following functions are deactivated: 
Save Favorites, Update Bookmarks, SaveToStream and ReOpen Size.  

You can either merge whole part in the menu or merge the selection to another part using drag and drop.  
Drag and drop:  
Press left and right mouse button, press keyboard 'ALT'.  
Then drag and drop to the left or right. If you move to the left, the selected index and all above are moved to the previous part.
With a right movement the selected and all below if moved to the next part.  

Saving the split points is only possible in bookstreams that were saved with the new version 2.0.4.  
So open your bookstreams and save them again, overwrite the old file.  

Commands
-------------
Command menu entries can be created in AvsPThumb. They are displayed in the pop-up menu.  

Use commands:  
Commands can be entered in the text file 'AvsPCommand.txt'. Commands are AvsPmod menu entries.  

Copy image to clipboard=2  
Fire up|Toggle extended left move=2|MinScriptLines=4,2,0  

1.) Search for 'Copy image to clipboard' in the 3rd menu  
2.) Text for the own menu 'Fire up' | Search for 'Toggle extended left move' in the 3rd menu | Select 5.Menu, select in it 3. Menu, select in it 1. Menu and search for 'MinScriptLines'  

Note: Entries always start at 0, so the 1st menu is 0  
'Copy image to clipboard' can be found in AvsPmod under Menu 2 ! And not 3  

So '|' is a separator for multiple commands  
For multiple commands, the name for the menu must appear in the beginning (The Name | then the functions)  

And '-' without quotes is a separator in the AvsPThumb menu  

Commands can be deactivated with '#'  
#Copy image to clipboard=2 



