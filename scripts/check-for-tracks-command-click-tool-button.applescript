(*
	If the Logic Pro window is too small, the Command-Click Tool button may not be visible.
	This script verifies that it's visible on the screen.
	If it's not visible, the script displays an alert.
	Sends true or false to Keyboard Maestro by setting the value of a Keyboard Maestro variable.
*)

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set tracksToolbar to missing value -- The Tracks area toolbar.
set commandClickToolButtonFound to false -- Variable that will be passed back to Keyboard Maestro.

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
					set tracksToolbar to sGroup
					exit repeat
				end if
			end repeat
			
			if tracksToolbar is not missing value then
				-- We found the toolbar of the Tracks area. No need to check the other groups.
				exit repeat
			end if
		end repeat
		
		if tracksToolbar is not missing value then
			set toolbarContents to entire contents of tracksToolbar
			
			repeat with theItem in toolbarContents
				-- Check every item until we find one that has a role description of "menu button" and a description that starts with "Command-Click Tool."
				if role description of theItem is "menu button" and description of theItem starts with "Command-Click Tool" then
					-- We found the Command-Click Tool button. No need to check other items.
					set commandClickToolButtonFound to true
					exit repeat
				end if
			end repeat
		end if
		
		if commandClickToolButtonFound is false then
			display alert "The Command-Click Tool button is not visible. Please make the Logic Pro window larger." buttons {"OK"} as critical
		end if
		
	end tell
end tell

set kmInst to system attribute "KMINSTANCE"
tell application "Keyboard Maestro Engine"
	setvariable "Local__CommandClickToolButtonFound" to commandClickToolButtonFound instance kmInst
end