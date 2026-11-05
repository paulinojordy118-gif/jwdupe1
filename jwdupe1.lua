-- ==========================================
-- JW DUPLICATOR HUB (CLIENT-SIDE EXECUTION)
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. DETERMINAR DÓNDE GUARDAR LA GUI
local parentGui = CoreGui
local success, _ = pcall(function() local test = CoreGui.Name end)
if not success then
    parentGui = PlayerGui
end

-- Limpiar interfaz anterior si existe
if parentGui:FindFirstChild("JW_DupeHub") then
    parentGui.JW_DupeHub:Destroy()
end

-- 2. CREACIÓN DE LA INTERFAZ BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JW_DupeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Botón principal cuadrado "JW"
local JWBtn = Instance.new("TextButton")
JWBtn.Name = "JWButton"
JWBtn.Size = UDim2.new(0, 50, 0, 50)
JWBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
JWBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
JWBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
JWBtn.Text = "JW"
JWBtn.TextSize = 22
JWBtn.Font = Enum.Font.SourceSansBold
JWBtn.BorderSizePixel = 2
JWBtn.BorderColor3 = Color3.fromRGB(0, 170, 255)
JWBtn.Active = true
JWBtn.Draggable = true -- Permite arrastrar el botón en pantalla
JWBtn.Parent = ScreenGui

-- Ventana principal de duplicación
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 240)
MainFrame.Position = UDim2.new(0.02, 60, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Título del menú
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "JW DUPLICATOR HUB"
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Contenedor scrolleable para mostrar la lista de unidades detectadas
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.9, 0, 0.5, 0)
ScrollList.Position = UDim2.new(0.05, 0, 0.16, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollList.BorderColor3 = Color3.fromRGB(50, 50, 50)
ScrollList.ScrollBarThickness = 6
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- Botón para duplicar
local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(0.9, 0, 0.16, 0)
DupeBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
DupeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
DupeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DupeBtn.Text = "Duplicate JW"
DupeBtn.TextSize = 15
DupeBtn.Font = Enum.Font.SourceSansBold
DupeBtn.Parent = MainFrame

-- Label de estado (muestra qué unidad se seleccionó)
local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
SelectedLabel.Position = UDim2.new(0.05, 0, 0.68, 0)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SelectedLabel.Text = "Selecciona una unidad..."
SelectedLabel.TextSize = 12
SelectedLabel.Font = Enum.Font.SourceSans
SelectedLabel.Parent = MainFrame

-- 3. DETECCIÓN AUTOMÁTICA DEL INVENTARIO Y SELECCIÓN
local unidadSeleccionADA = nil

-- Función para buscar las carpetas donde los juegos suelen almacenar las unidades del usuario
local function obtenerInventarioJugador()
    return LocalPlayer:FindFirstChild("Units") 
        or LocalPlayer:FindFirstChild("Inventory") 
        or LocalPlayer:FindFirstChild("Backpack")
        or LocalPlayer:FindFirstChild("EquippedUnits")
end

local function cargarUnidadesEnLista()
    -- Limpiar lista anterior
    for _, item in ipairs(ScrollList:GetChildren()) do
        if item:IsA("TextButton") then
            item:Destroy()
        end
    end

    local inv = obtenerInventarioJugador()
    local unidadesEncontradas = {}

    if inv then
        for _, item in ipairs(inv:GetChildren()) do
            table.insert(unidadesEncontradas, item.Name)
        end
    end

    -- También revisa dentro del Character si las tiene equipadas
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") and not table.find(unidadesEncontradas, item.Name) then
                table.insert(unidadesEncontradas, item.Name)
            end
        end
    end

    -- Si no encuentra carpetas por defecto, escanea en ReplicatedStorage por carpetas de datos del usuario
    if #unidadesEncontradas == 0 then
        local pData = ReplicatedStorage:FindFirstChild("PlayerData") or ReplicatedStorage:FindFirstChild("Profiles")
        if pData and pData:FindFirstChild(LocalPlayer.Name) then
            local uFolder = pData[LocalPlayer.Name]:FindFirstChild("Units") or pData[LocalPlayer.Name]:FindFirstChild("Inventory")
            if uFolder then
                for _, item in ipairs(uFolder:GetChildren()) do
                    table.insert(unidadesEncontradas, item.Name)
                end
            end
        end
    end

    -- Generar botones en la lista por cada unidad detectada
    for _, nombreUnidad in ipairs(unidadesEncontradas) do
        local btnUnidad = Instance.new("TextButton")
        btnUnidad.Size = UDim2.new(1, -6, 0, 25)
        btnUnidad.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btnUnidad.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnUnidad.Text = tostring(nombreUnidad)
        btnUnidad.TextSize = 12
        btnUnidad.Font = Enum.Font.SourceSans
        btnUnidad.Parent = ScrollList

        btnUnidad.MouseButton1Click:Connect(function()
            unidadSeleccionADA = nombreUnidad
            SelectedLabel.Text = "Seleccionado: " .. nombreUnidad
            SelectedLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        end)
    end
    
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, #unidadesEncontradas * 29)
end

-- 4. CONEXIONES Y ACCIONES DEL MENÚ

-- Mostrar / Ocultar panel con el botón JW
JWBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        cargarUnidadesEnLista()
    end
end)

-- Acción al hacer clic en "Duplicate JW"
DupeBtn.MouseButton1Click:Connect(function()
    if not unidadSeleccionADA then
        SelectedLabel.Text = "¡Primero selecciona una unidad!"
        SelectedLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        return
    end

    -- Intentar enviar señal por RemoteEvents del juego o duplicar localmente si el objeto existe
    local remote = ReplicatedStorage:FindFirstChild("DuplicateUnitRemote") 
        or ReplicatedStorage:FindFirstChild("SpawnUnit") 
        or ReplicatedStorage:FindFirstChild("EquipUnit")

    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(unidadSeleccionADA)
        SelectedLabel.Text = "Petici\195\179n enviada: " .. unidadSeleccionADA
    else
        -- Duplicado directo en Backpack/Units si se permite clonar la instancia
        local inv = obtenerInventarioJugador()
        if inv then
            local target = inv:FindFirstChild(unidadSeleccionADA) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(unidadSeleccionADA))
            if target then
                local clone = target:Clone()
                clone.Parent = inv
                SelectedLabel.Text = "Duplicado: " .. unidadSeleccionADA
            else
                SelectedLabel.Text = "Error al clonar instancia"
            end
        end
    end
end)

print("[JW DUPE] Script cargado e iniciado correctamente.")
