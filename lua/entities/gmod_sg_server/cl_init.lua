include("shared.lua")
if true then return end

if (SGLanguage ~=nil and SGLanguage.GetMessage ~=nil) then
  ENT.Category = SGLanguage.GetMessage("entity_main_cat")
  ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end
