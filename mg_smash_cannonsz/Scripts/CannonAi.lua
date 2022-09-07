#include "Extensions.lua"


CannonAiTags = {
    target_platform = "target_platform",
}

CannonAiStates = {
    Idle = 1,
    Targeting = 2,
    Shooting = 3,
}

CannonAiTargetMode = {
    Player,
    Platforms,
    RandomArea
}

CannonAiDebugSettings = {
    Debug_NextStageTimeout = false,
    Debug_ChangeStage = false
}

CannonAi = {
    assignedBody = nil,
    isActive = false,
    state = CannonAiStates.Idle,
    target = nil, 
    projectileSpeed = 100,
    aimDeviation = 0.1,
    nextStageTimeout = 0,
    debugPrintActive = true,
    retagSystemActive = true,
    shootAtPlayer = false,
    shootAtTargets = true,
    bulletVox = "<voxbox size='10 10 10' prop='true' strength='100' material='wood' density='10'/>"
    }

CannonAi.__index = CannonAi


-- this will be probabbly bad idea, 
-- but there are no clear way how to get reference on shapes and bodies of newly created chunks
function InitializeTargetsMaterialColorPallete(boundsMin, boundsMax)
    local bodies = QueryAabbBodies(boundsMin, boundsMax)
    local cannonAiMaterialColorPalete = {}

    for i=1, #bodies do
        local body = bodies[i]
        -- filter all bodies which does not have tag "target_platform"
        if(HasTag(body, CannonAiTags.target_platform))then
            local shapes = GetBodyShapes(body)
            for j=1, #shapes do

                local min, max = GetShapeBounds(shapes[j])
                local boundsSize = VecSub(max, min)
                local center = VecLerp(min, max, 0.5)

                -- issue: shape must have one color
                -- maybe texture will fuck this up
                local material, r, g, b, a = GetShapeMaterialAtPosition(shapes[j],center)

                if(not has_value(cannonAiMaterialColorPalete, {material, r, g, b, a}, true ))then
                    table.insert(cannonAiMaterialColorPalete, {material, r, g, b, a})
                end
            end
        end
    end
    return cannonAiMaterialColorPalete
end

function CannonAi:SetDefaults(o)
    o.assignedBody = nil
    o.isActive = false
    o.state = CannonAiStates.Idle
    o.target = nil
    o.aimDeviation = 0.1
    o.nextStageTimeout = 0
    o.debugPrintActive = true
    o.TargetMaterialColorPalette = nil
    o.targetAreaMin = nil
    o.targetAreaMax = nil
    o.minTargetVoxelCount = 250
end

function CannonAi:new(o, assignedBody, targetAreaMin, targetAreaMax)
    local item = o or {}
    setmetatable(item, self)
    self.__index = self
    item.SetDefaults(item,item)
    item.assignedBody = assignedBody
    item.targetAreaMin = targetAreaMin
    item.targetAreaMax = targetAreaMax
    item.TargetMaterialColorPalette = InitializeTargetsMaterialColorPallete(targetAreaMin, targetAreaMax)
    return item
end

function CannonAi:activate()
    self.isActive = true
end

function CannonAi:debugPrint(o, message, debugSettingsItem)
    if(not self.debugPrintActive)then
        return
    end
    if(debugSettingsItem == null or not debugSettingsItem)then
        return
    end
    DebugDump(o, message)
end

