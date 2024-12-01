use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- Change "Marquee Tool" to any other tool. See the README for a list of tool names.
set theTool to "Marquee Tool"
set theToolbar to missing value
set toolbarGroups to missing value
set commandClickToolButton to missing value

tell application "System Events"
	tell its application process "Logic Pro"
		set allGroups to every group of its front window
		
		repeat with theGroup in allGroups
			set subGroups to every group of theGroup
			
			repeat with sGroup in subGroups
				if role description of sGroup is equal to "toolbar" then
					set theToolbar to sGroup
					exit repeat
				end if
			end repeat
		end repeat
		
		if theToolbar is not missing value then
			set toolbarGroups to every group of theToolbar
			
			if toolbarGroups is not missing value then
				repeat with tGroup in toolbarGroups
					set theMenuButtons to menu buttons of tGroup
					
					if length of theMenuButtons is greater than 0 then
						repeat with theButton in theMenuButtons
							if description of theButton starts with "Command-Click Tool" then
								set commandClickToolButton to theButton
								exit repeat
							end if
						end repeat
					end if
					
					if commandClickToolButton is not missing value then
						exit repeat
					end if
				end repeat
			end if
		end if
		
		if commandClickToolButton is not missing value then
			click commandClickToolButton
			set theMenu to menu 1 of commandClickToolButton
			click menu item theTool of theMenu
		end if
		
	end tell
end tell