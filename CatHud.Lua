local KeyFileName = "CatHub_SavedKey.txt"
local CorrectKey = "ScriptTodday"

function loadMainScript()
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local player = Players.LocalPlayer

    local config = {
        speed = 450,
        isTweening = false,
        heightOffset = 4.5,
        instantTake = true,
        unlimitedZoom = false
    }

    -- ==========================================
    -- FIX CELESTIAL LABEL CHO MOBILE
    -- ==========================================
    local function setupCelestialTimer(labelObj)
        task.spawn(function()
            while task.wait(1) do -- Mobile nên để 1s để tránh lag
                pcall(function()
                    local modelFolder = Workspace:FindFirstChild("Model")
                    if modelFolder then
                        -- Thay vì dùng [15], ta quét toàn bộ để tìm cái có SurfaceGui
                        -- Điều này giúp Mobile tìm đúng vật thể dù thứ tự bị đảo lộn
                        for _, child in ipairs(modelFolder:GetChildren()) do
                            local sGui = child:FindFirstChild("SurfaceGui")
                            if sGui and sGui:FindFirstChild("Frame") and sGui.Frame:FindFirstChild("TextLabel") then
                                local textLabel = sGui.Frame.TextLabel
                                -- Chỉ lấy nếu ContentText có chứa số hoặc chữ liên quan đến thời gian
                                if textLabel.ContentText ~= "" then
                                    labelObj:Set("Celestial: " .. textLabel.ContentText)
                                    break 
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end

    -- ==========================================
    -- NOCLIP & ANTI-FALL (GIỮ NGUYÊN)
    -- ==========================================
    RunService.Stepped:Connect(function()
        if config.isTweening and player.Character then
            for _, p in ipairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)

    -- ==========================================
    -- LOGIC TELEPORT & CHỐNG TÉ (MOBILE OPTIMIZED)
    -- ==========================================
    local function GetGapCenter(i)
        local gaps = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Gaps")
        if not gaps then return nil end
        local gap = gaps:FindFirstChild("Gap"..i)
        if not gap then return nil end
        local biggestPart = nil
        local maxVolume = 0
        for _, p in ipairs(gap:GetDescendants()) do
            if p:IsA("BasePart") then
                local volume = p.Size.X * p.Size.Y * p.Size.Z
                if volume > maxVolume then maxVolume = volume; biggestPart = p end
            end
        end
        return biggestPart
    end

    local function ForcedCenterTP(targetPart)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or not targetPart or config.isTweening then return end

        config.isTweening = true
        local bp = Instance.new("BodyPosition", root)
        bp.MaxForce = Vector3.new(1, 1, 1) * 1e7
        bp.P = 20000
        bp.D = 200
        
        local bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1, 1, 1) * 1e7
        bg.P = 20000
        bg.CFrame = root.CFrame

        local targetPos = targetPart.Position + Vector3.new(0, config.heightOffset, 0)
        bp.Position = root.Position

        local tween = TweenService:Create(bp, TweenInfo.new((targetPos - root.Position).Magnitude / config.speed, Enum.EasingStyle.Linear), {Position = targetPos})
        tween:Play()
        
        tween.Completed:Connect(function()
            task.wait(0.2)
            bp:Destroy()
            bg:Destroy()
            config.isTweening = false 
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end

    -- ==========================================
    -- GIAO DIỆN (TAB CHÍNH HIỆN ĐẦU TIÊN)
    -- ==========================================
    local Win = Rayfield:CreateWindow({
        Name = "CAT HUB | FreeMium",
        LoadingTitle = "Đang cấu hình giao diện.....",
        ConfigurationSaving = {Enabled = false}
    })

    -- Đưa Tab MAIN lên đầu để Mobile dễ nhấn
    local MudTab = Win:CreateTab("MAIN", 4483362458)
    local MainTab = Win:CreateTab("Mics", 4483362458)

    -- Label hiển thị thời gian (Fix cho Mobile)
    local CelestialLabel = MudTab:CreateLabel("Celestial: Đang tìm bảng thời gian...")
    setupCelestialTimer(CelestialLabel)

    MudTab:CreateSlider({
        Name = "Tốc độ",
        Range = {100, 1500}, Increment = 50, CurrentValue = 450,
        Callback = function(v) config.speed = v end
    })

    MudTab:CreateButton({Name = "⬆️(UP)", Callback = function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local closest, minDist = 1, math.huge
        for i = 1, 9 do
            local m = GetGapCenter(i)
            if m then
                local d = (root.Position - m.Position).Magnitude
                if d < minDist then minDist = d; closest = i end
            end
        end
        if closest < 9 then ForcedCenterTP(GetGapCenter(closest + 1)) end
    end})

    MudTab:CreateButton({Name = "⬇️(DOWN)", Callback = function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local closest, minDist = 1, math.huge
        for i = 1, 9 do
            local m = GetGapCenter(i)
            if m then
                local d = (root.Position - m.Position).Magnitude
                if d < minDist then minDist = d; closest = i end
            end
        end
        if closest > 1 then ForcedCenterTP(GetGapCenter(closest - 1)) end
    end})

    MainTab:CreateToggle({
        Name = "Unlimited Zoom",
        CurrentValue = false,
        Callback = function(v) 
            player.CameraMaxZoomDistance = v and 10000 or 35
        end
    })

    MainTab:CreateToggle({
        Name = "Instant Take",
        CurrentValue = true,
        Callback = function(v) config.instantTake = v end
    })

    -- Khởi tạo Instant Take
    local function initInstantTake()
        local root = Workspace:FindFirstChild("ActiveBrainrots")
        if not root then return end
        root.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") and config.instantTake then
                task.wait()
                desc.HoldDuration = 0
            end
        end)
        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
    end
    initInstantTake()
end

-- KEY SYSTEM
if isfile(KeyFileName) and readfile(KeyFileName) == CorrectKey then
    loadMainScript()
else
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    local Win = Rayfield:CreateWindow({Name = "CAT HUB | VERIFY"})
    local Tab = Win:CreateTab("Verify", 4483362458)
    Tab:CreateInput({
        Name = "Nhập Key",
        Callback = function(t)
            if t == CorrectKey then
                writefile(KeyFileName, t)
                Rayfield:Destroy()
                loadMainScript()
            end
        end
    })
end
