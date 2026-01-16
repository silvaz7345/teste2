-- MAGNET BLOCKS FIX (Executor Friendly)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MagnetFix"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "MAGNET BLOCKS FIX"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.85,0,0,40)
btn.Position = UDim2.new(0.075,0,0.45,0)
btn.Text = "ATIVAR"
btn.Font = Enum.Font.Gotham
btn.TextSize = 14
btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
btn.TextColor3 = Color3.new(1,1,1)

-- CONFIG
local magnet = false
local height = 7
local spacing = 3
local blocks = {}

-- Pegar blocos soltos
local function getBlocks()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart")
        and not v.Anchored
        and not v:IsDescendantOf(character)
        and v.Size.Magnitude < 50 then
            table.insert(list, v)
        end
    end
    return list
end

-- Controlar bloco
local function controlBlock(part, index)
    if blocks[part] then return end
    blocks[part] = true

    pcall(function()
        part:SetNetworkOwner(player)
    end)

    part.CanCollide = false
    part.Massless = true
    part.AssemblyLinearVelocity = Vector3.zero

    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e9,1e9,1e9)
    bp.P = 5000
    bp.D = 200
    bp.Parent = part

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.P = 3000
    bg.Parent = part

    RunService.Heartbeat:Connect(function()
        if not magnet or not part.Parent then
            bp:Destroy()
            bg:Destroy()
            blocks[part] = nil
            return
        end

        bp.Position = hrp.Position + Vector3.new(0, height + (index * spacing), 0)
        bg.CFrame = CFrame.new(part.Position)
    end)
end

-- Loop
task.spawn(function()
    while task.wait(1) do
        if magnet then
            local list = getBlocks()
            for i, part in ipairs(list) do
                controlBlock(part, i)
            end
        end
    end
end)

-- Botão
btn.MouseButton1Click:Connect(function()
    magnet = not magnet
    btn.Text = magnet and "DESATIVAR" or "ATIVAR"

    if not magnet then
        for part in pairs(blocks) do
            if part and part.Parent then
                part.CanCollide = true
            end
        end
        blocks = {}
    end
end)
