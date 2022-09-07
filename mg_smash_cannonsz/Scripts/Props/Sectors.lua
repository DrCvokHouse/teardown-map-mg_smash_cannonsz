#include "../Builder.lua"
#include "../Enums.lua"




function Samples_Sector(xOffset,yOffset,zOffset,width, height, depth, tag)
    local centerColor = "255 0 0 50"
    local colide = false
    local allowStatic = true

    local xColor = "255 0 0 100"
    local YColor = "0 255 0 100"
    local ZColor = "0 0 255 100"

    local materialName = MyMaterial.GLASS.Name

    local bottom = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", width, 1, depth),
        CreateParam("collide", colide),
        CreateParam("desc", "sector"),
        CreateParam("material",materialName),
        CreateParam("color", RGB255String_To_RGB01String(YColor))
    )
    local spawned_center = Spawn(bottom,Transform(Vec(0 + xOffset, 0 + yOffset, 0 + zOffset)), allowStatic,false)

    local top = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", width, 1, depth),
        CreateParam("collide", colide),
        CreateParam("desc", "sector"),
        CreateParam("material",materialName),
        CreateParam("color", RGB255String_To_RGB01String(YColor))
    )
    local spawned_center = Spawn(top,Transform(Vec(0 + xOffset, (height * 0.1) + yOffset, 0 + zOffset)), allowStatic,false)

     local right = Build_Voxbox_Raw(
         CreateParam("tags", tag),
         CreateParam("size", 1, height, depth),
         CreateParam("collide", colide),
         CreateParam("desc", "sector"),
         CreateParam("material",materialName),
         CreateParam("color", RGB255String_To_RGB01String(xColor))
     )
   local spawned_center = Spawn(right,Transform(Vec(0 + xOffset, 0 + yOffset, 0 + zOffset)), false,false)

    local left = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", 1, height, depth),
        CreateParam("collide", colide),
        CreateParam("desc", "sector"),
        CreateParam("material",materialName),
        CreateParam("color", RGB255String_To_RGB01String(xColor))
    )
   local spawned_center = Spawn(left,Transform(Vec((width * 0.1) + xOffset, 0 + yOffset, 0 + zOffset)), allowStatic,false)

   local back = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", width, height, 0),
        CreateParam("collide", colide),
        CreateParam("desc", "sector"),
        CreateParam("material",materialName),
        CreateParam("color", RGB255String_To_RGB01String(ZColor))
    )
    local spawned_center = Spawn(back,Transform(Vec(0 + xOffset, 0 + yOffset, (depth * 0.1) + zOffset)), allowStatic,false)

    local front = Build_Voxbox_Raw(
        CreateParam("tags", tag),
        CreateParam("size", width, height, 0),
        CreateParam("collide", colide),
        CreateParam("desc", "sector"),
        CreateParam("material",materialName),
        CreateParam("color", RGB255String_To_RGB01String(ZColor))
    )
    local spawned_center = Spawn(front,Transform(Vec(0 + xOffset, 0 + yOffset, 0 + zOffset)), allowStatic,false)



    -- local right = Build_Voxbox_Raw(
    --     CreateParam("tags", tag),
    --     CreateParam("size", width, hight, depth),
    --     CreateParam("collide", false),
    --     CreateParam("desc", "sector"),
    --     CreateParam("material",MyMaterial.GLASS.Name),
    --     CreateParam("color", RGB255String_To_RGB01String(centerColor))
    -- )
    -- local front = Build_Voxbox_Raw(
    --     CreateParam("tags", tag),
    --     CreateParam("size", width, hight, depth),
    --     CreateParam("collide", false),
    --     CreateParam("desc", "sector"),
    --     CreateParam("material",MyMaterial.GLASS.Name),
    --     CreateParam("color", RGB255String_To_RGB01String(centerColor))
    -- )
    -- local back = Build_Voxbox_Raw(
    --     CreateParam("tags", tag),
    --     CreateParam("size", width, hight, depth),
    --     CreateParam("collide", false),
    --     CreateParam("desc", "sector"),
    --     CreateParam("material",MyMaterial.GLASS.Name),
    --     CreateParam("color", RGB255String_To_RGB01String(centerColor))
    -- )
end