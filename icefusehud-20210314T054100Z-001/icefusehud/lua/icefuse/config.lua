
--[[-------------------------------------------------------------------------
icefuse {{ script_version_name }} Configuration
---------------------------------------------------------------------------]]
icefuse.config = {} 

--[[-------------------------------------------------------------------------
HUD Language
---------------------------------------------------------------------------]]
//Use the file name from the lang folder, make sure to remove the .lua extension
//Currently available languages: english, francais, deutsch, polskie, русский, chinese, türk
icefuse.config.language = "english"
icefuse.config.serverName = "Icefuse Networks"

--[[-------------------------------------------------------------------------
HUD Theme
---------------------------------------------------------------------------]]
//Use the file name from the themes folder, make sure to remove the .lua extension
//Currently available languages: default, dark, light, opaque
icefuse.config.theme = "icefuse_blue"

--[[-------------------------------------------------------------------------
HUD Resource Settings
---------------------------------------------------------------------------]]
icefuse.config.usefastdl = false //Should the HUD icons be added to fast dl?
icefuse.config.useworkshopdl = false //Should the content be added to force download?

icefuse.config.useimgur = true //Should we download the HUD materials from imgur instead of fast dl or workshop?
icefuse.config.customdlurl = "" //Set to "" to disable. Should we download the HUD materials from a custom url instead of fast dl or workshop?

icefuse.config.customfont = "Arial" //What font should the HUD use? Make you get the correct font name (https://wiki.facepunch.com/gmod/Finding_the_Font_Name)

--[[-------------------------------------------------------------------------
HUD Element Positioning and Sizing Settings
---------------------------------------------------------------------------]]
icefuse.config.padding = 30 //The spacing in pixels from the sides of the screen
icefuse.config.elementspacing = 10 //The spacing between grouped boxes

icefuse.config.barfontsize = 20 //The size of the font used on the bar hud
icefuse.config.barelementspacing = 20 //The spacing between items on the bar hud
icefuse.config.bariconspacing = 8 //The spacing between an icon and the text on the bar hud
icefuse.config.barheight = 36 //The height of the bar
icefuse.config.barunderlineheight = 2 //The height of the bar underline
icefuse.config.barbottom = false //Should the bar hud be on the bottom?

--[[-------------------------------------------------------------------------
HUD Element Visibility Settings
---------------------------------------------------------------------------]]
icefuse.config.barhud = true //Should we use the bar hud?
icefuse.config.enableHungermod = true //Should we show the player's hunger?
icefuse.config.enableLevellingSystem = true //Should we show the player's level?
icefuse.config.hideHungerWhenNone = false //Should the hunger bar be hidden if your hunger is 0?
icefuse.config.hideArmourWhenNone = false //Should the armour bar be hidden if your armour is 0?
icefuse.config.hideAgendaWhenNone = true //Should the agenda be hidden if there is none set?
icefuse.config.hideLockdownBox = false //Should the lockdown message only appear when it is set?
icefuse.config.hideLawsBox = false //Should the laws be displayed on screen?
icefuse.config.toggleLawsKey = 2 //What F key should we use to toggle the laws on screen?
icefuse.config.hideAvatar = false //Should we hide the avatar on your HUD?
icefuse.config.hideOverheads = false //Should we hide player overheads?
icefuse.config.wantedFlash = true //Should the wanted text flash?

--[[-------------------------------------------------------------------------
End of icefuse Configuration

DO NOT TOUCH ANYTHING BELOW THIS
---------------------------------------------------------------------------]]

if IsValid(icefusePlayerAvatar) then //Reset the avatar for the people who change from the normal hud to bar while already in game
	icefusePlayerAvatar:Remove()
end
icefusePlayerAvatar = false
--{{ user_id }}
