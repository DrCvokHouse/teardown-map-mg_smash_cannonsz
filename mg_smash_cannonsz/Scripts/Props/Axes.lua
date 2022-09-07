#include "../Builder.lua"
#include "../Enums.lua"


function Samples_Axes_Disapiring(xOffset,yOffset,zOffset, ttl)
    local tag = Uuid()

    Samples_Axes(xOffset,yOffset,zOffset, tag)

    TimerManager.RegisterTimer(function ()
        local shapesToRemove = FindShapes(tostring(tag), true)
        local bodiesToRemove = FindBodies(tostring(tag), true)

         for key, value in ipairs(bodiesToRemove) do
             Delete(value)
         end
         for key, value in ipairs(shapesToRemove) do

             Delete(value)
         end
    end,
    Global.Elapsed + ttl,
    true)

end

function Samples_Axes(xOffset,yOffset,zOffset, tag)
    local centerColor = "0 0 0 100"
    local xColor = "255 0 0 100"
    local YColor = "0 255 0 100"
    local ZColor = "0 0 255 100"

    --local xOffset = 0
    --local yOffset = 2
    --local zOffset = 0

    local center = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 1, 1, 1),
        CreateParam("collide", false),
        CreateParam("desc", "center"),
        CreateParam("material",MyMaterial.GLASS.Name),
        CreateParam("color", RGB255String_To_RGB01String(centerColor))
    )
    local spawned_center = Spawn(center,Transform(Vec(0 + xOffset, 0 + yOffset, 0 + zOffset)), false,false)


    local xMinus = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 1, 1, 1),
        CreateParam("collide", false),
        CreateParam("desc", "X -"),
        CreateParam("color", RGB255String_To_RGB01String(xColor))
    )
    for i=1,5 do
        Spawn(xMinus,Transform(Vec( (-0.2 * i) + xOffset, 0 + yOffset,0 + zOffset)), false,false)
    end
    
    local xPlus = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 10, 1, 1),
        CreateParam("collide", false),
        CreateParam("desc", "X +"),
        CreateParam("color", RGB255String_To_RGB01String(xColor))
    )
    Spawn(xPlus,Transform(Vec( 0.1 + xOffset ,0 + yOffset, 0 + zOffset)), false,false)
--
    -- Y
    local YMinus = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 1, 1, 1),
        CreateParam("collide", false),
        CreateParam("desc", "Y -"),
        CreateParam("color", RGB255String_To_RGB01String(YColor))
    )
    for i=1,5 do
        Spawn(YMinus,Transform(Vec( 0 + xOffset, (-0.2 *i) + yOffset ,0 + zOffset)), false,false)
    end
    
    local YPlus = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 1, 10, 1),
        CreateParam("collide", false),
        CreateParam("color", RGB255String_To_RGB01String(YColor))
    )
    Spawn(YPlus,Transform(Vec( 0 + xOffset, 0.1 + yOffset, 0 + zOffset)), false,false)

     --Z
    local ZMinus = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 1, 1, 1),
        CreateParam("collide", false),
        CreateParam("desc", "Z -"),
        CreateParam("color", RGB255String_To_RGB01String(ZColor))
    )
    for i=1,5 do
        Spawn(ZMinus,Transform(Vec( 0 + xOffset , 0 + yOffset , (-0.2 * i) + zOffset)), false,false)
    end
    
    local ZPlus = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 1, 1, 10),
        CreateParam("collide", false),
        CreateParam("desc", "Z +"),
        CreateParam("color", RGB255String_To_RGB01String(ZColor))
    )
    Spawn(ZPlus,Transform(Vec( 0 + xOffset , 0 + yOffset, 0.1 + zOffset)), false,false)
end