function CannonAi:process(dt)
    if(not self.isActive)then
        return
    end

    if(self.nextStageTimeout > 0)then
        self:debugPrint(self.nextStageTimeout, "timeout: ", CannonAiDebugSettings.Debug_NextStageTimeout)
        self.nextStageTimeout = self.nextStageTimeout - dt
        return
    end

    if(self.state == CannonAiStates.Idle) then

        self:debugPrint("","Entering to: Idle",CannonAiDebugSettings.Debug_ChangeStage)

        --Fix newly created bodies after destruction
        if(not self.retagSystemActive)then
            self:FixNewlyCreatedBodiesTags(self.targetAreaMin,self.targetAreaMax, self.minTargetVoxelCount)
        end
        
        local aimPositionsList = {}
        
        if(self.shootAtPlayer) then
            table.insert(aimPositionsList, GetPlayerTransform().pos) 
        end
        if(self.shootAtTargets)then
            -- find target      
            local platformTargets = GetPlatformTargets()

            -- filtter no shapes 
            local filteredTargets = {}
            for i=1, #platformTargets do
                local bodyShapes = GetBodyShapes(platformTargets[i])
                if table.getn(bodyShapes) > 1 then
                    local hasShapeInBounds = false
                    for j=1, #bodyShapes do
                        -- GetShape
                        -- TODO: shape in bounds
                    end
                    table.insert(filteredTargets,platformTargets[i])
                end
            end

            if(filteredTargets == nil or table.getn(filteredTargets) == 0)then
                self:debugPrint("","No targets found",true)
                return
            end
            self:debugPrint(table.getn(filteredTargets), "Possible targets: ",true)
            local platformBody = GetRandomBody(filteredTargets)
            DebugDump(platformBody,"platformBody:____")
            local platformShapes = GetBodyShapes(platformBody)
            DebugDump(platformShapes,"platformShapes:____")

            local highestShape = GetHighestShape(platformShapes)
            local targetPoint = GetRandomPointInShape(highestShape)
            DebugDump(targetPoint,"targetPoint")
            table.insert(aimPositionsList, targetPoint)
        end

        self.target = getRandomItem(aimPositionsList)
        
        self.nextStageTimeout = 3
        self.state = CannonAiStates.Targeting

        return
    end

    if(self.state == CannonAiStates.Targeting) then
        self:debugPrint("","Entering to: Targeting",CannonAiDebugSettings.Debug_ChangeStage)
        -- rotate body to point
        -- TODO: make smoth rotation
        local eye = GetBodyTransform(self.assignedBody)
        local rot = QuatLookAt(eye.pos, self.target)
        SetBodyTransform(self.assignedBody, Transform(eye.pos, rot))

        local aimDistance = 0
        if(aimDistance <= self.aimDeviation)then
            self.nextStageTimeout = 3
            self.state = CannonAiStates.Shooting
        end
        return
    end

    if(self.state == CannonAiStates.Shooting) then
        self:debugPrint("","Entering to: Shooting",CannonAiDebugSettings.Debug_ChangeStage)
        -- shoot
        local bt = GetBodyTransform(self.assignedBody)
        local aimpos = TransformToParentPoint(bt, Vec(0, 0, -self.projectileSpeed))
        local startpos = TransformToParentPoint(bt, Vec(0, 1, -2))
        local barrelend = TransformToParentPoint(bt, Vec(0, 1, -5))
    
        -- create bullet
        local entities =  Spawn(self.bulletVox, bt.pos )
        
        for index,item in ipairs(entities) do
            if(GetEntityType(item) == 'body') then
                SetBodyTransform(item, Transform(startpos, QuatEuler(0, 180, 0)))
                local direction = VecSub(aimpos, startpos)
                SetBodyVelocity(item, direction)
            end
        end

        self.targetPoint = nil
        self.nextStageTimeout = 3
        self.state = CannonAiStates.Idle
        return
    end

end

function CannonAi:deactivate()
    self.isActive = false
end


function CannonAi:debug_drawLineToTarget()
    if(self.target == nil)then
        return    
    end
    local bodyTransform = GetBodyTransform(self.assignedBody)
    DebugLine(bodyTransform.pos, self.target,1, 0, 0)
end

function CannonAi:FixNewlyCreatedBodiesTags(playArenaMin, playArenaMax, minTargetVoxelCount)
    local shapes = QueryAabbShapes(playArenaMin, playArenaMax)
  
    for i=1, #shapes do
        local shape = shapes[i]
        local body = GetShapeBody(shape)
        if(not  HasTag(body, CannonAiTags.target_platform) and 
                GetShapeVoxelCount(shape) > minTargetVoxelCount)then

            -- check if shape has specific color and material
            local min, max = GetShapeBounds(shape)
            local boundsSize = VecSub(max, min)
            local center = VecLerp(min, max, 0.5)
            local material, r, g, b, a = GetShapeMaterialAtPosition(shapes[i],center)

            if(has_value(self.TargetMaterialColorPalette, {material,r,g,b,a}, true))then
                DebugDump("setting tag ____")
                SetTag(body, CannonAiTags.target_platform)
            end
        end
    end
end


function GetPlatformTargets()
    local shapes = QueryAabbShapes()
    return FindBodies(CannonAiTags.target_platform, true)
end

function GetRandomBody(bodies)
   local index =  math.random(1,table.getn(bodies))
   return bodies[index]
end

function GetRandomPointInShape(shape)
    local min, max = GetShapeBounds(shape)
    return Vec(math.random(min[1],max[1]),math.random(min[2],max[2]),math.random(min[3],max[3]))
end

function GetRandomPointInBody(body)
    local min, max = GetBodyBounds(body)
    return Vec(math.random(min[1],max[1]),math.random(min[2],max[2]),math.random(min[3],max[3]))
end

function GetHighestShape(shapes)
    local currentMax = -9999
    local highestShape
    for i=1,#shapes do
        local shape = shapes[i]
        local min, max = GetShapeBounds(shape)
        if(max[2] > currentMax)then
            highestShape = shapes[i];
        end
    end
    return highestShape    
end
