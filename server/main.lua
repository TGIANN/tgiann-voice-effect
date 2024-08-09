local config <const> = require "config"
require "server.versionCheck"

RegisterNetEvent('tgiann-voice:setIsTalking', function(bool)
    local playerState = Player(source).state
    playerState.isTalking = bool
end)

if config.effects.radioDefault.active then
    local function setTalkingOnRadio(talking)
        local src <const> = source
        local plyState <const> = Player(src).state
        local radioChannel <const> = plyState.radioChannel
        local players <const> = exports['pma-voice']:getPlayersInRadioChannel(radioChannel)
        local playerCoords <const> = GetEntityCoords(GetPlayerPed(src))

        for player, _ in pairs(players) do
            if player ~= src then
                TriggerClientEvent('tgiann-voice:setTalkingOnRadio', player, src, talking, playerCoords)
            end
        end
    end
    RegisterNetEvent('pma-voice:setTalkingOnRadio', setTalkingOnRadio)
end
