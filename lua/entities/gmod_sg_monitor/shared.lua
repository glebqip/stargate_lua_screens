if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "SGC Computer monitor"
ENT.Author = "glebqip"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.RequestScreenReload = true

function ENT:ReloadScreen(ID)
  local tbl = self.GetScreenFunctions[ID](self,true)
  for k,v in pairs(self.Screens[ID]) do
    self.Screens[ID][k] = tbl[k] or v
  end
end
--Screens loading func
ENT.GetScreenFunctions = {}
for _,filename in pairs(file.Find("entities/gmod_sg_monitor/screens/*.lua","LUA")) do
  local ID,SCR = include("entities/gmod_sg_monitor/screens/"..filename)
  --Creating a function, that returns a copy! of screen functions
  ENT.GetScreenFunctions[ID] = function(self,noinit)
    local tbl = {}

    for k,v in pairs(SCR) do
      tbl[k] = v
    end

    tbl.Entity = self
    tbl.GetMonitorBool = function(_, id, default) return tbl.Entity:GetNW2Bool(id, default) end
    tbl.GetMonitorInt = function(_, id, default) return tbl.Entity:GetNW2Int(id, default) end
    tbl.GetMonitorString = function(_, id, default) return tbl.Entity:GetNW2String(id, default) end
    tbl.GetServerBool = function(_,id, default)
      if not IsValid(tbl.Entity.Server) then return default end
      return tbl.Entity.Server:GetNW2Bool(id, default)
    end
    tbl.GetServerInt = function(_,id, default)
      if not IsValid(tbl.Entity.Server) then return default end
      return tbl.Entity.Server:GetNW2Int(id, default)
    end
    tbl.GetServerString = function(_,id, default)
      if not IsValid(tbl.Entity.Server) then return default end
      return tbl.Entity.Server:GetNW2String(id, default)
    end
    tbl.EmitSound = function(_,...) return tbl.Entity:EmitSound(...) end
    if not noinit then tbl:Initialize() end
    return tbl
  end
end

function ENT:Think()
  print(2)
end
