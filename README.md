# LibVan32
A personal library for use in the Van32 line of addons. See the [documentation]() for information on the [Library's API]()

To put simply, the library just handles message printing that accepts "Minecraft-style" color codes in the strings, to make for coloring output text easier.

## Importing
### `.pkgmeta` method
```yaml
externals:
   libs/LibStub:
      url: svn://svn.wowace.com/wow/libstub/mainline/trunk
      tag: latest
   libs/!LibVan32:
      url: svn://svn.curseforge.net/wow/libvan32/mainline/trunk
      tag: latest
```
### Download method
Download the library's latest release and add the contents of the folder to your addon's libs folder.
Make sure you also get a copy of [LibStub](http://www.wowace.com/addons/libstub/) while you are at it, and put it in the same place.
## Embedding it in your addon
Import this into your addon using embeds.xml like so

`Embeds.xml`
```xml
  <Script file="libs\LibStub\LibStub.lua">
  <Script file="libs\!LibVan32\LibVan32.lua">
```

### Embedding (Without AceAddon):
```lua
local YourAddonTable = {}
LibStub:GetLibrary("LibVan32-2.0"):Embed(YourAddonTable, "YourAddonName")
```
### Embedding (WithAceAddon):
```lua
MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddonName","LibVan32-2.0")
```
