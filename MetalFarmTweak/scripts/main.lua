local ModName = "MetalFarmTweak"
local LIB_ROOT = "./ue4ss/Mods/SN2ModSettings/"
local MANIFEST_PATH = LIB_ROOT .. "registrations/" .. ModName .. ".lua"
local SAVED_PATH = LIB_ROOT .. "saved/" .. ModName .. ".lua"

local function log(msg)
    print(string.format("[%s] %s\n", ModName, msg))
end

local VanillaDefaults = {
    Troilite = 1200.0,
    Gold = 600.0,
    Atacamite = 600.0,
    ConduitCrystal = 1200.0,
    Silver = 600.0,
    Titanium = 600.0,
    Copper = 600.0,
    Quartz = 600.0,
    Salt = 600.0,
    Sulfur = 600.0,
    Lithium = 600.0,
    Celestine = 600.0,
    Enamel = 600.0,
}

local Config = {
    Enabled = true,
    Troilite = 1200.0,
    Gold = 600.0,
    Atacamite = 600.0,
    ConduitCrystal = 1200.0,
    Silver = 600.0,
    Titanium = 600.0,
    Copper = 600.0,
    Quartz = 600.0,
    Salt = 600.0,
    Sulfur = 600.0,
    Lithium = 600.0,
    Celestine = 600.0,
    Enamel = 600.0,
}

local boosted = {}

-- ── Settings integration ──

local function mkdir(path)
    os.execute('mkdir "' .. path:gsub("/", "\\") .. '" 2>nul')
end

local function write_text(path, body)
    mkdir(path:match("(.*[/\\])"))
    local f = io.open(path, "w")
    if not f then return false end
    f:write(body)
    f:close()
    return true
end

local function read_lua_table(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*all")
    f:close()
    if not content or content == "" then return nil end
    local loader = load(content)
    if not loader then return nil end
    local ok, data = pcall(loader)
    return ok and data or nil
end

local function WriteManifest()
    local content = [=[
return {
    name     = "MetalFarmTweak",
    display  = "Metal Farm Tweak",
    version  = "1.0.0",
    settings = {
        { key="Enabled", title="Enable Metal Farm Tweak",
          description="Master switch. When off, all farms use vanilla ripen times.",
          type="toggle", default=true },
        { key="Troilite", title="Troilite (sec)",
          description="Ripen time in seconds for Troilite. Vanilla: 1200",
          type="slider", default=1200.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Gold", title="Gold (sec)",
          description="Ripen time in seconds for Gold. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Silver", title="Silver (sec)",
          description="Ripen time in seconds for Silver. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Titanium", title="Titanium (sec)",
          description="Ripen time in seconds for Titanium. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Copper", title="Copper (sec)",
          description="Ripen time in seconds for Copper. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Atacamite", title="Atacamite (sec)",
          description="Ripen time in seconds for Atacamite. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="ConduitCrystal", title="Conduit Crystal (sec)",
          description="Ripen time in seconds for Conduit Crystal. Vanilla: 1200",
          type="slider", default=1200.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Quartz", title="Quartz (sec)",
          description="Ripen time in seconds for Quartz. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Salt", title="Salt (sec)",
          description="Ripen time in seconds for Salt. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Sulfur", title="Sulfur (sec)",
          description="Ripen time in seconds for Sulfur. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Lithium", title="Lithium (sec)",
          description="Ripen time in seconds for Lithium. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Celestine", title="Celestine (sec)",
          description="Ripen time in seconds for Celestine. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
        { key="Enamel", title="Creature Enamel (sec)",
          description="Ripen time in seconds for Creature Enamel. Vanilla: 600",
          type="slider", default=600.0, min=10.0, max=1800.0, step=10.0, format="integer",
          enabled_by="Enabled" },
    },
}
]=]
    if write_text(MANIFEST_PATH, content) then
        log("Manifest written")
    else
        log("Failed to write manifest (is SN2ModSettings installed?)")
    end
end

local function LoadSavedConfig()
    local changed = false
    local got_any_shared = false

    if ModRef then
        for k, _ in pairs(Config) do
            local v = ModRef:GetSharedVariable("SN2ModSettings/" .. ModName .. "/" .. k)
            if v ~= nil then
                got_any_shared = true
                if type(v) == type(Config[k]) and Config[k] ~= v then
                    Config[k] = v
                    changed = true
                end
            end
        end
    end

    if not got_any_shared then
        local saved = read_lua_table(SAVED_PATH)
        if not saved then return changed end
        for k, v in pairs(saved) do
            if Config[k] ~= nil and type(v) == type(Config[k]) and Config[k] ~= v then
                Config[k] = v
                changed = true
            end
        end
    end

    return changed
end

local function GetResourceName(farm)
    local itemType = farm.CurrentItemType
    if not itemType or not itemType:IsValid() then return nil end
    local fullName = itemType:GetFullName()
    return fullName:match("DA_(%w+)_ItemType")
end

local function GetRipenTime(resourceName)
    if not resourceName then return nil end
    if not VanillaDefaults[resourceName] then return nil end
    if not Config.Enabled then
        return VanillaDefaults[resourceName]
    end
    return Config[resourceName] or VanillaDefaults[resourceName]
end

local function TweakAllFarms()
    local farms = FindAllOf("SN2MetalFarm")
    if not farms then return end

    for _, farm in ipairs(farms) do
        if farm and farm:IsValid() then
            local resourceName = GetResourceName(farm)
            if resourceName then
                local ripenTime = GetRipenTime(resourceName)
                if ripenTime then
                    local growers = farm.SeedGrowerComponents
                    if growers then
                        for i = 1, #growers do
                            local grower = growers[i]
                            if grower and grower:IsValid() then
                                local id = tostring(grower) .. resourceName
                                if not boosted[id] then
                                    local oldTime = grower.RipenTime
                                    grower.RipenTime = ripenTime
                                    boosted[id] = true
                                    log(string.format("%s: %f -> %f", resourceName, oldTime, ripenTime))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


WriteManifest()
LoadSavedConfig()

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    boosted = {}
    ExecuteWithDelay(3000, function()
        TweakAllFarms()
    end)
end)

NotifyOnNewObject("/Game/Blueprints/Farming/BP_MetalFarm.BP_MetalFarm_C", function(NewObject)
    ExecuteWithDelay(1000, function()
        TweakAllFarms()
    end)
end)

NotifyOnNewObject("/Game/Blueprints/World/ResourceDeposits/BP_Resource_MetalFarmSeed.BP_Resource_MetalFarmSeed_C", function(NewObject)
    boosted = {}
    ExecuteWithDelay(100, function()
        TweakAllFarms()
    end)
end)

LoopAsync(1000, function()
    if not ModRef then return end

    local changed = false
    for k, _ in pairs(Config) do
        local v = ModRef:GetSharedVariable("SN2ModSettings/" .. ModName .. "/" .. k)
        if v ~= nil and type(v) == type(Config[k]) and Config[k] ~= v then
            changed = true
            break
        end
    end
    if not changed then return end

    ExecuteInGameThread(function()
        local ok, err = pcall(function()
            if LoadSavedConfig() then
                log("Config changed via UI - reapplying")
                boosted = {}
                TweakAllFarms()
            end
        end)
        if not ok then log("Config poll error: " .. tostring(err)) end
    end)
end)