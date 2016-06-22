--[[

	Project Name: LibVan32-2.0
	Author: Vandesdelca32

	File: LibVan32.lua
	Purpose: Common Library functions for Van32 Addons.

	Copyright © 2016 by Vandesdelca32
	All rights reserved. The contents of this file 	or any portion thereof
	may not be reproduced without the express written permission of the
	publisher.
]]

-- Initialization --
--------------------
local MAJOR, MINOR = "LibVan32-2.0", tonumber("@file-revision@")

-- This is for debug builds
--@do-not-package@
if not MINOR then MINOR = 9999 end
--@end-do-not-package@

local lib, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end -- No Upgrade Needed


-- Cached Lua APIs --
---------------------

-- GLOBALS: DEFAULT_CHAT_FRAME
local pairs, string, error, type = pairs, string, error, type
local bit = bit

-- Library Functions --
-----------------------

--- Color table
local colorTable = {
	-- Color codes kindly borrowed from Minecraft!
	["§0"]="|cFF000000",	-- Black
	["§1"]="|cFF0000A0",	-- Dark Blue
	["§2"]="|cFF00A000",	-- Dark Green
	["§3"]="|cFF00A0A0",	-- Dark Aqua
	["§4"]="|cFFA00000",	-- Dark Red
	["§5"]="|cFFA000A0",	-- Purple
	["§6"]="|cFFF0A000",	-- Gold
	["§7"]="|cFFA0A0A0",	-- Grey
	["§8"]="|cFF505050",	-- Dark Grey
	["§9"]="|cFF5050F0",	-- Indigo
	["§a"]="|cFF50F050",	-- Bright Green
	["§b"]="|cFF50F0F0",	-- Aqua
	["§c"]="|cFFF05050",	-- Red
	["§d"]="|cFFF050F0",	-- Pink
	["§e"]="|cFFF0F050",	-- Yellow
	["§f"]="|cFFF0F0F0",	-- White
	["§r"]="|r",			-- reset
	["§T"]="|cFFAF96FF",	-- Title, (ltpurple)
	["#c"]="|cFF", 		-- custom color
}

--- Parse the %x color-coded strings
local function parseString(string)
	local fStr = string
	for k,v in pairs(colorTable) do
		fStr = string.gsub(fStr, k, v)
	end
	return fStr
end


---Sets the default chat frame used to print messages.
--@usage YourAddon:SetDefaultChatFrame(chatFrame)
--@param chatFrame The frame you want to send messages to. It MUST have an .AddMessage entry
function lib:SetDefaultChatFrame( chatFrame )
	if chatFrame and ( not chatFrame.AddMessage ) then
		error("invalid chatFrame specified, must have :AddMessage method", 2)
	end

	self._dfc = chatFrame
end

---Used to parse color-coded strings.\\
-- Provides users with a way to easily color a dialog's strings in the same theme as the chat.
--@usage string = YourAddon:ParseColorCodedString("string")
--@param string The string that contains the color-codes.
--@return A string with library color codes replaced with the client's color escape sequence. (|cFFFFFFFF, for example)
function lib:ParseColoredString( string )
	if type( string ) ~= "string" then
		error( ("bad argument #1 to \'ParseColoredString\', (string expected, got %s)"):format(type(string)), 2 )
	end
	return parseString( string )
end

local function checkChatFrame( chatFrame )
	if chatFrame and (not chatFrame.AddMessage) then error("invalid chatFrame specified", 2) end
	return chatFrame
end


---MessageTypeEnum table, contains the options used in :Print
lib.MessageTypeEnum = {
	["STANDARD"] = 0,
	["ERROR"] = 1,
	["DEBUG"] = 2,
}

