local config <const> = require "config"
local submixList     = {}
local functions      = {}
local submixCount    = -1

function functions.Debug(msg, ...)
    if not config.enableDebug then return end

    local params = {}

    for _, param in ipairs({ ... }) do
        if type(param) == "table" then
            param = json.encode(param)
        end

        params[#params + 1] = param
    end

    print((msg):format(table.unpack(params)))
end

function functions.GetSubmix(submixName)
    return submixList[submixName]
end

function functions.SetAudioSubmixEffect(submixName, effects)
    local submix <const> = functions.GetSubmix(submixName)
    if not submix then
        return functions.Debug('Submix Not Found! | %s', submixName)
    end

    local submixSlot <const> = submix.slot
    local submixId <const> = submix.id
    if not submixSlot then submixCount = submixCount + 1 end
    local slot <const> = submixSlot or submixCount

    SetAudioSubmixEffectRadioFx(submixId, slot)
    SetAudioSubmixEffectParamInt(submixId, slot, `default`, 1)
    for hash, value in pairs(effects) do
        SetAudioSubmixEffectParamFloat(submixId, slot, hash, value)
    end
    if submixId ~= 0 then
        AddAudioSubmixOutput(submixId, slot)
    end
    submixList[submixName].slot = slot
    functions.Debug('Updated Submix parameters | %s', submixName)
end

function functions.CreateAudioSubmix(configData)
    local submixName <const> = configData.name
    if not configData.id then
        local submixId <const> = CreateAudioSubmix(submixName)
        submixList[submixName] = { id = submixId }
        functions.Debug('Registered Submix | Id: %s Name: %s', submixId, submixName)
    else
        submixList[submixName] = { id = configData.id, slot = configData.slot }
        functions.Debug('Registered Mastergame Submix | Id: %s Name: %s', configData.id, submixName)
    end
end

function functions.SetPlayerSubmixEffect(submixName, serverId, playerData)
    if submixName then
        local submixId <const> = functions.GetSubmix(submixName)?.id
        if not submixId then
            return functions.Debug('SubmixId Not Found! | %s', submixName)
        end
        playerData.activeSubmix = submixName
        MumbleSetSubmixForServerId(serverId, submixId)
        --MumbleSetVolumeOverrideByServerId(serverId, 1.0)
        functions.Debug('Player submix effect is actvie | Player: %s Submix: %s', serverId, submixName)
    else
        if playerData then playerData.activeSubmix = nil end
        MumbleSetSubmixForServerId(serverId, -1)
        --  MumbleSetVolumeOverrideByServerId(serverId, -1.0)
        functions.Debug('Player submix effect is deactvie | Player: %s', serverId)
    end
end

function functions.DetectPlayerSubmix(playerData)
    local playerPed <const> = GetPlayerPed(playerData.playerId)
    if not DoesEntityExist(playerPed) then return end
    local isSubmixActive <const> = playerData.activeSubmix
    local serverId <const> = playerData.serverId
    -- Under water effect
    local isPedSwimmingUnderWater <const> = IsPedSwimmingUnderWater(playerPed)
    if not isSubmixActive and isPedSwimmingUnderWater then
        functions.SetPlayerSubmixEffect(config.underWaterTalking.name, serverId, playerData)
    elseif isSubmixActive == config.underWaterTalking.name and not isPedSwimmingUnderWater then
        functions.SetPlayerSubmixEffect(nil, serverId, playerData)
    end
end

return functions
