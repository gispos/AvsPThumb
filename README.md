# AvsPThumb v2.0.0
AvsPmod bookmark reader

- Reads bookmarks saved with AvsPmod in avs script. Also reads a bookmarks list (cr.txt).
- You can save the read as a stream, to open quickly with AvsPThumb.
- Can send commands to AvsPmod.

How to do
---------------
Navigate AvsPmod to another bookmark:
Just click on the thumbnail.

The AvsPmod display can be moved on the thumbnail:
Press left mouse button and move the mouse.

AvsPmod one frame ahead or back:
Press left mouse button and use the mouse wheel.

Copy thumbnail to favorites:
Hold down the left and right mouse buttons and perform a drag and drop movement

Copy Thumbnail to Basket:
Press CTRL and hold down left and right mouse button and perform a drag and drop movement

Go to the AvsPmod Current Bookmark:
Press the middle mouse button

Remove from Favorites or Basket:
Just do a drag and drop operation (In 'Basket' CTRL must be pressed)

Information
----------------
If the file has already been saved with 'Save to Stream' and the favorites have been changed, the changes can be saved with 'Save Favorites'.

If the bookmarks have changed in the avs file, an update can be made with 'Update Bookmarks'. Only the not yet existing bookmarks are read.
And when saving again, the quality of the other thumbnails is not changed. And the existing favorites are retained. 
The existing favorites are retained even if the bookmarks are read again with 'ReOpen Size'.

Finds the AvsPmod window even if the avs is present in an AvsPmod tab. So you can find single AvsPmod Instances or one Instanc with multiple tabs.

Constraints
----------------
In AvsPmod you have to disable 'Video preview always on top' (Options menu).

When a saved stream is opened, AvsPThumb finds the AvsPmod window only:
The stream (.bk3, .bk6) filename must be the same as the avs file. 'Stars.mkv.avs' = 'Stars.mkv.bk6'

Please also use to save the avs files and the bk6 files always the name of the source incl. Extension.
AvsPThumb will automatically suggest the file name in the save dialog.

Save multiple streams, so you can have different thumbnail sizes from the same avs file:
Permitted addition for e.g. 'Stars.mkv.avs' is an underscore with a number: Stars.mkv_2.bk6, Stars.mkv_3.bk6 and so on.
AvsPThumb will then search for 'Stars.mkv.avs'.

Commands
-------------
Command menu entries can be created in AvsPThumb. They are displayed in the pop-up menu.  

Use commands:  
Commands can be entered in the text file 'AvsPCommand.txt'. Commands are AvsPmod menu entries.  

Copy image to clipboard=2  
Fire up|Toggle extended left move=2|MinScriptLines=4,2,0  

1.) Search 'Copy image to clipboard' in the 3rd menu  
2.) Text for the own menu 'Fire up' | Search for 'Toggle extended left move' in the 3rd menu | Select 5.Menu, select in it 3. Menu, select in it 1. Menu and search for 'MinScriptLines'  
 
Note: Entries always start at 0, so the 1st menu is 0  
'Copy image to clipboard' can be found in AvsPmod under Menu 2 ! And not 3  
  
So '|' is a separator for multiple commands  
For multiple commands, the name must appear in the beginning of the menu (The Name | then the functions)  
 
And '-' without quotes is a separator in the AvsP Thumb menu  

Commands can be deactivated with '#'  
#Copy image to clipboard=2  

