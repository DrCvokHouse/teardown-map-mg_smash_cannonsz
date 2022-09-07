#include "Builder.lua"
#include "Enums.lua"
#include "Extensions.lua"
#include "Props/Axes.lua"
#include "Props/Textures.lua"
#include "Props/Sectors.lua"
#include "CannonAi.lua"

local cannons = {}

function init()
    DebugPrint("Test lua")

    local boundsMin = GetLocationTransform(FindLocation("boundsMin", true)).pos
    local boundsMax = GetLocationTransform(FindLocation("boundsMax", true)).pos
    DebugDump(boundsMin)
    DebugDump(boundsMax)
    Delete(FindBody("boundsMin", true))
    Delete(FindBody("boundsMax", true))

    local foundCannons = FindBodies('cannon_1', true)

    for i=1, #foundCannons do
        table.insert(cannons,CannonAi:new(nil, foundCannons[i], boundsMin, boundsMax))
    end
    -- initialize Cannos
    table.insert(cannons,CannonAi:new(nil, FindBody('cannon_1', true), boundsMin, boundsMax))

    for i=1, #cannons do
        cannons[i]:activate()
    end
end

function tick(dt)
    for i=1, #cannons do
        cannons[i]:process(dt)
        cannons[i]:debug_drawLineToTarget(dt)
    end

    local platformTargets = GetPlatformTargets()
    -- filtter no shapes 

    local filteredTargets = {}
    for i=1, #platformTargets do
        if table.getn(GetBodyShapes(platformTargets[i])) >1 then
            local bodyTransform = GetBodyTransform(platformTargets[i])
            DebugLine(bodyTransform.pos, GetPlayerTransform().pos,1, 0, 0)

            --table.insert(filteredTargets,platformTargets[i])
        end
    end

end
