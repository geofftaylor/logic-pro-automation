(*
	The script first checks if the Piano Roll is open.
	If the Piano Roll is not open, the script displays an alert.
	If the Piano Roll is open, the script verifies that its Command-Click button is visible on the screen. (If the Logic Pro window is too small, the Command-Click Tool button may not be visible.) 
	If the button is not visible, the script displays an alert.
	The script sets two Keyboard Maestro variables:
	- Local__PianoRollOpen: Piano Roll is open (true or false).
	- Local__CommandClickToolButtonFound: Piano Roll's Command-Click button was found (true or false).
	
*)

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set focusedEditorButton to missing value -- The name of the focused button in the Editor.
set editorGroupIndex to 0 -- The index of the UI group that contains the Editor.
set pianoRollOpen to false
set pianoRollToolbar to missing value -- The Piano Roll toolbar.
set commandClickToolButtonFound to false -- Variable that will be passed back to Keyboard Maestro.

tell application "System Events"
	tell its application process "Logic Pro"
		set allGroups to every group of its front window
		
		repeat with groupIndex from 1 to (count of allGroups)
			set theGroup to item groupIndex of allGroups
			set radioGroups to every radio group of theGroup
			
			if length of radioGroups = 1 then
				-- If the Editor is open, there will be one top-level group that contains a radio group as its immediate child.
				-- If the Editor is not open, there will not be a top-level group that contains a radio group as its immediate child.
				
				-- We found the UI group that contains the Editor.
				set editorGroupIndex to groupIndex
				
				repeat with rGroup in radioGroups
					-- This loop will only run once because there's only one radio group.
					-- However, trying to drill into the radio buttons' attributes outside of a repeat loop doesn't seem to work.
					repeat with radioButton in (every radio button of rGroup)
						if value of radioButton is 1 then
							-- The radio button whose value is 1 is the focused button.
							set focusedEditorButton to description of radioButton
							
							-- We found the focused button. No need to check the other buttons.
							exit repeat
						end if
					end repeat
				end repeat
			end if
			
			if focusedEditorButton is not missing value then
				-- We found the focused button in this group. No need to check the other groups.
				exit repeat
			end if
			
		end repeat
	end tell
	
	if focusedEditorButton is equal to "Piano Roll" then
		set pianoRollOpen to true
	else
		display alert "The Piano Roll is not open." buttons {"OK"} as critical
	end if
	
	if pianoRollOpen is equal to true then
		-- Piano roll is open. Check for its Command-Click tool button.
		-- Check every group of Logic Pro's front window until we find one with the role description "toolbar" and the description "Piano Roll."
		-- That group is the toolbar of the Piano Roll area.
		repeat with theGroup in allGroups
			set subGroups to every group of theGroup
			
			repeat with sGroup in subGroups
				if role description of sGroup is "toolbar" and description of sGroup is equal to "Piano Roll" then
					-- We found the toolbar of the Piano Roll area. No need to check the other sub-groups.
					set pianoRollToolbar to sGroup
					exit repeat
				end if
			end repeat
			
			if pianoRollToolbar is not missing value then
				-- We found the toolbar of the Piano Roll area. No need to check the other groups.
				exit repeat
			end if
		end repeat
		
		if pianoRollToolbar is not missing value then
			set toolbarContents to entire contents of pianoRollToolbar
			
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
	end if
	
end tell

set kmInst to system attribute "KMINSTANCE"
tell application "Keyboard Maestro Engine"
	setvariable "Local__PianoRollOpen" to pianoRollOpen instance kmInst
	setvariable "Local__CommandClickToolButtonFound" to commandClickToolButtonFound instance kmInst
end tell