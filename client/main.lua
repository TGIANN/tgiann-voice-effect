local functions <const>            = require "client.functions"
local config <const>               = require "config"
local clientPlayerServerId <const> = GetPlayerServerId(PlayerId())
local talkingPlayerList            = {}
local localPlayerIsTalking         = false

CreateThread(function()
    functions.CreateAudioSubmix(config.underWaterTalking)
    functions.SetAudioSubmixEffect(config.underWaterTalking.name, config.underWaterTalking.effects)

    functions.CreateAudioSubmix(config.underWaterHear)
    functions.SetAudioSubmixEffect(config.underWaterHear.name, config.underWaterHear.effects)
    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)

    local underWaterSubmixActive = false
    while true do
        Wait(100)
        for _, playerData in pairs(talkingPlayerList) do
            if NetworkIsPlayerActive(playerData.playerId) then
                functions.DetectPlayerSubmix(playerData)
            end
        end

        local talking = NetworkIsPlayerTalking(PlayerId())
        if not localPlayerIsTalking and talking then
            localPlayerIsTalking = true
            TriggerServerEvent("tgiann-voice:setIsTalking", talking)
        elseif localPlayerIsTalking and not talking then
            localPlayerIsTalking = false
            TriggerServerEvent("tgiann-voice:setIsTalking", talking)
        end

        local isPedSwimmingUnderWater <const> = IsPedSwimmingUnderWater(PlayerPedId())
        if not underWaterSubmixActive and isPedSwimmingUnderWater then
            underWaterSubmixActive = true
            SetAudioSubmixEffectParamInt(0, 0, `enabled`, 1)
        elseif underWaterSubmixActive and not isPedSwimmingUnderWater then
            underWaterSubmixActive = false
            SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
        end
    end
end)

-- NetworkIsPlayerTalking native sometimes returns false even though the player is talking. so we check it with state bag
AddStateBagChangeHandler("isTalking", nil, function(bagName, key, value)
    local player <const> = GetPlayerFromStateBagName(bagName)
    if player == PlayerId() then return end
    if value then
        local serverId <const> = GetPlayerServerId(player)
        talkingPlayerList["p_" .. player] = {
            playerId = player,
            serverId = serverId,
        }
        functions.DetectPlayerSubmix(talkingPlayerList["p_" .. player])
    elseif talkingPlayerList["p_" .. player] then
        if talkingPlayerList["p_" .. player].activeSubmix then
            functions.SetPlayerSubmixEffect(false, GetPlayerServerId(player))
        end
        talkingPlayerList["p_" .. player] = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    MumbleSetSubmixForServerId(clientPlayerServerId, -1)
    MumbleSetVolumeOverrideByServerId(clientPlayerServerId, -1.0)
    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
end)
