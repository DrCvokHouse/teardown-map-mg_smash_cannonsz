#include "Enums.lua"



function MySplitString (inputstr, sep)
  if sep == nil then
     sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do 
     table.insert(t, str)
  end
  return t
end

function CreateParam(paramName, ...)
    local args = {...}
    if (table.getn(args) == 0) then return "" end
    local result = " "..paramName.."='"
    for i,v in ipairs(args) do
      if(i == table.getn(args))then
        result = result .. tostring(v)
      else
        result = result .. tostring(v) .." "
      end
    end
    return result .. "' "
end

function Map_0255_To_01(color255Int)
  return color255Int/255;
end

function RBG255_To_RGBFloatString(r,g,b)
  return ""..Map_0255_To_01(r).." ".. Map_0255_To_01(g).." "..Map_0255_To_01(b)
end
function RBGA255_To_RGBAFloatString(r,g,b,a)
  return ""..Map_0255_To_01(r).." ".. Map_0255_To_01(g).." "..Map_0255_To_01(b).." "..Map_0255_To_01(a)
end

function RGB255String_To_RGB01String(RGB255String)
  local r_g_b = MySplitString(RGB255String," ")
  if(table.getn(r_g_b) == 3)then
    return RBG255_To_RGBFloatString(r_g_b[1],r_g_b[2], r_g_b[3])
  end
  if(table.getn(r_g_b) == 4)then
    return RBGA255_To_RGBAFloatString(r_g_b[1],r_g_b[2], r_g_b[3],r_g_b[4])
  end
end

function Build_Voxbox(width, height, depth, rotX, rotY, rotZ, materialName, isProp, _255ColorString )
    return  "<voxbox "..
    CreateParam("size", width, height, depth) ..
    CreateParam("rot", rotX, rotY, rotZ) ..
    CreateParam("material", materialName) ..
    CreateParam("prop", isProp) ..
    CreateParam("color", RGB255String_To_RGB01String(_255ColorString)) ..
    "/>"
end
function Build_Voxbox_Raw(...)
  local args = {...}

  local result =  "<voxbox "
  for i,v in ipairs(args) do
      result = result .. tostring(v) .." "
  end
  return result ..  "/>"
end