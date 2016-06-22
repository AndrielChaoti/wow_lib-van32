---A simple library for consolidating functions used often by Van32's addons
--
-- **LibVan32-2.0** can be embedded into your addon, either explicitly by calling LibVan32:Embed(MyAddon, "MyAddonName") or by
-- specifying it as an embedded library in your AceAddon. All functions will be available on your addon object
-- and can be accessed directly, without having to explicitly call LibVan32 itself.\\
-- It is recommended to embed LibVan32, otherwise you'll have to specify a custom `self` on all calls you
-- make into LibVan32.
--@class file
--@name LibVan32-2.0
--@version @file-revision@: @file-date-iso@

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
-- GLOBALS: _G, getmetatable, setmetatable
local pairs, string, error, type = pairs, string, error, type
local bit, tostring = bit, tostring

-- Library Functions --
-----------------------
local parseString, checkChatFrame, Embed, SetDefaultChatFrame, ParseColoredString, Print, PrintDebug, PrintError

---The list of valid color codes
--@name //addOn//.colorTable
--@field §0 Black
--@field §1 Dark Blue
--@field §2 Dark Green
--@field §3 Dark Aqua
--@field §4 Dark Red
--@field §5 Purple
--@field §6 Gold
--@field §7 Grey
--@field §8 Dark Grey
--@field §9 Indigo
--@field §a Bright Green
--@field §b Aqua
--@field §c Red
--@field §d Pink
--@field §e Yellow
--@field §f White
--@field §r reset
--@field §T Title, (light purple)
--@field #c Custom 32 bit hex color code (ex #cff0000 for solid red)
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
	["§T"]="|cFFAF96FF",	-- Title, (light purple)
	["#c"]="|cFF", 		-- custom color
}

-- internally used only.
local function getaddonname( self ) return self.name end

-- Handles string parsing for the library (internal)
--@param string the string to be parsed.
--@return the string with all color escapes replaced with valid ui escape sequences
local function parseString(string)
	local fStr = string
	for k,v in pairs(colorTable) do
		fStr = string.gsub(fStr, k, v)
	end
	return fStr
end

-- Checks the name of the chatframe against an actual frame, to see if it is valid
--@param chatFrame the name of the chatframe to check
local function checkChatFrame( chatFrame )
	if _G[chatFrame] and (not type(_G[chatFrame].AddMessage) == "function") then
		error("invalid chatFrame specified", 2)
	end
	return chatFrame
end

--- Set the default chat frame used for Print() calls when no frame is specified.
--@name //addOn//:SetDefaultChatFrame
--@paramsig chatFrame
--@param chatFrame the name of the "ChatFrame" object to change the default to
--@usage self:SetDefaultChatFrame("frame")
local function SetDefaultChatFrame( self, chatFrame )
	chatFrame = checkChatFrame(chatFrame)

	self._dfc = chatFrame
end

--- Parse and output a string containing library color code shortcuts.
--@name //addOn//:ParseColoredString
--@paramsig string
--@param string the string to parse
--@return the formatted string, with all §x color codes replaced with valid ui escape sequences.
--@usage self:ParseColoredString("string")
local function ParseColoredString( self, string )
	if type( string ) ~= "string" then
		error( ("bad argument #1 to \'ParseColoredString\', (string expected, got %s)"):format(type(string)), 2 )
	end
	return parseString( string )
end

--- messageType enumeration.\\
-- These options can be combined (added together), or used individually. There is no need to specify STANDARD when printing messages, it is the default output.
--@name //addOn//.MessageTypeEnum
--@field STANDARD messages do not have any prefixes\\
--@field ERROR messages will be prefixed with a light red [ERROR]\\
--@field DEBUG messages will be prefixed with a dark grey <Debug>, and only be shown if your addon sets _DebugMode to true\\

local MessageTypeEnum = {
	["STANDARD"] = 0,
	["ERROR"] = 1,
	["DEBUG"] = 2,
}

