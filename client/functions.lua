local config <const>      = require "config"
local talkingRadioPlayers = {}
local submixList          = {}
local functions           = {}
local submixCount         = -1

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
    if submix.default then SetAudioSubmixEffectParamInt(submixId, slot, `default`, 1) end
    if effects then
        for hash, value in pairs(effects) do
            SetAudioSubmixEffectParamFloat(submixId, slot, hash, value)
        end
    end

    if submix.volume then SetAudioSubmixOutputVolumes(submixId, slot, submix.volume, submix.volume, submix.volume, submix.volume, submix.volume, submix.volume) end

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
        submixList[submixName] = { id = submixId, slot = configData.slot, default = configData.default, volume = configData.volume, outputVolumes = configData.outputVolumes }
        functions.Debug('Registered Submix | Id: %s Name: %s', submixId, submixName)
    else
        submixList[submixName] = { id = configData.id, slot = configData.slot, default = configData.default, volume = configData.volume, outputVolumes = configData.outputVolumes }
        functions.Debug('Registered Mastergame Submix | Id: %s Name: %s', configData.id, submixName)
    end
end

function functions.SetPlayerSubmixEffect(submixName, serverId, playerData)
    if submixName then
        local submixId <const> = functions.GetSubmix(submixName)?.id
        if not submixId then
            return functions.Debug('SubmixId Not Found! | %s', submixName)
        end
        if playerData then playerData.activeSubmix = submixName end
        MumbleSetSubmixForServerId(serverId, submixId)
        --MumbleSetVolumeOverrideByServerId(serverId, 1.0)
        functions.Debug('Player submix effect is actvie | Player: %s Submix: %s', serverId, submixName)
    else
        if playerData then playerData.activeSubmix = nil end
        MumbleSetSubmixForServerId(serverId, -1)
        MumbleSetVolumeOverrideByServerId(serverId, -1.0)
        functions.Debug('Player submix effect is deactvie | Player: %s', serverId)
    end
end

function functions.DetectPlayerSubmix(playerData)
    local playerPed <const>             = GetPlayerPed(playerData.playerId)
    local clientPlayer <const>          = PlayerPedId()
    local clientPlayerInVehicle <const> = IsPedInAnyVehicle(clientPlayer)
    local clientPlayerVehicle <const>   = clientPlayerInVehicle and GetVehiclePedIsIn(clientPlayer) or false

    if not DoesEntityExist(playerPed) then return end
    local isSubmixActive <const> = playerData.activeSubmix
    local serverId <const> = playerData.serverId

    -- Under water effect
    if config.effects.underWaterTalking.active then
        local isPedSwimmingUnderWater <const> = IsPedSwimmingUnderWater(playerPed)
        if not isSubmixActive and isPedSwimmingUnderWater then
            functions.SetPlayerSubmixEffect(config.effects.underWaterTalking.name, serverId, playerData)
        elseif isSubmixActive == config.effects.underWaterTalking.name and not isPedSwimmingUnderWater then
            functions.SetPlayerSubmixEffect(nil, serverId, playerData)
        end
    end

    --Vehicle effect
    if config.effects.vehicleInside.active then
        local inVehicle <const> = IsPedInAnyVehicle(playerPed)
        local playerVehicle <const> = inVehicle and GetVehiclePedIsIn(playerPed) or false

        local canActiveVehicleSubmix <const> = not talkingRadioPlayers[playerData.serverId] and (inVehicle or clientPlayerInVehicle) and functions.CheckVehicle(inVehicle and playerVehicle or clientPlayerVehicle) and (playerVehicle ~= clientPlayerVehicle)
        if not isSubmixActive and canActiveVehicleSubmix then
            functions.SetPlayerSubmixEffect(config.effects.vehicleInside.name, serverId, playerData)
        elseif isSubmixActive == config.effects.vehicleInside.name and not canActiveVehicleSubmix then
            functions.SetPlayerSubmixEffect(nil, serverId, playerData)
        end
    end
end

function functions.CheckVehicle(vehicle)
    local vehicleClass <const> = GetVehicleClass(vehicle)
    local disableClass <const> = { 13, 14, 8 }
    for i = 1, #disableClass do
        if disableClass[i] == vehicleClass then
            return false
        end
    end

    if IsVehicleAConvertible(vehicle, false) and GetConvertibleRoofState(vehicle) ~= 0 then
        return false
    end

    if not DoesVehicleHaveRoof(vehicle) then
        return false
    end

    for i = 0, 3 do
        if GetVehicleDoorAngleRatio(vehicle, i) > 0.2 then
            return false
        end
    end

    for i = 0, 7 do
        if not IsVehicleWindowIntact(vehicle, i) then
            return false
        end
    end
    return true
end

function functions.SetTalkingOnRadio(serverId, enabled, playerCoords)
    Wait(100) -- a small waiting time to overwrite pma's effect
    if not enabled then
        MumbleSetVolumeOverrideByServerId(serverId, -1.0)
        talkingRadioPlayers[serverId] = nil
        return
    end

    talkingRadioPlayers[serverId] = true
    local dist <const> = #(playerCoords - GetEntityCoords(PlayerPedId()))
    local count <const> = #config.radioDistance

    MumbleSetVolumeOverrideByServerId(serverId, LocalPlayer.state.radio or 1.0)
    for i = 1, count do
        if dist < config.radioDistance[i].dist then
            return functions.SetPlayerSubmixEffect(config.radioDistance[i].effect, serverId)
        end
    end

    functions.SetPlayerSubmixEffect(config.radioDistance[count].effect, serverId)
end

return functions
