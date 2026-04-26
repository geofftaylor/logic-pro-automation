use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set toolbarDescription to "Tracks" -- The description of the toolbar that contains the Command-Click tool button (e.g., "Tracks" or "Piano Roll").
set theTool to missing value
set theToolbar to missing value
set toolbarGroups to missing value
set commandClickToolButton to missing value

-- Get the tool requested by the user.
set kmInst to system attribute "KMINSTANCE"
tell application "Keyboard Maestro Engine"
	set theTool to getvariable "Local__CommandClickTool" instance kmInst
end tell

tell application "System Events"
	tell its application process "Logic Pro"
		set allGroups to every group of its front window
		
		-- Check every group of Logic Pro's front window until we find one with the role description "toolbar" and the description `toolbarDescription`.
		-- That group is the toolbar that contains the Command-Click tool button.
		repeat with theGroup in allGroups
			set subGroups to every group of theGroup
			
			repeat with sGroup in subGroups
				if role description of sGroup is equal to "toolbar" and description of sGroup is equal to toolbarDescription then
					-- We found the toolbar of the area. No need to check the other sub-groups.
					set theToolbar to sGroup
					exit repeat
				end if
			end repeat
			
			if theToolbar is not missing value then
				-- We found the toolbar. No need to check the other groups.
				exit repeat
			end if
		end repeat
		
		if theToolbar is not missing value then
			set toolbarContents to entire contents of theToolbar
			
			repeat with theItem in toolbarContents
				-- Check every item until we find one that has a role description of "menu button" and a description that starts with "Command-Click Tool."
				if role description of theItem is "menu button" and description of theItem starts with "Command-Click Tool" then
					-- We found the Command-Click Tool button. No need to check other items.
					set commandClickToolButton to theItem
					exit repeat
				end if
			end repeat
		end if
		
		if commandClickToolButton is not missing value then
			click commandClickToolButton -- Click the button.
			set theMenu to menu 1 of commandClickToolButton
			click menu item theTool of theMenu -- Click the requested tool.
		end if
		
	end tell
end tell