--- Prints a formatted and prefixed message to the specified chat frame.\\
-- The message is prefixed with the addon's name that was set at embed time, and any message flags that were chosen.
--@name //addOn//:Print
--@paramsig message [, messagetype [, chatFrame]]
--@param message the message to print to the chat.
--@param messageType a valid message type. @see messageTypeEnum (optional)
--@pram chatFrame the name of the chatframe where you want the message to be printed (optional)
--@usage self:Print("message", messageType, "chatFrame")
--@return the values returned from the chat frame's "AddMessage" method.
local function Print( self, message, messageType, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	-- handle optional arguments
	messageType = messageType or self.MessageTypeEnum.STANDARD
	chatFrame = checkChatFrame(chatFrame or self._dfc or "DEFAULT_CHAT_FRAME")

	-- start building our message:
	local fMessage = ("§T%s§r: "):format( tostring(self) )

	-- check message prefixes:
	if bit.band(messageType, self.MessageTypeEnum.DEBUG) ~= 0 then -- debug flag set
		if not self._DebugMode then return end
		fMessage = fMessage .. "§8<Debug>§r "
	end

	if bit.band(messageType, self.MessageTypeEnum.ERROR) ~= 0 then -- error flag set
		fMessage = fMessage .. "§c[ERROR]§r "
	end

	fMessage = fMessage .. message

	return _G[chatFrame]:AddMessage(parseString(fMessage))

end

--- Doubles as a shortcut for :Print("message", self.messageTypeEnum.DEBUG)
--@name //addOn//:PrintDebug
--@paramsig message [, isError [, chatFrame]]
--@param message the message to print to the chat.
--@param isError whether or not to also show the [ERROR] tag (optional)
--@pram chatFrame the name of the chatframe where you want the message to be printed (optional)
--@usage self:Print("message", isError, "chatFrame")
--@return the values returned from the chat frame's "AddMessage" method.
local function PrintDebug( self, message, isError, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	return self:Print( message, self.MessageTypeEnum.DEBUG + (isError and self.MessageTypeEnum.ERROR or 0), chatFrame )
end

--- Doubles as a shortcut for :Print("message", self.messageTypeEnum.ERROR)
--@name //addOn//:PrintError
--@paramsig message [, isDebug [, chatFrame]]
--@param message the message to print to the chat.
--@param isDebug whether or not to also show the <Debug> tag (optional)
--@pram chatFrame the name of the chatframe where you want the message to be printed (optional)
--@usage self:PrintError("message", isDebug, "chatFrame")
--@return the values returned from the chat frame's "AddMessage" method.
local function PrintError( self, message, isDebug, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	return self:Print( message, self.MessageTypeEnum.ERROR + (isDebug and self.MessageTypeEnum.ERROR or 0), chatFrame )
end


-- Embedding --
---------------
lib.addons = lib.addons or {}
local mixins = {
	Print = Print,
	PrintDebug = PrintDebug,
	PrintError = PrintError,
	SetDefaultChatFrame = SetDefaultChatFrame,
	ParseColoredString = ParseColoredString,
	MessageTypeEnum = MessageTypeEnum,
	colorTable = colorTable,
}
local pmixins = {
	_DebugMode = false,
	_dfc = "DEFAULT_CHAT_FRAME",
}

--- Handles addon embedding. This is best done as a mix-in with AceAddon-3.0
--@name LibVan32:Embed
--@paramsig object, name
--@param object the table to embed the library into
--@param name the name of the object the library will use for function calls.
--@usage
-- LibVan32:Embed(object, "name")
-- -- Or, when embedding with an AceAddon, name is not required, as it is already set.
-- LibVan32:Embed(object)
function lib:Embed( object, name )
	if type(object) ~= "table" then
		error( ("bad argument #1 to \'Embed\', (table expected, got %s)"):format(type(object)), 2 )
	end

	-- This library is meant to be an Ace3 mixin, but if we don't do that, we still need a name
	-- for any things that happen here.
	if not tostring(object) then
		if type(name) ~= "string" then
			error( ("bad argument #2 to \'Embed\', (string expected, got %s)"):format(type(name)), 2 )
		end

		object.name = name
		-- we need to set up metatable here to add a name to the addon...
		local m = {}

		-- import the old metatable if there is one...
		local oldmeta = getmetatable(object)
		if oldmeta then
			for k, v in pairs(oldmeta) do m[k] = v end
		end
		-- add our metatable
		m.__tostring = getaddonname

		setmetatable(object, m)
	end

	Embed( object )
	return object
end

-- this is a local function specifically since it's meant to be only called internally
function Embed(target, skipPMixins)
	for k, v in pairs(mixins) do
		target[k] = v
	end
	if not skipPMixins then
		for k, v in pairs(pmixins) do
			target[k] = target[k] or v
		end
	end
end

-- update embed
for name, addon in pairs(lib.addons) do
	Embed(addon, true)
end
