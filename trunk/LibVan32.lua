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


---Enable the calling addon's 'DebugMode' flag, allowing invisible debug messages to be printed.
--@usage YourAddon:EnableDebugMode()
function LibVan32:EnableDebugMode()
	if not self.DebugMode or self.DebugMode == false then
		self.DebugMode = true
	end
end

---Disable the calling addon's 'DebugMode' flag, causing invisible debug messages to no longer print.
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

---Used to parse color-coded strings in the same way that PrintMessage does.\\
-- Provides users with a way to easily color a dialog's strings in the same theme as the chat.
--@usage string = YourAddon:ParseColorCodedString("string")
--@param str The string that contains the color-codes.//(string)//
--@return A string with library color codes replaced with the client's color escape sequence. (|cFFFFFFFF, for example)
function LibVan32:ParseColorCodedString(str)
	if type(str) ~= 'string' then error("str must be a string, was " .. type(str) ..".") end
	return parseMessage(str)
end

--- Prints a color-coded message to the default chat frame. It supports the following escape sequences in strings:\\
-- $V will be replaced with |cFFff4b00 (<<color #ff4b00>>The text will be this color.<</color>>)\\
-- $T will be replaced with |cFFaf96ff (<<color #af96ff>>The text will be this color.<</color>>)\\
-- $E will be replaced with |cFFe60a0a (<<color #e60a0a>>The text will be this color.<</color>>)\\
-- $G will be replaced with |cFF0ae60a (<<color #0ae60a>>The text will be this color.<</color>>)\\
-- $C will be replaced with |r\\
-- The message output is: title: <Debug> [ERROR] message
-- @usage YourAddon:PrintMessage("message", [isError], [isDebug])
-- @param message The message to print to the chat.//(string)//
-- @param isError Whether or not to flag the message as an error.//(boolean)[optional]//
-- @param isDebug Whether or not to flag the message as debug.//(boolean)[optional]//
function LibVan32:PrintMessage(message, isError, isDebug)
	if type(message) ~= 'string' then error("bad argument #1 to \'PrintMessage\', (string expected, got " .. type(message) ..")") end
	
	local oM = "$T" .. self._AddonRegisteredName .. "$C: "
	
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

---Prints a message that can only be seen when the calling addon is in debug mode.\\
--This is the same as calling YourAddon:PrintMessage("message", isError, true)
--@usage YourAddon:PrintDebug("message", [isError])
--@param message The message to print to the chat frame.//(string)//
--@param isError Whether or not to flag the message as also being an error.//(boolean)[optional]//
function LibVan32:PrintDebug(message, isError)
	if type(message) ~= 'string' then error("bad argument #1 to \'PrintDebug\', (string expected, got " .. type(message) ..")") end
	
	self:PrintMessage(message, isError, true)
end

-- Timers Library
LibVan32.timers = {}

---Create a recurring or single-tick timer.\\
-- For example: calling a function after 5 seconds, or updating a list of objects every half-second
--@usage Timer = YourAddon:SetTimer(interval, callback, [recur, [uID]], [...])
--@param interval The delay, in seconds, that you want before excecuting //callback//.//(float)//
--@param callback The function to excecute when //interval// time has passed.//(function)//
--@param recur Whether or not the timer will repeat each //interval// seconds.//(boolean)//
--@param uID A Unique identifier assigned to a timer instance. You can use this, for instance, in a recursive function that iterates on a timer.//(anything)//\\Setting this field will deny creation of any new timers with the exact same uID. I reccomend using a string for this field, since it is global, however it will accept anything.
--@param ... A list of arguments to pass to //callback//.//(vararg)//
--@return The instance of the timer created, if successful, otherwise -1.
function LibVan32:SetTimer(interval, callback, recur, uID, ...)
	--Redundancy checks
	if type(interval) ~= 'number' then error("bad argument #1 to \'SetTimer\', (number expected, got " .. type(message) ..")") end
	if type(callback) ~= 'function' then error("bad argument #2 to \'SetTimer\', (function expected, got " .. type(message) ..")") end
	
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

---Stop an existing timer. This function requires a timer instance created with :SetTimer()
--@usage YourAddon:KillTimer(timer)
--@param timer The timer you wish to stop.//(SetTimer timer)//
--@return This function returns nil if the timer was sucessfully stopped, making it easier for you to clear the variable you stored the timer instance in originally.\\If it did not find a timer, it will return the variable you sent to it, so that it's not completely lost.
function LibVan32:KillTimer(timer)
	if type(timer) ~= 'table' then error("bad argument #1 to \'KillTimer\', (table expected, got " .. type(message) ..")") end
	if LibVan32.timers[timer] then
		LibVan32.timers[timer] = nil
		return nil
	else
		return timer
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
	"DisableDebugMode",
	"PrintDebug"
}



---Embed this library into an addon, and store it's 'short title' for addon output.\\
--The addonName is used in PrintMessage, showing which addon is accosting the user with information.
--@param target The table you want to embed the library into.//(table)//
--@param addonName The short title of your addon, used in PrintMessage calls.//(string)//
--@usage LibStub:GetLibrary("LibVan32-1.0"):Embed(YourAddon, "addonName")
function LibVan32:Embed(target, addonName)
	--Redundancy checks
	if type(target) ~= 'table' then error("bad argument #1 to \'Embed\', (table expected, got " .. type(message) ..")") end
	if type(addonName) ~= 'string' then error("bad argument #2 to \'Embed\', (string expected, got " .. type(message) ..")") end
	
	for _, name in pairs(mixins) do
		target[name] = LibVan32[name]
	end
	target._AddonRegisteredName = addonName
	LibVan32.mixinTargets[target] = true
end

for target, _ in pairs(LibVan32.mixinTargets) do
	LibVan32:Embed(target)
end