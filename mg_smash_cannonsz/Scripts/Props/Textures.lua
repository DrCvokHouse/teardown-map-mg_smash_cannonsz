#include "../Builder.lua"
#include "../Enums.lua"




function Samples_Textures()

    for i = 0, 31, 1 do
        local voxBox = Build_Voxbox_Raw(
            CreateParam("size", 10, 10, 10),
        --CreateParam("rot", 0, 0, 0),
            CreateParam("material", MyMaterial.WOOD.Name),
        -- CreateParam("prop", isProp),
            CreateParam("color", RGB255String_To_RGB01String(MyMaterial.GLASS.Color)),
            CreateParam("texture",  i)
        )

        Spawn(voxBox,Transform(Vec( 2*i ,1.1,0)), true,true)
    end
end