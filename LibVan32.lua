--[[
------------------------------------------------------------------------
	Project: LibVan32
	File: Core, revision 3
	Date: 11-Oct-2011
	Purpose: Library for common addon functions
	Credits: Code written by Vandesdelca32

	Copyright (C) 2011  Vandesdelca32

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
------------------------------------------------------------------------
]]

local MAJOR, MINOR = "LibVan32-1.0", tonumber('@project-revision@')

local LibVan32, OLDMINOR = LibStub:NewLibrary(MAJOR, MINOR)

if not LibVan32 then return end -- No upgrade needed


---Enables your addon's "DebugMode" flag, which will cause all messages sent
--to :PrintMessage() and isDebug is set, to show up in the chat frame.
--@usage YourAddon:EnableDebugMode()
function LibVan32:EnableDebugMode()
	if not self.DebugMode or self.DebugMode == false then
		self.DebugMode = true
	end
end

---Disables your addon's "DebugMode" flag, which will stop messages
--flagged as debug to stop printing
--@usage YourAddon:DisableDebugMode()
function LibVan32:DisableDebugMode()
	if not self.debugMode or self.DebugMode == true then
		self.DebugMode = false
	end
end

-- Parse the $X Color codes from the PrintMessage function
local function parseMessage(message)
	if not message then return end
	local cT = {
		["$V"] = "|cFFFF4B00",
		["$T"] = "|cFFAF96FF",
		["$E"] = "|cFFE60A0A",
		["$G"] = "|cFF0AE60A",
		["$C"] = "|r",
	}
	local str, newStr = message
	for k, v in pairs(cT) do
		newStr = string.gsub(str, k, v)
		str = newStr
	end
	return str
end

---Parses a color-coded message for use with localization tables. See :PrintMessage for a list of color codes.
--@usage local someString = YourAddon:ParseColorCodedString("string")
--@param str The string to parse.
--@return The string, with the color codes replaced with client escape sequences.
function LibVan32:ParseColorCodedString(str)
	return parseMessage(str)
end

--- Prints a color-coded message to the default chat frame. It supports the following escape sequences in strings:<br>
-- $V will be replaced with |cFFFF4B00<br>
-- $T will be replaced with |cFFAF96FF<br>
-- $E will be replaced with |cFFE6A0A0<br>
-- $G will be replaced with |cFF10FF10<br>
-- $C will be replaced with |r<br>
-- The message output is: title: <Debug> [ERROR] message
-- @usage YourAddon:PrintMessage("title", "message", true, true)
-- @param title The short title used by the addon for chat. (string)
-- @param message The message to print to the chat. (string)
-- @param isDebug True if the message is not to be printed while the addon is in debug mode, otherwise false. (boolean) (optional)
-- @param isError True if the message is an error message, and should have [ERROR] prefixed to it. (boolean) (optional)
function LibVan32:PrintMessage(title, message, isError, isDebug)
	
	-- Title cannot be empty
	if not title or title == "" then	
		error("Usage: PrintMessage(\"message\", [isError], [isDebug]); title cannot be empty.")
		return
	end
	
	-- Message cannot be empty:
	if not message or message == "" then
		error("Usage: PrintMessage(\"message\", [isError], [isDebug]); message cannot be empty.")
		return
	end
	
	local oM = "$T" .. title .. "$C: "
	
	-- Check and append debug header
	if isDebug then
		if self.DebugMode then
			oM = oM .. "<Debug> "
		else
			-- Do not print a message if debug mode is not enabled
			return
		end
	end
	
	-- Check and add [ERROR] header
	if isError then
		oM = oM .. "$E[ERROR]$C "
	end
	
	-- Append the actual message
	oM = oM .. message
	
	-- Parse the color codes
	print(parseMessage(oM))
end


-- Timers Library
LibVan32.timers = {}

--- Creates a timer that will call a function after a specific amount of time.
-- @usage local someTimer = YourAddon:SetTimer(30, doSomething, false, nil, arg1, arg2)
-- @param interval A time, in seconds, before iterating 'callback'. (number)
-- @param callback The code to excecute when the interval is passed. (function)
-- @param recur If true, this timer will continue running until stopped. (1nil)
-- @param uID A unique identifier for the timer. Used if you do not want more than one instance of any recurring timer (string/number)
-- @param ... A list of arguments to pass to the callback function
-- @return The table representing the timer created if successful, otherwise -1.
function LibVan32:SetTimer(interval, callback, recur, uID, ...)
	local timer = {
		interval = interval,
		callback = callback,
		recur = recur,
		uID = nil or (recur and uID),
		update = 0,
		...
	}
	
	if uID then
		-- Check the timers existing:
		for k, _ in pairs(LibVan32.timers) do
			if k.uID == uID then
				return -1
			end
		end
	end
	LibVan32.timers[timer] = timer
	return timer
end

--- Stops and removes an existing timer.
-- @usage local killed = YourAddon:KillTimer(someTimer)
-- @param timer The timer object created by 'SetTimer' you wish stopped. (Timer)
-- @return True if the timer was stopped, otherwise nil.
function LibVan32:KillTimer(timer)
	if LibVan32.timers[timer] then
		LibVan32.timers[timer] = nil
		return true
	else
		return
	end
end


-- How often to check timers. Lower values are more CPU intensive.
local granularity = 0.1

local totalElapsed = 0
local function OnUpdate(self, elapsed)
   totalElapsed = totalElapsed + elapsed
   if totalElapsed > granularity then
	  for k,t in pairs(LibVan32.timers) do
		 t.update = t.update + totalElapsed
		 if t.update > t.interval then
			local success, rv = pcall(t.callback, unpack(t))
			if not rv and t.recur then
			   t.update = 0
			else
			   LibVan32.timers[t] = nil
			   if not success then error("Timer Callback failed:" .. rv) end
			end
		 end
	  end
	  totalElapsed = 0
   end
end
CreateFrame("Frame"):SetScript("OnUpdate", OnUpdate)

LibVan32.mixinTargets = LibVan32.mixinTargets or {}
local mixins = {
	"KillTimer",
	"SetTimer",
	"PrintMessage",
	"ParseColorCodedString",
	"EnableDebugMode",
	"DisableDebugMode"
}

--- Embeds the library in the specified addon
--@param target The table you want to embed the library into
--@usage LibStub:GetLibrary("LibVan32-1.0"):Embed(YourAddon)
function LibVan32:Embed(target)
	for _, name in pairs(mixins) do
		target[name] = LibVan32[name]
	end
	LibVan32.mixinTargets[target] = true
end

for target, _ in pairs(LibVan32.mixinTargets) do
	LibVan32:Embed(target)
end