--- Prints a color-coded message to the default chat frame.\\
--Supports Minecraft style escape sequences (§x), where x corresponds to a single hex digit. See library code for color conversions.\\
--The message output is: title: <Debug> [ERROR] message
-- @usage YourAddon:Print("message", [messageType], [chatFrame])
-- @param message The message to print to the chat.
-- @param messageType The type of message that this will be flagged as. (optional)\\
--		@see MessageTypeEnum table for valid options
-- @param chatFrame The Frame to send the message through. This frame needs to have an AddMessage method. (optional)
-- @return Returns from the frame's called AddMessage function
function lib:Print( message, messageType, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	-- handle optional arguments
	messageType = messageType or self.MessageTypeEnum.STANDARD
	chatFrame = checkChatFrame(chatFrame or DEFAULT_CHAT_FRAME)

	-- start building our message:
	local fMessage = ("§T%s§r"):format( self.name )

	-- check message prefixes:
	if bit.band(messageType, self.MessageTypeEnum.DEBUG) ~= 0 then -- debug flag set
		if not self._DebugMode then return end
		fMessage = fMessage .. "§8<Debug>§r "
	end

	if bit.band(messageType. self.MessageTypeEnum.ERROR) ~= 0 then -- error flag set
		fMessage = fMessage .. "§c[ERROR]§r "
	end

	fMessage = fMessage .. message

	return chatFrame:AddMessage(parseString(fMessage))

end

---Prints a message that can only be seen when the calling addon is in debug mode.\\
--This is the same as calling YourAddon:PrintMessage("message", self.MESSAGETYPE.DEBUG)
--@usage YourAddon:PrintDebug("message", [isError], [chatFrame])
--@param message The message to print to the chat frame.
--@param isError Whether or not to flag the message as also being an error. (optional)
--@param chatFrame The Frame to send the message through. This frame needs to have an AddMessage method. (optional)
function lib:PrintDebug( message, isError, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	self:Print( message, self.MESSAGETYPE.DEBUG + (isError and self.MESSAGETYPE.ERROR or 0), chatFrame )
end

---Prints a message that is flagged as an error.\\
--This is the same as calling YourAddon:PrintMessage("message", self.MESSAGETYPE.ERROR)
--@usage YourAddon:PrintDebug("message", [isDebug], [chatFrame])
--@param message The message to print to the chat frame.
--@param isDebug Whether or not to flag the message as also being debug. (optional)
--@param chatFrame The Frame to send the message through. This frame needs to have an AddMessage method. (optional)
function lib:PrintError( message, isDebug, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	self:Print( message, self.MESSAGETYPE.ERROR + (isDebug and self.MESSAGETYPE.ERROR or 0), chatFrame )
end
-- Embedding --
---------------

--[=========[
--- Prints a color-coded message to the default chat frame.\\
--Supports Minecraft style escape sequences (§x), where x corresponds to a single hex digit. See library code for color conversions.\\
--The message output is: title: <Debug> [ERROR] message
-- @usage YourAddon:PrintMessage("message", [isError], [isDebug], [chatFrame])
-- @param message The message to print to the chat.//(string)//
-- @param isError Whether or not to flag the message as an error.//(boolean)[optional]//
-- @param isDebug Whether or not to flag the message as debug.//(boolean)[optional]//
-- @param chatFrame The Frame to send the message through. This frame needs to have an AddMessage method.//(Frame)[optional]//
function lib32:Print(message, isError, isDebug, chatFrame)
	if type(message) ~= 'string' then error("bad argument #1 to \'PrintMessage\', (string expected, got " .. type(message) ..")", 2) end

	if chatFrame and (not chatFrame.AddMessage) then error("invalid chatFrame specified", 2) end

	local oM = "§T" .. self.name .. "§r: "
	local oF = (chatFrame or self._DefaultChatFrame) or DEFAULT_CHAT_FRAME

	-- Check and append debug header
	if isDebug then
		if not self._DebugMode then return end
		oM = oM .. "§8<Debug>§r "
	end

	-- Check and add [ERROR] header
	if isError then
		oM = oM .. "§c[ERROR]§r "
	end

	-- Append the actual message
	oM = oM .. message

	-- Parse the color codes
	return oF:AddMessage(parseMessage(oM))
end

---Prints a message that can only be seen when the calling addon is in debug mode.\\
--This is the same as calling YourAddon:PrintMessage("message", isError, true)
--@usage YourAddon:PrintDebug("message", [isError], [chatFrame])
--@param message The message to print to the chat frame.//(string)//
--@param isError Whether or not to flag the message as also being an error.//(boolean)[optional]//
--@param chatFrame The Frame to send the message through. This frame needs to have an AddMessage method.//(Frame)[optional]//
function lib32:PrintDebug(message, isError, chatFrame)
	if type(message) ~= 'string' then error("bad argument #1 to \'PrintDebug\', (string expected, got " .. type(message) ..")", 2) end

	return self:PrintMessage(message, isError, true, chatFrame)
end

---Prints a message that will be flagged to the user as an error.\\
--This is the same as calling YourAddon:PrintMessage("message", true, isDebug)
--@usage YourAddon:PrintErr("message", [isDebug], [chatFrame])
--@param message The message to print to the chat frame.//(string)
--@param isDebug Also mark this message as a debug message.//(boolean)[optional]//\\(It's preferred that you call :PrintDebug("message", true) for this)
--@param chatFrame The Frame object to send the message to.//(Frame)[optional]//\\The frame requires the AddMessage method.
function lib32:PrintErr(message, isDebug, chatFrame)
	if type(message) ~= 'string' then error("bad argument #1 to \'PrintError\', (string expected, got " .. type(message) ..")", 2) end

	return self:PrintMessage(message, true, isDebug, chatFrame)
end

function lib32:PrintMessage(...)
	-- This is here only for backwards compatibility
	self:Print(...)
end


-- Timers Library
--[===[lib32.timers = {}

---Create a recurring or single-tick timer.\\
-- For example: calling a function after 5 seconds, or updating a list of objects every half-second
--@usage DEPRECATED. Please find an alternative.
function lib32:SetTimer(interval, callback, recur, uID, ...)
	error("SetTimer is deprecated and no longer supported.", 2)
	--[[
	--Redundancy checks
	if type(interval) ~= 'number' then error("bad argument #1 to \'SetTimer\', (number expected, got " .. type(interval) ..")", 2) end
	if type(callback) ~= 'function' then error("bad argument #2 to \'SetTimer\', (function expected, got " .. type(callback) ..")", 2) end

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
		for k, _ in pairs(lib32.timers) do
			if k.uID == uID then
				return -1
			end
		end
	end
	lib32.timers[timer] = timer
	return timer
	]]
end

---Stop an existing timer. This function requires a timer instance created with :SetTimer()
--@usage DEPRECATED. Please find an alternative.
function lib32:KillTimer(timer)
	error("KillTimer is deprecated and no longer supported.", 2)
	--[[
	if type(timer) ~= 'table' then error("bad argument #1 to \'KillTimer\', (table expected, got " .. type(timer) ..")", 2) end
	if lib32.timers[timer] then
		lib32.timers[timer] = nil
		return nil
	else
		return timer
	end]]
end


-- How often to check timers. Lower values are more CPU intensive.
local granularity = 0.1

local totalElapsed = 0
local function OnUpdate(self, elapsed)
   totalElapsed = totalElapsed + elapsed
   if totalElapsed > granularity then
	  for k,t in pairs(lib32.timers) do
		 t.update = t.update + totalElapsed
		 if t.update > t.interval then
			local success, rv = pcall(t.callback, unpack(t))
			if not rv and t.recur then
			   t.update = 0
			else
			   lib32.timers[t] = nil
			   if not success then error("Timer Callback failed:" .. rv, 0) end
			end
		 end
	  end
	  totalElapsed = 0
   end
end
CreateFrame("Frame"):SetScript("OnUpdate", OnUpdate)
]===]

lib32.mixinTargets = lib32.mixinTargets or {}
local mixins = {
	"PrintMessage",
	"PrintErr",
	"PrintDebug",
	"SetDefaultChatFrame",
	"ParseColorCodedString",
}

---Embed this library into an addon, and store it's 'short title' for addon output.\\
--The addonName is used in PrintMessage, showing which addon is accosting the user with information.\\
--If you wish to change the default color used by the title, it's possible, by adding your color string in the "addonName" field.
--@param target The table you want to embed the library into.//(table)//
--@param addonName The short title of your addon, used in PrintMessage calls.//(string)//
--@usage LibStub:GetLibrary("lib32-1.0"):Embed(YourAddon, "addonName")
function lib32:Embed(target, addonName)
	--Redundancy checks
	if type(target) ~= 'table' then error("bad argument #1 to \'Embed\', (table expected, got " .. type(target) ..")", 2) end

	if type(addonName) == "nil" then
		-- check "target", to see if it's an Ace3 mixin
		if target.name then
			addonName = target.name
		else
			if type(addonName) ~= 'string' then error("Unable to name addon. Bad argument #2 to \'Embed\', (string expected, got " .. type(addonName) ..")", 2) end
		end
	end


	for _, name in pairs(mixins) do
		target[name] = lib32[name]
	end
	-- Pass Lib variables to the addon as well on embed.
	target.name = addonName
	target._DefaultChatFrame = DEFAULT_CHAT_FRAME
	target._DebugMode = false

	lib32.mixinTargets[target] = true
end

-- Update the old embeds
for target, _ in pairs(lib32.mixinTargets) do
	lib32:Embed(target, target._AddonRegisteredName)
end
]=========]
