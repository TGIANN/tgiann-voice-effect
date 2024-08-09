local updatePath <const> = "/TGIANN/tgiann-voice-effect"
local resourceName <const> = GetCurrentResourceName()

local function infoHandle(msg, color)
    if color == "green" then
        color = 2
    elseif color == "red" then
        color = 1
    elseif color == "blue" then
        color = 4
    else
        color = 3
    end
    print(("^3%s^7: ^%s%s^7"):format(resourceName, color, msg))
end

local function checkVersion(_, latestVersion, _)
    local currentVersion <const> = LoadResourceFile(resourceName, "version")

    if not latestVersion then
        return infoHandle("An error occurred while trying to get the current version!")
    end

    if latestVersion ~= currentVersion then
        infoHandle(("currentVersion: %s"):format(latestVersion), "green")
        infoHandle(("Your version: %s"):format(currentVersion), "blue")
        infoHandle("You need download latest version! You are using an old version at the moment!", "red")
    end
end

PerformHttpRequest(("https://raw.githubusercontent.com%s/master/version"):format(updatePath), checkVersion, "GET")
