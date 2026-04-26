use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set changeTool to missing value
set theToolbar to missing value
set commandClickToolButton to missing value

tell application "Keyboard Maestro Engine"
	set changeTool to getvariable "LogicProChangeTool"
end tell

tell application "System Events"
	tell its application process "Logic Pro"
		set allGroups to every group of its front window
		
		-- Check every group of Logic Pro's front window until we find one with the role description "toolbar" and the description "Tracks."
		-- That group is the toolbar of the Tracks area.
		repeat with theGroup in allGroups
			set subGroups to every group of theGroup
			
			repeat with sGroup in subGroups
				if role description of sGroup is "toolbar" and description of sGroup is equal to "Tracks" then
					-- We found the toolbar of the Tracks area. No need to check the other sub-groups.
					set theToolbar to sGroup
					exit repeat
				end if
			end repeat
			
			if theToolbar is not missing value then
				-- We found the toolbar of the Tracks area. No need to check the other groups.
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
			click commandClickToolButton
			set theMenu to menu 1 of commandClickToolButton
			click menu item changeTool of theMenu
		end if
		
	end tell
end tell