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

local function getaddonname( self ) return self.name end


local function parseString(string)
	local fStr = string
	for k,v in pairs(colorTable) do
		fStr = string.gsub(fStr, k, v)
	end
	return fStr
end


local function checkChatFrame( chatFrame )
	if _G[chatFrame] and (not type(_G[chatFrame].AddMessage) == "function") then
		error("invalid chatFrame specified", 2)
	end
	return chatFrame
end

local function SetDefaultChatFrame( self, chatFrame )
	chatFrame = checkChatFrame(chatFrame)

	self._dfc = chatFrame
end


local function ParseColoredString( self, string )
	if type( string ) ~= "string" then
		error( ("bad argument #1 to \'ParseColoredString\', (string expected, got %s)"):format(type(string)), 2 )
	end
	return parseString( string )
end


local MessageTypeEnum = {
	["STANDARD"] = 0,
	["ERROR"] = 1,
	["DEBUG"] = 2,
}


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


local function PrintDebug( self, message, isError, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	self:Print( message, self.MessageTypeEnum.DEBUG + (isError and self.MessageTypeEnum.ERROR or 0), chatFrame )
end


local function PrintError( self, message, isDebug, chatFrame )
	if type( message ) ~= "string" then
		error( ("bad argument #1 to \'Print\', (string expected, got %s)"):format(type( message )), 2 )
	end

	self:Print( message, self.MessageTypeEnum.ERROR + (isDebug and self.MessageTypeEnum.ERROR or 0), chatFrame )
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
