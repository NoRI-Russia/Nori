local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local walkSpeed = 16
local keepSpeedOnRespawn = true
local particlesOn = true
local guiActive = false
local minimized = false
local busy = false
local defaultFov = (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70
local fovValue = defaultFov
local fovCustom = false
local stretchOn = false
local stretchValue = 0.75
local viewBindName = "NoRIView" .. tostring(os.clock())

local C = {
    Black = Color3.fromRGB(4, 2, 7),
    Background = Color3.fromRGB(15, 7, 20),
    Panel = Color3.fromRGB(32, 15, 38),
    PanelLight = Color3.fromRGB(54, 28, 62),
    BloodDark = Color3.fromRGB(122, 50, 8),
    Blood = Color3.fromRGB(205, 88, 10),
    Ember = Color3.fromRGB(255, 130, 26),
    Silver = Color3.fromRGB(240, 226, 200),
    Steel = Color3.fromRGB(184, 162, 176),
    Gray = Color3.fromRGB(165, 132, 154),
    White = Color3.fromRGB(255, 247, 232),
}

local CORRECT_PASSWORD = "NoRIs"
local MAX_ATTEMPTS = 3
local LOCK_DURATION = 180
local attemptsLeft = MAX_ATTEMPTS
local lockedUntil = 0
local authorized = _G.NoRIAuthorized == true

local translations = {
    en = {
        author = "By Rodion",
        tab_speed = "Speed",
        tab_settings = "Settings",
        tab_info = "Info",
        tab_cheat = "Cheats",
        sec_movement = "MOVEMENT",
        sec_options = "OPTIONS",
        sec_interface = "INTERFACE",
        sec_language = "LANGUAGE",
        sec_about = "ABOUT",
        sec_cheat_movement = "CHEAT MOVEMENT",
        sec_visual = "VISUAL",
        sec_aimbot = "AIMBOT",
        walkspeed = "WalkSpeed",
        reset = "RESET (16)",
        keep_speed = "Keep speed after respawn",
        embers = "Embers",
        window_size = "Window size",
        hotkey_title = "Hotkey",
        hotkey_body = "Press K to show or hide the menu. Drag the top bar to move the window.",
        info_title = "BETA GPT",
        info_body = "Version 1.0\nAuthor: Rodion  •  NoRI Scripts",
        key_subtitle = "Key system  •  NoRI Scripts",
        key_hint = "Enter access key",
        key_placeholder = "Key...",
        confirm = "CONFIRM",
        attempts_left = "Attempts left: %d",
        key_note = "Three wrong keys lock input for 180 sec.",
        retry_in = "Retry in %d sec.",
        access_status = "ACCESS GRANTED",
        locked = "Locked for 180 sec.",
        wrong_key = "Wrong key! Attempts left: %d",
        attempts_restored = "Attempts restored: 3",
        granted_title = "Access granted",
        granted_body = "Welcome to BETA GPT",
        error_title = "Error",
        error_body = "Wrong key. Attempts left: %d",
        speed_title = "Speed",
        speed_body = "Reset to 16",
        lang_title = "Language",
        lang_body = "English",
        loading = "LOADING",
        tab_view = "View",
        sec_camera = "CAMERA",
        fov = "Field of view",
        fov_reset = "RESET FOV",
        stretch = "Stretched screen 4:3",
        stretch_amount = "Stretch amount",
        noclip = "Noclip",
        fly = "Fly",
        fly_speed = "Fly speed",
        esp = "ESP (players)",
        fullbright = "Fullbright",
        aimbot = "Aimbot",
        aimbot_fov = "Aimbot FOV",
        aimbot_smooth = "Aimbot smooth",
        crosshair = "Crosshair",
        tab_combat = "Combat",
        tab_visual = "Visual",
        tab_move = "Movement",
        sec_aimbot_settings = "AIMBOT SETTINGS",
        wall_check = "Wall Check",
        silent_aim = "Silent Aim (RISK)",
        sec_visual_extras = "VISUAL EXTRAS",
        tracer = "Tracer ESP",
        name_esp = "Name ESP",
        fullbright_brightness = "Fullbright Brightness",
        part_head = "Head",
        part_body = "Body",
        sec_hitbox = "HITBOX",
        hitbox = "Hitbox Expander",
        hitbox_size = "Hitbox Size",
        sec_freecam = "FREECAM",
        freecam = "Freecam (WASD + QE)",
        freecam_speed = "Freecam Speed",
        sec_god = "GOD MODE (Client)",
        god = "God Mode (try)",
    },
    ru = {
        author = "От Родиона",
        tab_speed = "Скорость",
        tab_settings = "Настройки",
        tab_info = "Инфо",
        tab_cheat = "Читы",
        sec_movement = "ДВИЖЕНИЕ",
        sec_options = "ПАРАМЕТРЫ",
        sec_interface = "ИНТЕРФЕЙС",
        sec_language = "ЯЗЫК",
        sec_about = "О СКРИПТЕ",
        sec_cheat_movement = "ЧИТ-ДВИЖЕНИЕ",
        sec_visual = "ВИЗУАЛ",
        sec_aimbot = "АИМБОТ",
        walkspeed = "Скорость ходьбы",
        reset = "СБРОСИТЬ (16)",
        keep_speed = "Сохранять после респавна",
        embers = "Искры",
        window_size = "Размер окна",
        hotkey_title = "Горячая клавиша",
        hotkey_body = "Нажми K, чтобы показать или скрыть меню. Окно можно перетаскивать за верхнюю панель.",
        info_title = "BETA GPT",
        info_body = "Версия 1.0\nАвтор: Родион  •  NoRI Scripts",
        key_subtitle = "Система ключа  •  NoRI Scripts",
        key_hint = "Введи ключ доступа",
        key_placeholder = "Ключ...",
        confirm = "ПОДТВЕРДИТЬ",
        attempts_left = "Осталось попыток: %d",
        key_note = "Три ошибки подряд блокируют ввод на 180 сек.",
        retry_in = "Повтор через %d сек.",
        access_status = "ДОСТУП РАЗРЕШЁН",
        locked = "Заблокировано на 180 сек.",
        wrong_key = "Неверный ключ! Осталось: %d",
        attempts_restored = "Попытки восстановлены: 3",
        granted_title = "Доступ разрешён",
        granted_body = "Добро пожаловать в BETA GPT",
        error_title = "Ошибка",
        error_body = "Неверный ключ. Осталось попыток: %d",
        speed_title = "Скорость",
        speed_body = "Сброшена до 16",
        lang_title = "Язык",
        lang_body = "Русский",
        loading = "ЗАГРУЗКА",
        tab_view = "Вид",
        sec_camera = "КАМЕРА",
        fov = "Угол обзора",
        fov_reset = "СБРОСИТЬ FOV",
        stretch = "Растянутый экран 4:3",
        stretch_amount = "Степень растяжения",
        noclip = "Ноклип",
        fly = "Полёт",
        fly_speed = "Скорость полёта",
        esp = "ESP (игроки)",
        fullbright = "Полная яркость",
        aimbot = "Аимбот",
        aimbot_fov = "Радиус аимбота",
        aimbot_smooth = "Плавность аимбота",
        crosshair = "Прицел",
        tab_combat = "Бой",
        tab_visual = "Визуал",
        tab_move = "Движение",
        sec_aimbot_settings = "НАСТРОЙКИ АИМБОТА",
        wall_check = "Проверка стен",
        silent_aim = "Silent Aim (РИСК)",
        sec_visual_extras = "ДОП. ВИЗУАЛ",
        tracer = "Трассеры",
        name_esp = "Имена игроков",
        fullbright_brightness = "Яркость Fullbright",
        part_head = "Голова",
        part_body = "Тело",
        sec_hitbox = "ХИТБОКС",
        hitbox = "Увеличение хитбоксов",
        hitbox_size = "Размер хитбокса",
        sec_freecam = "ФРИКАМ",
        freecam = "Фрикам (WASD + QE)",
        freecam_speed = "Скорость фрикама",
        sec_god = "БЕССМЕРТИЕ (клиент)",
        god = "Бессмертие (попытка)",
    },
}

local lang = (_G.NoRILanguage == "ru") and "ru" or "en"
local bindings = {}
local statusState = {key = "attempts_left", color = C.Gray, arg = MAX_ATTEMPTS}
local AuthStatus
local langButton
local setLanguage

local function T(key)
    local set = translations[lang]
    return set[key] or translations.en[key] or key
end

local function bind(obj, key, prop)
    local entry = {obj = obj, key = key, prop = prop or "Text"}
    table.insert(bindings, entry)
    obj[entry.prop] = T(key)
end

local function renderStatus()
    if not AuthStatus or not AuthStatus.Parent then return end
    AuthStatus.Text = string.format(T(statusState.key), statusState.arg)
    AuthStatus.TextColor3 = statusState.color
end

local function setStatus(key, color, arg)
    statusState = {key = key, color = color, arg = arg}
    renderStatus()
end

local oldGui = PlayerGui:FindFirstChild("NoRIUI")
if oldGui then oldGui:Destroy() end
local oldCross = PlayerGui:FindFirstChild("NoRICrosshair")
if oldCross then oldCross:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoRIUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 20
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

ScreenGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.AutoLocalize = false
    end
end)

local function corner(parent, radius)
    local obj = Instance.new("UICorner")
    obj.CornerRadius = UDim.new(0, radius)
    obj.Parent = parent
    return obj
end

local function round(parent)
    local obj = Instance.new("UICorner")
    obj.CornerRadius = UDim.new(0.5, 0)
    obj.Parent = parent
    return obj
end

local function stroke(parent, color, thickness)
    local obj = Instance.new("UIStroke")
    obj.Color = color
    obj.Thickness = thickness
    obj.Parent = parent
    return obj
end

local function tween(obj, duration, properties)
    local animation = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function text(parent, name, str, size, position, font, color, textSize, align)
    local obj = Instance.new("TextLabel")
    obj.Name = name
    obj.Size = size
    obj.Position = position
    obj.BackgroundTransparency = 1
    obj.Text = str
    obj.TextColor3 = color
    obj.Font = font
    obj.TextSize = textSize
    obj.TextXAlignment = align or Enum.TextXAlignment.Left
    obj.Parent = parent
    return obj
end

local function padding(parent, left, right, top, bottom)
    local obj = Instance.new("UIPadding")
    obj.PaddingLeft = UDim.new(0, left or 0)
    obj.PaddingRight = UDim.new(0, right or 0)
    obj.PaddingTop = UDim.new(0, top or 0)
    obj.PaddingBottom = UDim.new(0, bottom or 0)
    obj.Parent = parent
    return obj
end

local function fadeLine(parent, position, size)
    local line = Instance.new("Frame")
    line.Size = size
    line.Position = position
    line.BackgroundColor3 = C.Ember
    line.BorderSizePixel = 0
    line.Parent = parent
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0.2),
        NumberSequenceKeypoint.new(0.8, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Parent = line
    return line
end

-- === FPS & PING OVERLAY ===
local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "NoRIOverlay"
overlayGui.ResetOnSpawn = false
overlayGui.IgnoreGuiInset = true
overlayGui.DisplayOrder = 100
overlayGui.Parent = PlayerGui

local overlayFrame = Instance.new("Frame")
overlayFrame.Name = "Overlay"
overlayFrame.AnchorPoint = Vector2.new(1, 0)
overlayFrame.Position = UDim2.new(1, -12, 0, 12)
overlayFrame.Size = UDim2.fromOffset(140, 50)
overlayFrame.BackgroundColor3 = C.Background
overlayFrame.BackgroundTransparency = 0.35
overlayFrame.BorderSizePixel = 0
overlayFrame.Parent = overlayGui
corner(overlayFrame, 8)
stroke(overlayFrame, C.BloodDark, 1.5)

local fpsLabel = text(overlayFrame, "FPS", "FPS: --", UDim2.new(1, -12, 0, 20), UDim2.new(0, 10, 0, 4),
    Enum.Font.GothamBold, C.Silver, 12)
local pingLabel = text(overlayFrame, "Ping", "Ping: --", UDim2.new(1, -12, 0, 20), UDim2.new(0, 10, 0, 24),
    Enum.Font.GothamBold, C.Steel, 12)

task.spawn(function()
    local frameCount = 0
    local lastTime = os.clock()
    while overlayGui.Parent do
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastTime >= 0.5 then
            local fps = math.floor(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now
            fpsLabel.Text = "FPS: " .. fps
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            pingLabel.Text = "Ping: " .. ping .. "ms"
        end
        RunService.RenderStepped:Wait()
    end
end)
-- === END OVERLAY ===

local userScale = 1
local scalers = {}

local function fitFor(w, h)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    return math.clamp(math.min(vp.X / (w + 30), vp.Y / (h + 30)), 0.5, 1)
end

local function registerScale(scaleObj, w, h, usesUser)
    table.insert(scalers, {s = scaleObj, w = w, h = h, u = usesUser})
    scaleObj.Scale = fitFor(w, h) * (usesUser and userScale or 1)
end

local function refreshScales()
    for _, e in ipairs(scalers) do
        if e.s.Parent then
            e.s.Scale = fitFor(e.w, e.h) * (e.u and userScale or 1)
        end
    end
end

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScales)
end

local spinners = {}

local function createSpinner(parent, size, position, zIndex, dots)
    local ringThickness = size >= 100 and 3 or 2

    local holder = Instance.new("Frame")
    holder.Name = "Spinner"
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = position
    holder.Size = UDim2.fromOffset(size, size)
    holder.BackgroundTransparency = 1
    holder.ZIndex = zIndex
    holder.Parent = parent

    local glow = Instance.new("Frame")
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.fromScale(0.5, 0.5)
    glow.Size = UDim2.fromScale(0.8, 0.8)
    glow.BackgroundColor3 = C.Blood
    glow.BackgroundTransparency = 0.65
    glow.BorderSizePixel = 0
    glow.ZIndex = zIndex
    glow.Parent = holder
    round(glow)

    local base = Instance.new("Frame")
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.Size = UDim2.fromScale(1, 1)
    base.BackgroundTransparency = 1
    base.ZIndex = zIndex + 1
    base.Parent = holder
    round(base)
    local baseStroke = stroke(base, C.BloodDark, ringThickness)
    baseStroke.Transparency = 0.2

    local arc = Instance.new("Frame")
    arc.AnchorPoint = Vector2.new(0.5, 0.5)
    arc.Position = UDim2.fromScale(0.5, 0.5)
    arc.Size = UDim2.fromScale(1, 1)
    arc.BackgroundTransparency = 1
    arc.ZIndex = zIndex + 2
    arc.Parent = holder
    round(arc)
    local arcStroke = stroke(arc, C.White, ringThickness + 1)
    local arcGradient = Instance.new("UIGradient")
    arcGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.White),
        ColorSequenceKeypoint.new(0.3, C.Ember),
        ColorSequenceKeypoint.new(1, C.Blood),
    })
    arcGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.35, 0.85),
        NumberSequenceKeypoint.new(0.36, 1),
        NumberSequenceKeypoint.new(1, 1),
    })
    arcGradient.Parent = arcStroke

    local orbit = nil
    if dots and dots > 0 then
        orbit = Instance.new("Frame")
        orbit.AnchorPoint = Vector2.new(0.5, 0.5)
        orbit.Position = UDim2.fromScale(0.5, 0.5)
        orbit.Size = UDim2.fromScale(0.78, 0.78)
        orbit.BackgroundTransparency = 1
        orbit.ZIndex = zIndex + 2
        orbit.Parent = holder
        for i = 1, dots do
            local angle = math.rad((i / dots) * 360)
            local d = math.max(2, math.floor(size * ((i % 2 == 0) and 0.04 or 0.027)))
            local dot = Instance.new("Frame")
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.Size = UDim2.fromOffset(d, d)
            dot.Position = UDim2.fromScale(0.5 + 0.5 * math.cos(angle), 0.5 + 0.5 * math.sin(angle))
            dot.BackgroundColor3 = (i % 2 == 0) and C.Silver or C.Ember
            dot.BackgroundTransparency = 0.15
            dot.BorderSizePixel = 0
            dot.ZIndex = zIndex + 2
            dot.Parent = orbit
            round(dot)
        end
    end
    local pw = size * 0.6
    local ph = size * 0.54
    local pumpkin = Instance.new("Frame")
    pumpkin.Name = "Pumpkin"
    pumpkin.AnchorPoint = Vector2.new(0.5, 0.5)
    pumpkin.Position = UDim2.new(0.5, 0, 0.55, 0)
    pumpkin.Size = UDim2.fromOffset(pw, ph)
    pumpkin.BackgroundTransparency = 1
    pumpkin.ZIndex = zIndex + 4
    pumpkin.Parent = holder

    local function part(parentFrame, x, y, w, h, color, z, radius)
        local f = Instance.new("Frame")
        f.Position = UDim2.fromScale(x, y)
        f.Size = UDim2.fromScale(w, h)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.ZIndex = zIndex + z
        f.Parent = parentFrame
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(radius or 0.5, 0)
        cr.Parent = f
        return f
    end

    local function outline(frame)
        local o = stroke(frame, Color3.fromRGB(110, 44, 6), 1)
        o.Transparency = 0.1
    end

    outline(part(pumpkin, 0.02, 0.14, 0.38, 0.82, Color3.fromRGB(196, 78, 8), 4))
    outline(part(pumpkin, 0.6, 0.14, 0.38, 0.82, Color3.fromRGB(196, 78, 8), 4))
    local middle = part(pumpkin, 0.2, 0.06, 0.6, 0.94, Color3.fromRGB(246, 120, 18), 5)
    outline(middle)
    local shine = part(pumpkin, 0.3, 0.16, 0.09, 0.22, Color3.fromRGB(255, 176, 76), 6)
    shine.BackgroundTransparency = 0.45

    local stem = part(pumpkin, 0.44, -0.14, 0.13, 0.22, Color3.fromRGB(88, 124, 32), 3, 0.3)
    stem.Rotation = 12

    local face = Instance.new("Frame")
    face.Name = "Face"
    face.Size = UDim2.fromScale(1, 1)
    face.BackgroundTransparency = 1
    face.ZIndex = zIndex + 7
    face.Parent = pumpkin

    local dark = Color3.fromRGB(26, 8, 30)
    local glowYellow = Color3.fromRGB(255, 200, 60)
    local eyeL = part(face, 0.28, 0.3, 0.15, 0.17, dark, 7, 0.2)
    eyeL.Rotation = 16
    part(face, 0.315, 0.35, 0.08, 0.08, glowYellow, 8, 0.5)
    local eyeR = part(face, 0.57, 0.3, 0.15, 0.17, dark, 7, 0.2)
    eyeR.Rotation = -16
    part(face, 0.605, 0.35, 0.08, 0.08, glowYellow, 8, 0.5)
    part(face, 0.26, 0.55, 0.48, 0.24, dark, 7, 0.25)
    part(face, 0.33, 0.55, 0.07, 0.09, Color3.fromRGB(246, 120, 18), 8, 0.1)
    part(face, 0.465, 0.55, 0.07, 0.09, Color3.fromRGB(246, 120, 18), 8, 0.1)
    part(face, 0.6, 0.55, 0.07, 0.09, Color3.fromRGB(246, 120, 18), 8, 0.1)
    part(face, 0.4, 0.7, 0.07, 0.09, Color3.fromRGB(246, 120, 18), 8, 0.1)
    part(face, 0.53, 0.7, 0.07, 0.09, Color3.fromRGB(246, 120, 18), 8, 0.1)

    table.insert(spinners, {holder = holder, glow = glow, arc = arcGradient, pumpkin = pumpkin, face = face, pw = pw, ph = ph, spin = 0, orbit = orbit})
    return holder
end

RunService.Heartbeat:Connect(function(dt)
    local now = os.clock()
    for i = #spinners, 1, -1 do
        local s = spinners[i]
        if not s.holder.Parent then
            table.remove(spinners, i)
        else
            s.spin += dt * 3.4
            local c = math.cos(s.spin)
            s.pumpkin.Size = UDim2.fromOffset(s.pw * math.max(0.14, math.abs(c)), s.ph)
            s.face.Visible = c > 0.12
            s.arc.Rotation = (s.arc.Rotation + dt * 300) % 360
            if s.orbit then
                s.orbit.Rotation = (s.orbit.Rotation - dt * 90) % 360
            end
            s.glow.BackgroundTransparency = 0.65 + 0.15 * math.sin(now * 4)
        end
    end
end)

local function styleButton(button, color)
    button.BackgroundColor3 = color
    button.TextColor3 = C.White
    button.Font = Enum.Font.GothamBlack
    button.TextSize = 14
    button.TextStrokeColor3 = C.Black
    button.TextStrokeTransparency = 0.45
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    corner(button, 10)

    local fill = Instance.new("UIGradient")
    fill.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color:Lerp(C.White, 0.18)),
        ColorSequenceKeypoint.new(0.45, color),
        ColorSequenceKeypoint.new(1, color:Lerp(C.Black, 0.55)),
    })
    fill.Rotation = 90
    fill.Parent = button

    local outline = stroke(button, C.Silver, 1.5)
    outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outline.Transparency = 0.15

    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = button

    local shine = Instance.new("Frame")
    shine.AnchorPoint = Vector2.new(0.5, 0)
    shine.Position = UDim2.new(0.5, 0, 0, 3)
    shine.Size = UDim2.new(0.7, 0, 0, 1)
    shine.BackgroundColor3 = C.White
    shine.BackgroundTransparency = 0.55
    shine.BorderSizePixel = 0
    shine.ZIndex = button.ZIndex + 1
    shine.Parent = button
    local shineFade = Instance.new("UIGradient")
    shineFade.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    shineFade.Parent = shine

    button.MouseEnter:Connect(function()
        tween(button, 0.15, {BackgroundColor3 = color:Lerp(C.Ember, 0.35)})
        tween(outline, 0.15, {Color = C.White, Thickness = 2.5, Transparency = 0})
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.15, {BackgroundColor3 = color})
        tween(outline, 0.15, {Color = C.Silver, Thickness = 1.5, Transparency = 0.15})
        tween(scale, 0.12, {Scale = 1})
    end)
    button.MouseButton1Down:Connect(function()
        tween(scale, 0.08, {Scale = 0.95})
    end)
    button.MouseButton1Up:Connect(function()
        tween(scale, 0.12, {Scale = 1})
    end)
    return outline
end

local function miniButton(parent, symbol, position, hoverColor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(28, 28)
    b.Position = position
    b.BackgroundColor3 = C.PanelLight
    b.Text = symbol
    b.TextColor3 = C.Silver
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 15
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.Parent = parent
    corner(b, 8)
    local s = stroke(b, C.BloodDark, 1)
    b.MouseEnter:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = hoverColor})
        tween(s, 0.15, {Color = C.Silver})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = C.PanelLight})
        tween(s, 0.15, {Color = C.BloodDark})
    end)
    return b
end

local function makeDraggable(handle, target)
    local drag = false
    local start, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            start = input.Position
            startPos = target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - start
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local NotifyHolder = Instance.new("Frame")
NotifyHolder.Name = "Notifications"
NotifyHolder.AnchorPoint = Vector2.new(1, 1)
NotifyHolder.Position = UDim2.new(1, -14, 1, -14)
NotifyHolder.Size = UDim2.fromOffset(280, 320)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.ZIndex = 200
NotifyHolder.Parent = ScreenGui
local notifyLayout = Instance.new("UIListLayout")
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Parent = NotifyHolder

local function notify(title, content, duration)
    if not NotifyHolder.Parent then return end
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 62)
    toast.BackgroundColor3 = C.Background
    toast.BorderSizePixel = 0
    toast.ZIndex = 201
    toast.Parent = NotifyHolder
    corner(toast, 10)
    stroke(toast, C.Ember, 1.5)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = C.Ember
    accent.BorderSizePixel = 0
    accent.ZIndex = 202
    accent.Parent = toast
    corner(accent, 4)

    createSpinner(toast, 24, UDim2.new(0, 26, 0.5, 0), 203, 0)

    local t = text(toast, "Title", title, UDim2.new(1, -56, 0, 20), UDim2.new(0, 44, 0, 8),
        Enum.Font.GothamBlack, C.Silver, 14)
    t.ZIndex = 202
    local c = text(toast, "Content", content, UDim2.new(1, -56, 0, 30), UDim2.new(0, 44, 0, 28),
        Enum.Font.Gotham, C.Steel, 12)
    c.TextWrapped = true
    c.TextYAlignment = Enum.TextYAlignment.Top
    c.ZIndex = 202

    local sc = Instance.new("UIScale")
    sc.Scale = 0.85
    sc.Parent = toast
    toast.BackgroundTransparency = 0.4
    tween(sc, 0.25, {Scale = 1})
    tween(toast, 0.25, {BackgroundTransparency = 0})

    task.delay(duration or 3, function()
        if not toast.Parent then return end
        tween(sc, 0.25, {Scale = 0.85})
        tween(toast, 0.25, {BackgroundTransparency = 1})
        task.wait(0.27)
        if toast.Parent then toast:Destroy() end
    end)
end

setLanguage = function(code, silent)
    lang = code
    _G.NoRILanguage = code
    for _, entry in ipairs(bindings) do
        if entry.obj.Parent then
            entry.obj[entry.prop] = (entry.prefix or "") .. T(entry.key)
        end
    end
    renderStatus()
    if langButton and langButton.Parent then
        langButton.Text = string.upper(code)
    end
    if not silent then
        notify(T("lang_title"), T("lang_body"), 2)
    end
end

local function applySpeed()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = walkSpeed end
end

-- === MAIN WINDOW ===
local WIN_W, WIN_H = 500, 330
local TOP_H = 44
local SIDE_W = 128

local MainRoot = Instance.new("Frame")
MainRoot.Name = "MainRoot"
MainRoot.AnchorPoint = Vector2.new(0.5, 0.5)
MainRoot.Position = UDim2.new(0.5, 0, 0.5, 0)
MainRoot.Size = UDim2.fromOffset(WIN_W, WIN_H)
MainRoot.BackgroundTransparency = 1
MainRoot.Visible = false
MainRoot.Parent = ScreenGui
local MainScale = Instance.new("UIScale")
MainScale.Parent = MainRoot
registerScale(MainScale, WIN_W, WIN_H, true)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromScale(1, 1)
Main.BackgroundColor3 = C.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = MainRoot
corner(Main, 14)
local mainStroke = stroke(Main, C.Ember, 2)
local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 24, 70)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 6, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 30, 8)),
})
mainGradient.Rotation = 35
mainGradient.Parent = Main

local EmberLayer = Instance.new("Frame")
EmberLayer.Name = "EmberLayer"
EmberLayer.Size = UDim2.fromScale(1, 1)
EmberLayer.BackgroundTransparency = 1
EmberLayer.ClipsDescendants = true
EmberLayer.ZIndex = 1
EmberLayer.Parent = Main

local Top = Instance.new("Frame")
Top.Name = "Topbar"
Top.Size = UDim2.new(1, 0, 0, TOP_H)
Top.BackgroundColor3 = C.Black
Top.BackgroundTransparency = 0.25
Top.BorderSizePixel = 0
Top.ZIndex = 3
Top.Parent = Main

local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 3)
TopAccent.BackgroundColor3 = C.Ember
TopAccent.BorderSizePixel = 0
TopAccent.ZIndex = 4
TopAccent.Parent = Top
local topAccentGradient = Instance.new("UIGradient")
topAccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.BloodDark),
    ColorSequenceKeypoint.new(0.7, C.Ember),
    ColorSequenceKeypoint.new(1, C.White),
})
topAccentGradient.Parent = TopAccent

createSpinner(Top, 32, UDim2.new(0, 28, 0, 22), 4, 0)

local TitleLabel = text(Top, "Title", "BETA GPT", UDim2.new(0, 160, 0, 20), UDim2.new(0, 52, 0, 6),
    Enum.Font.GothamBlack, C.White, 17)
TitleLabel.ZIndex = 4
local SubLabel = text(Top, "Subtitle", "", UDim2.new(0, 240, 0, 14),
    UDim2.new(0, 52, 0, 26), Enum.Font.GothamMedium, C.Ember, 11)
SubLabel.ZIndex = 4
SubLabel.Text = "NoRI Scripts  •  " .. T("author")
table.insert(bindings, {obj = SubLabel, key = "author", prop = "Text", prefix = "NoRI Scripts  •  "})

local MinButton = miniButton(Top, "-", UDim2.new(1, -72, 0, 10), C.Blood)
MinButton.ZIndex = 5
local CloseButton = miniButton(Top, "X", UDim2.new(1, -38, 0, 10), C.Blood)
CloseButton.ZIndex = 5
CloseButton.TextSize = 13

fadeLine(Main, UDim2.new(0, 0, 0, TOP_H), UDim2.new(1, 0, 0, 1)).ZIndex = 4
makeDraggable(Top, MainRoot)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = C.Ember
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.Position = UDim2.new(0, 0, 0, TOP_H + 1)
Sidebar.Size = UDim2.new(0, SIDE_W, 1, -(TOP_H + 1))
Sidebar.BackgroundColor3 = C.Black
Sidebar.BackgroundTransparency = 0.45
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = Main
local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = Sidebar
padding(Sidebar, 8, 8, 10, 8)

local sideLine = Instance.new("Frame")
sideLine.Position = UDim2.new(0, SIDE_W, 0, TOP_H + 1)
sideLine.Size = UDim2.new(0, 1, 1, -(TOP_H + 1))
sideLine.BackgroundColor3 = C.BloodDark
sideLine.BorderSizePixel = 0
sideLine.ZIndex = 4
sideLine.Parent = Main

local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Position = UDim2.new(0, SIDE_W + 8, 0, TOP_H + 8)
Pages.Size = UDim2.new(1, -(SIDE_W + 16), 1, -(TOP_H + 16))
Pages.BackgroundTransparency = 1
Pages.ZIndex = 3
Pages.Parent = Main

local tabs = {}
local activeTab = nil

local function selectTab(id)
    for tabId, t in pairs(tabs) do
        local on = (tabId == id)
        t.page.Visible = on
        t.indicator.Visible = on
        tween(t.button, 0.2, {
            BackgroundTransparency = on and 0.35 or 1,
            TextColor3 = on and C.White or C.Steel,
        })
    end
    activeTab = id
end

local function createTab(id, key, order)
    local button = Instance.new("TextButton")
    button.Name = id
    button.LayoutOrder = order
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = C.Blood
    button.BackgroundTransparency = 1
    button.TextColor3 = C.Steel
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.ZIndex = 4
    button.Parent = Sidebar
    bind(button, key)
    corner(button, 8)
    padding(button, 16, 4, 0, 0)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, -12, 0.2, 0)
    indicator.BackgroundColor3 = C.Ember
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 5
    indicator.Parent = button
    corner(indicator, 2)

    local page = Instance.new("ScrollingFrame")
    page.Name = id .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Ember
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 3
    page.Parent = Pages
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    padding(page, 0, 8, 2, 8)

    button.MouseEnter:Connect(function()
        if activeTab ~= id then tween(button, 0.15, {BackgroundTransparency = 0.7}) end
    end)
    button.MouseLeave:Connect(function()
        if activeTab ~= id then tween(button, 0.15, {BackgroundTransparency = 1}) end
    end)
    button.Activated:Connect(function() selectTab(id) end)

    tabs[id] = {button = button, page = page, indicator = indicator}
    return page
end

-- === UI WIDGET HELPERS ===
local function addSection(page, key)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 22)
    box.BackgroundTransparency = 1
    box.ZIndex = 3
    box.Parent = page
    local l = text(box, "Section", "", UDim2.new(1, 0, 0, 16), UDim2.new(0, 2, 0, 0),
        Enum.Font.GothamBlack, C.Ember, 11)
    l.ZIndex = 4
    bind(l, key)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -3)
    line.BackgroundColor3 = C.BloodDark
    line.BorderSizePixel = 0
    line.ZIndex = 4
    line.Parent = box
    return box
end

local function addButton(page, key, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 38)
    b.ZIndex = 4
    b.Parent = page
    styleButton(b, color or C.Blood)
    bind(b, key)
    b.Activated:Connect(function() callback() end)
    return b
end

local function addButtonRow(page, items)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundTransparency = 1
    row.ZIndex = 3
    row.Parent = page
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    layout.Parent = row
    local n = #items
    for _, item in ipairs(items) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1 / n, -8 * (n - 1) / n, 1, 0)
        b.Text = item.name
        b.ZIndex = 4
        b.Parent = row
        styleButton(b, item.color or C.Blood)
        b.Activated:Connect(function() item.callback() end)
    end
    return row
end

local function addToggle(page, key, default, callback)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 40)
    box.BackgroundColor3 = C.Panel
    box.BackgroundTransparency = 0.1
    box.BorderSizePixel = 0
    box.ZIndex = 4
    box.Parent = page
    corner(box, 10)
    local boxStroke = stroke(box, C.BloodDark, 1.5)

    local l = text(box, "Name", "", UDim2.new(1, -70, 1, 0), UDim2.new(0, 14, 0, 0),
        Enum.Font.GothamBold, C.Silver, 13)
    l.ZIndex = 5
    bind(l, key)

    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, -12, 0.5, 0)
    track.Size = UDim2.fromOffset(42, 22)
    track.BackgroundColor3 = C.Black
    track.BorderSizePixel = 0
    track.ZIndex = 5
    track.Parent = box
    round(track)
    local trackStroke = stroke(track, C.BloodDark, 1.5)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 3, 0.5, 0)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.BackgroundColor3 = C.Steel
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = track
    round(knob)

    local state = default
    local function render(animate)
        local info = animate and 0.18 or 0
        tween(knob, info, {
            Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = state and C.White or C.Steel,
        })
        tween(track, info, {BackgroundColor3 = state and C.Blood or C.Black})
        tween(trackStroke, info, {Color = state and C.Ember or C.BloodDark})
    end
    render(false)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.fromScale(1, 1)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 7
    hit.Parent = box
    hit.MouseEnter:Connect(function() tween(boxStroke, 0.15, {Color = C.Blood}) end)
    hit.MouseLeave:Connect(function() tween(boxStroke, 0.15, {Color = C.BloodDark}) end)
    hit.Activated:Connect(function()
        state = not state
        render(true)
        callback(state)
    end)
end

local function addSlider(page, key, min, max, default, step, suffix, callback)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 58)
    box.BackgroundColor3 = C.Panel
    box.BackgroundTransparency = 0.1
    box.BorderSizePixel = 0
    box.ZIndex = 4
    box.Parent = page
    corner(box, 10)
    stroke(box, C.BloodDark, 1.5)

    local nameLabel = text(box, "Name", "", UDim2.new(0.6, 0, 0, 20), UDim2.new(0, 14, 0, 7),
        Enum.Font.GothamBold, C.Silver, 13)
    nameLabel.ZIndex = 5
    bind(nameLabel, key)
    local valueLabel = text(box, "Value", "", UDim2.new(0.4, -14, 0, 20), UDim2.new(0.6, 0, 0, 7),
        Enum.Font.GothamBlack, C.White, 13, Enum.TextXAlignment.Right)
    valueLabel.ZIndex = 5

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 14, 0, 38)
    track.Size = UDim2.new(1, -28, 0, 8)
    track.BackgroundColor3 = C.Black
    track.BorderSizePixel = 0
    track.ZIndex = 5
    track.Parent = box
    corner(track, 4)
    stroke(track, C.BloodDark, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = C.Ember
    fill.BorderSizePixel = 0
    fill.ZIndex = 6
    fill.Parent = track
    corner(fill, 4)
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.BloodDark),
        ColorSequenceKeypoint.new(1, C.Ember),
    })
    fillGradient.Parent = fill

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = C.White
    knob.BorderSizePixel = 0
    knob.ZIndex = 7
    knob.Parent = track
    round(knob)
    stroke(knob, C.Ember, 2)

    local function setValue(v, silent)
        v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
        local a = (v - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valueLabel.Text = tostring(v) .. (suffix or "")
        if not silent then callback(v) end
    end
    setValue(default, true)

    local hit = Instance.new("TextButton")
    hit.Position = UDim2.new(0, -8, 0, -12)
    hit.Size = UDim2.new(1, 16, 1, 24)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 8
    hit.Parent = track

    local sliding = false
    local function fromInput(pos)
        local a = math.clamp((pos.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setValue(min + a * (max - min))
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            fromInput(input.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            fromInput(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    return function(v, silent) setValue(v, silent) end
end

local function addParagraph(page, titleKey, bodyKey)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundColor3 = C.Panel
    box.BackgroundTransparency = 0.1
    box.BorderSizePixel = 0
    box.ZIndex = 4
    box.Parent = page
    corner(box, 10)
    stroke(box, C.BloodDark, 1.5)
    padding(box, 14, 14, 10, 12)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = box

    local t = text(box, "Title", "", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0),
        Enum.Font.GothamBlack, C.Silver, 13)
    t.ZIndex = 5
    t.LayoutOrder = 1
    bind(t, titleKey)
    local b = text(box, "Body", "", UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 0),
        Enum.Font.Gotham, C.Steel, 12)
    b.AutomaticSize = Enum.AutomaticSize.Y
    b.TextWrapped = true
    b.TextYAlignment = Enum.TextYAlignment.Top
    b.ZIndex = 5
    b.LayoutOrder = 2
    bind(b, bodyKey)
    return box
end

-- === CHEATS LOGIC ===
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 60
local flyBodyGyro = nil
local flyBodyVelocity = nil
local flyConn = nil
local espEnabled = false
local espHighlights = {}
local aimbotEnabled = false
local aimbotFOV = 150
local aimbotSmooth = 0.15
local fullbrightEnabled = false
local fullbrightBrightness = 3
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- Noclip
RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- Fly
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    noclipEnabled = true
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam or not flyBodyGyro or not flyBodyVelocity then return end
        flyBodyGyro.CFrame = cam.CFrame
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
        flyBodyVelocity.Velocity = move * flySpeed
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    noclipEnabled = false
end

-- ESP
local function applyESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local old = char:FindFirstChild("NoRI_ESP")
    if old then old:Destroy() end
    if not espEnabled then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "NoRI_ESP"
    highlight.FillColor = C.Ember
    highlight.OutlineColor = C.White
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = char
    espHighlights[player] = highlight
end

local function refreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        applyESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then applyESP(player) end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
end)

-- === AIMBOT CORE (UPDATED) ===
local aimbotTargetPart = "Head" -- "Head", "HumanoidRootPart"
local aimbotWallCheck = true
local silentAimEnabled = false
local inTargetSearch = false

local function getClosestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestDist = nil, aimbotFOV

    inTargetSearch = true
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if player ~= LocalPlayer and char then
            local targetPart = char:FindFirstChild(aimbotTargetPart) or char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if targetPart and (not hum or hum.Health > 0) then
                local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < bestDist then
                        local visible = true
                        if aimbotWallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                            -- both characters are excluded: any hit means a wall is in the way
                            local rayResult = workspace:Raycast(cam.CFrame.Position, targetPart.Position - cam.CFrame.Position, rayParams)
                            visible = (rayResult == nil)
                        end
                        if visible then
                            bestDist = dist
                            best = targetPart
                        end
                    end
                end
            end
        end
    end
    inTargetSearch = false
    return best
end

-- Silent Aim: hook is installed once, only when the toggle is switched on
local silentHookInstalled = false
local function installSilentAim()
    if silentHookInstalled then return true end
    if not (getrawmetatable and setreadonly and getnamecallmethod) then
        return false -- executor does not support it
    end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(self, ...)
            if silentAimEnabled and aimbotEnabled and not inTargetSearch
                and self == workspace and getnamecallmethod() == "Raycast"
                and not (checkcaller and checkcaller()) then
                local args = {...}
                local target = getClosestTarget()
                if target and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                    args[2] = (target.Position - args[1]).Unit * args[2].Magnitude
                    return oldNamecall(self, table.unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end
        setreadonly(mt, true)
    end)
    silentHookInstalled = ok
    return ok
end

-- Aim: smooth = 100% means instant snap
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local target = getClosestTarget()
    if not target then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local targetCFrame = CFrame.new(cam.CFrame.Position, target.Position)
    if aimbotSmooth >= 1 then
        cam.CFrame = targetCFrame
    else
        cam.CFrame = cam.CFrame:Lerp(targetCFrame, aimbotSmooth)
    end
end)
-- === END AIMBOT CORE ===

-- Hitbox Expander
local hitboxEnabled = false
local hitboxSize = 10
local hitboxOriginal = {}

local function restoreHitbox(player)
    local data = hitboxOriginal[player]
    if data and data.part and data.part.Parent then
        data.part.Size = data.size
        data.part.Transparency = data.transparency
        data.part.CanCollide = data.canCollide
    end
    hitboxOriginal[player] = nil
end

local function applyHitbox(player)
    if player == LocalPlayer then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not hitboxOriginal[player] or hitboxOriginal[player].part ~= hrp then
        hitboxOriginal[player] = {
            part = hrp,
            size = hrp.Size,
            transparency = hrp.Transparency,
            canCollide = hrp.CanCollide,
        }
    end
    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hrp.Transparency = 0.7
    hrp.CanCollide = false
end

local function refreshHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if hitboxEnabled then
            applyHitbox(player)
        else
            restoreHitbox(player)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not hitboxEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        applyHitbox(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    hitboxOriginal[player] = nil
end)

-- Freecam
local freecamEnabled = false
local freecamSpeed = 2
local freecamBindName = "NoRIFreecam" .. tostring(os.clock())
local freecamRot = Vector2.zero
local freecamPos = Vector3.zero
local freecamLook = false
local freecamInputConns = {}

local function setPlayerControls(enabled)
    pcall(function()
        local controls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
        if enabled then controls:Enable() else controls:Disable() end
    end)
end

local function stopFreecam()
    pcall(function() RunService:UnbindFromRenderStep(freecamBindName) end)
    for _, c in ipairs(freecamInputConns) do c:Disconnect() end
    freecamInputConns = {}
    freecamLook = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    setPlayerControls(true)
    local cam = workspace.CurrentCamera
    if cam then
        cam.CameraType = Enum.CameraType.Custom
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
    end
end

local function startFreecam()
    local cam = workspace.CurrentCamera
    if not cam then return end
    stopFreecam()
    local x, y = cam.CFrame:ToOrientation()
    freecamRot = Vector2.new(x, y)
    freecamPos = cam.CFrame.Position
    cam.CameraType = Enum.CameraType.Scriptable
    setPlayerControls(false)

    table.insert(freecamInputConns, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamLook = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        end
    end))
    table.insert(freecamInputConns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamLook = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end))
    table.insert(freecamInputConns, UserInputService.InputChanged:Connect(function(input)
        if freecamLook and input.UserInputType == Enum.UserInputType.MouseMovement then
            freecamRot = Vector2.new(
                math.clamp(freecamRot.X - input.Delta.Y * 0.003, -math.rad(89), math.rad(89)),
                freecamRot.Y - input.Delta.X * 0.003
            )
        end
    end))

    RunService:BindToRenderStep(freecamBindName, Enum.RenderPriority.Camera.Value + 2, function(dt)
        local c = workspace.CurrentCamera
        if not c then return end
        c.CameraType = Enum.CameraType.Scriptable
        local rot = CFrame.fromOrientation(freecamRot.X, freecamRot.Y, 0)
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += rot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= rot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += rot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= rot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move -= Vector3.new(0, 1, 0) end
        local boost = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 3 or 1
        freecamPos += move * freecamSpeed * 30 * boost * dt
        c.CFrame = CFrame.new(freecamPos) * rot
    end)
end

-- God Mode (client-side, works only in games that trust the client)
local godModeEnabled = false
local godConns = {}

local function stopGodMode()
    for _, c in ipairs(godConns) do c:Disconnect() end
    godConns = {}
end

local function hookGodHumanoid(hum)
    if not hum then return end
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    table.insert(godConns, hum.HealthChanged:Connect(function()
        if godModeEnabled and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end))
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
end

local function startGodMode()
    stopGodMode()
    local char = LocalPlayer.Character
    hookGodHumanoid(char and char:FindFirstChildOfClass("Humanoid"))
    table.insert(godConns, LocalPlayer.CharacterAdded:Connect(function(newChar)
        local hum = newChar:WaitForChild("Humanoid", 5)
        if godModeEnabled then hookGodHumanoid(hum) end
    end))
end

-- Fullbright
local function applyFullbright()
    if fullbrightEnabled then
        Lighting.Brightness = fullbrightBrightness
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end
-- === END CHEATS LOGIC ===

-- === TRACER & NAME ESP ===
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "NoRITracers"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.DisplayOrder = 115
tracerGui.Enabled = false
tracerGui.Parent = PlayerGui

local tracerEnabled = false
local nameEspEnabled = false
local tracerLines = {}
local nameTags = {}

local function createTracer(player)
    if player == LocalPlayer or tracerLines[player] then return end
    local line = Instance.new("Frame")
    line.Name = "Tracer_" .. player.Name
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Size = UDim2.new(0, 2, 0, 0)
    line.Visible = false
    line.Parent = tracerGui
    tracerLines[player] = line
end

local function updateTracers()
    if not tracerEnabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local origin = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    for player, line in pairs(tracerLines) do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local target = Vector2.new(screenPos.X, screenPos.Y)
                local delta = target - origin
                local mid = origin + delta / 2
                line.Position = UDim2.fromOffset(mid.X, mid.Y)
                line.Size = UDim2.new(0, 2, 0, delta.Magnitude)
                line.Rotation = math.deg(math.atan2(delta.Y, delta.X)) - 90
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(createTracer)
Players.PlayerRemoving:Connect(function(p)
    if tracerLines[p] then tracerLines[p]:Destroy() tracerLines[p] = nil end
    if nameTags[p] then nameTags[p]:Destroy() nameTags[p] = nil end
end)
for _, p in ipairs(Players:GetPlayers()) do createTracer(p) end

local function hideNameTags()
    for _, tag in pairs(nameTags) do tag.Visible = false end
end

local function updateNameTags()
    if not nameEspEnabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local tag = nameTags[player]
            if head then
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
                if onScreen then
                    if not tag then
                        tag = Instance.new("TextLabel")
                        tag.BackgroundTransparency = 1
                        tag.AnchorPoint = Vector2.new(0.5, 0.5)
                        tag.Size = UDim2.fromOffset(120, 18)
                        tag.TextColor3 = Color3.fromRGB(255, 255, 255)
                        tag.TextStrokeTransparency = 0
                        tag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        tag.Font = Enum.Font.GothamBold
                        tag.TextSize = 14
                        tag.Text = player.DisplayName
                        tag.Parent = tracerGui
                        nameTags[player] = tag
                    end
                    tag.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
                    tag.Visible = true
                elseif tag then
                    tag.Visible = false
                end
            elseif tag then
                tag.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateTracers()
    updateNameTags()
end)
-- === END TRACER & NAME ESP ===

-- === AIMBOT FOV CIRCLE & CROSSHAIR ===
local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "NoRICrosshair"
crosshairGui.ResetOnSpawn = false
crosshairGui.IgnoreGuiInset = true
crosshairGui.DisplayOrder = 110
crosshairGui.Parent = PlayerGui

-- FOV Круг
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = crosshairGui
round(fovCircle)
local fovStroke = stroke(fovCircle, Color3.fromRGB(255, 50, 50), 1.5)
fovStroke.Transparency = 0.5

-- Крутящийся крест
local crossFrame = Instance.new("Frame")
crossFrame.Name = "Crosshair"
crossFrame.AnchorPoint = Vector2.new(0.5, 0.5)
crossFrame.Position = UDim2.fromScale(0.5, 0.5)
crossFrame.Size = UDim2.fromOffset(40, 40)
crossFrame.BackgroundTransparency = 1
crossFrame.Visible = false
crossFrame.Parent = crosshairGui

local line1 = Instance.new("Frame")
line1.AnchorPoint = Vector2.new(0.5, 0.5)
line1.Position = UDim2.fromScale(0.5, 0.5)
line1.Size = UDim2.fromOffset(20, 2)
line1.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
line1.BorderSizePixel = 0
line1.Parent = crossFrame
corner(line1, 2)

local line2 = Instance.new("Frame")
line2.AnchorPoint = Vector2.new(0.5, 0.5)
line2.Position = UDim2.fromScale(0.5, 0.5)
line2.Size = UDim2.fromOffset(2, 20)
line2.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
line2.BorderSizePixel = 0
line2.Parent = crossFrame
corner(line2, 2)

local crossSpin = 0
local crossConn
crossConn = RunService.RenderStepped:Connect(function(dt)
    if not crosshairGui.Parent then
        crossConn:Disconnect()
        return
    end
    -- Крутим крест
    crossSpin = (crossSpin + dt * 60) % 360
    crossFrame.Rotation = crossSpin

    -- Обновляем размер круга FOV
    if aimbotEnabled then
        fovCircle.Visible = true
        local size = aimbotFOV * 2
        fovCircle.Size = UDim2.fromOffset(size, size)
    else
        fovCircle.Visible = false
    end
end)
-- === END AIMBOT FOV CIRCLE ===

-- === KEY WINDOW ===
local KEY_W, KEY_H = 360, 268

local KeyRoot = Instance.new("Frame")
KeyRoot.Name = "KeyWindow"
KeyRoot.AnchorPoint = Vector2.new(0.5, 0.5)
KeyRoot.Position = UDim2.new(0.5, 0, 0.5, 0)
KeyRoot.Size = UDim2.fromOffset(KEY_W, KEY_H)
KeyRoot.BackgroundColor3 = C.Background
KeyRoot.BorderSizePixel = 0
KeyRoot.ZIndex = 50
KeyRoot.ClipsDescendants = true
KeyRoot.Visible = false
KeyRoot.Parent = ScreenGui
corner(KeyRoot, 14)
stroke(KeyRoot, C.Ember, 2)
local KeyScale = Instance.new("UIScale")
KeyScale.Parent = KeyRoot
registerScale(KeyScale, KEY_W, KEY_H, false)

local keyGradient = Instance.new("UIGradient")
keyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(62, 26, 74)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(14, 6, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(72, 32, 8)),
})
keyGradient.Rotation = 35
keyGradient.Parent = KeyRoot

local KeyTop = Instance.new("Frame")
KeyTop.Size = UDim2.new(1, 0, 0, 52)
KeyTop.BackgroundColor3 = C.Black
KeyTop.BackgroundTransparency = 0.25
KeyTop.BorderSizePixel = 0
KeyTop.ZIndex = 51
KeyTop.Parent = KeyRoot

local KeyAccent = Instance.new("Frame")
KeyAccent.Size = UDim2.new(1, 0, 0, 3)
KeyAccent.BackgroundColor3 = C.Ember
KeyAccent.BorderSizePixel = 0
KeyAccent.ZIndex = 52
KeyAccent.Parent = KeyTop
local keyAccentGradient = Instance.new("UIGradient")
keyAccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.BloodDark),
    ColorSequenceKeypoint.new(0.7, C.Ember),
    ColorSequenceKeypoint.new(1, C.White),
})
keyAccentGradient.Parent = KeyAccent

createSpinner(KeyTop, 34, UDim2.new(0, 29, 0, 26), 52, 0)
text(KeyTop, "Title", "BETA GPT", UDim2.new(1, -140, 0, 22), UDim2.new(0, 54, 0, 8),
    Enum.Font.GothamBlack, C.White, 18).ZIndex = 52
local KeySubtitle = text(KeyTop, "Subtitle", "", UDim2.new(1, -140, 0, 14), UDim2.new(0, 54, 0, 30),
    Enum.Font.GothamMedium, C.Ember, 11)
KeySubtitle.ZIndex = 52
bind(KeySubtitle, "key_subtitle")

langButton = miniButton(KeyTop, string.upper(lang), UDim2.new(1, -74, 0, 12), C.Blood)
langButton.ZIndex = 53
langButton.TextSize = 11
langButton.Activated:Connect(function()
    setLanguage(lang == "en" and "ru" or "en", true)
end)

local KeyClose = miniButton(KeyTop, "X", UDim2.new(1, -40, 0, 12), C.Blood)
KeyClose.ZIndex = 53
KeyClose.TextSize = 13
KeyClose.Activated:Connect(function()
    ScreenGui:Destroy()
end)
fadeLine(KeyRoot, UDim2.new(0, 0, 0, 52), UDim2.new(1, 0, 0, 1)).ZIndex = 52

local KeyHint = text(KeyRoot, "Hint", "", UDim2.new(1, -40, 0, 18), UDim2.new(0, 20, 0, 68),
    Enum.Font.GothamBold, C.Steel, 12)
KeyHint.ZIndex = 52
bind(KeyHint, "key_hint")

local PasswordInput = Instance.new("TextBox")
PasswordInput.Name = "PasswordInput"
PasswordInput.Size = UDim2.new(1, -40, 0, 42)
PasswordInput.Position = UDim2.new(0, 20, 0, 90)
PasswordInput.BackgroundColor3 = C.Black
PasswordInput.BackgroundTransparency = 0.1
PasswordInput.BorderSizePixel = 0
PasswordInput.Text = ""
PasswordInput.PlaceholderColor3 = C.Gray
PasswordInput.TextColor3 = C.White
PasswordInput.Font = Enum.Font.Gotham
PasswordInput.TextSize = 15
PasswordInput.ClearTextOnFocus = false
PasswordInput.TextXAlignment = Enum.TextXAlignment.Center
PasswordInput.TextTruncate = Enum.TextTruncate.AtEnd
PasswordInput.ZIndex = 52
PasswordInput.Parent = KeyRoot
bind(PasswordInput, "key_placeholder", "PlaceholderText")
corner(PasswordInput, 10)
local inputStroke = stroke(PasswordInput, C.BloodDark, 1.5)
PasswordInput.Focused:Connect(function() tween(inputStroke, 0.15, {Color = C.Ember}) end)
PasswordInput.FocusLost:Connect(function() tween(inputStroke, 0.15, {Color = C.BloodDark}) end)

local AuthButton = Instance.new("TextButton")
AuthButton.Name = "ConfirmButton"
AuthButton.Size = UDim2.new(1, -40, 0, 40)
AuthButton.Position = UDim2.new(0, 20, 0, 144)
AuthButton.ZIndex = 52
AuthButton.Parent = KeyRoot
styleButton(AuthButton, C.Blood)
bind(AuthButton, "confirm")

AuthStatus = text(KeyRoot, "AuthStatus", "", UDim2.new(1, -40, 0, 20),
    UDim2.new(0, 20, 0, 196), Enum.Font.GothamMedium, C.Gray, 12, Enum.TextXAlignment.Center)
AuthStatus.ZIndex = 52
setStatus("attempts_left", C.Gray, MAX_ATTEMPTS)

local KeyNote = text(KeyRoot, "Note", "", UDim2.new(1, -40, 0, 16),
    UDim2.new(0, 20, 0, 224), Enum.Font.Gotham, C.Gray, 11, Enum.TextXAlignment.Center)
KeyNote.ZIndex = 52
bind(KeyNote, "key_note")

-- === TABS / PAGES ===
local SpeedPage = createTab("speed", "tab_speed", 1)
addSection(SpeedPage, "sec_movement")

local setSpeedSlider = addSlider(SpeedPage, "walkspeed", 4, 500, 16, 1, "", function(v)
    walkSpeed = v
    applySpeed()
end)

addButtonRow(SpeedPage, {
    {name = "- 16", color = Color3.fromRGB(60, 24, 72), callback = function()
        walkSpeed = math.clamp(walkSpeed - 16, 4, 500)
        setSpeedSlider(walkSpeed, true)
        applySpeed()
    end},
    {name = "+ 16", color = Color3.fromRGB(205, 92, 10), callback = function()
        walkSpeed = math.clamp(walkSpeed + 16, 4, 500)
        setSpeedSlider(walkSpeed, true)
        applySpeed()
    end},
})

addButton(SpeedPage, "reset", Color3.fromRGB(60, 24, 72), function()
    walkSpeed = 16
    setSpeedSlider(16, true)
    applySpeed()
    notify(T("speed_title"), T("speed_body"), 2)
end)

addSection(SpeedPage, "sec_options")
addToggle(SpeedPage, "keep_speed", true, function(v)
    keepSpeedOnRespawn = v
end)

local ViewPage = createTab("view", "tab_view", 2)
addSection(ViewPage, "sec_camera")

local setFovSlider = addSlider(ViewPage, "fov", 30, 120, math.floor(defaultFov + 0.5), 1, "", function(v)
    fovValue = v
    fovCustom = true
end)

addButton(ViewPage, "fov_reset", Color3.fromRGB(60, 24, 72), function()
    fovCustom = false
    fovValue = defaultFov
    setFovSlider(math.floor(defaultFov + 0.5), true)
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = defaultFov end
end)

addToggle(ViewPage, "stretch", false, function(v)
    stretchOn = v
end)

addSlider(ViewPage, "stretch_amount", 50, 100, 75, 5, "%", function(v)
    stretchValue = v / 100
end)

local SettingsPage = createTab("settings", "tab_settings", 3)
addSection(SettingsPage, "sec_interface")
addToggle(SettingsPage, "embers", true, function(v)
    particlesOn = v
end)
addSlider(SettingsPage, "window_size", 60, 110, 100, 5, "%", function(v)
    userScale = v / 100
    refreshScales()
end)
addSection(SettingsPage, "sec_language")
addButtonRow(SettingsPage, {
    {name = "English", color = Color3.fromRGB(60, 24, 72), callback = function() setLanguage("en") end},
    {name = "Русский", color = Color3.fromRGB(205, 92, 10), callback = function() setLanguage("ru") end},
})
addParagraph(SettingsPage, "hotkey_title", "hotkey_body")

local InfoPage = createTab("info", "tab_info", 7)
addSection(InfoPage, "sec_about")
addParagraph(InfoPage, "info_title", "info_body")

-- === CHEATS TABS ===
-- Combat
local CombatPage = createTab("combat", "tab_combat", 4)
addSection(CombatPage, "sec_aimbot")
addToggle(CombatPage, "aimbot", false, function(v)
    aimbotEnabled = v
end)
addSlider(CombatPage, "aimbot_fov", 50, 400, 150, 10, "px", function(v)
    aimbotFOV = v
end)
addSlider(CombatPage, "aimbot_smooth", 5, 100, 15, 1, "%", function(v)
    aimbotSmooth = v / 100
end)

addSection(CombatPage, "sec_aimbot_settings")
addButtonRow(CombatPage, {
    {name = T("part_head"), color = Color3.fromRGB(60, 24, 72), callback = function() aimbotTargetPart = "Head" end},
    {name = T("part_body"), color = Color3.fromRGB(205, 92, 10), callback = function() aimbotTargetPart = "HumanoidRootPart" end},
})
addToggle(CombatPage, "wall_check", true, function(v)
    aimbotWallCheck = v
end)
addToggle(CombatPage, "silent_aim", false, function(v)
    if v and not installSilentAim() then
        silentAimEnabled = false
        notify("Silent Aim", "Not supported by your executor", 3)
        return
    end
    silentAimEnabled = v
    notify("Silent Aim", v and "Enabled (Risky!)" or "Disabled", 2)
end)

addSection(CombatPage, "sec_hitbox")
addToggle(CombatPage, "hitbox", false, function(v)
    hitboxEnabled = v
    refreshHitboxes()
end)
addSlider(CombatPage, "hitbox_size", 5, 30, 10, 1, "", function(v)
    hitboxSize = v
    if hitboxEnabled then refreshHitboxes() end
end)

-- Visual
local VisualPage = createTab("visual", "tab_visual", 5)
addSection(VisualPage, "sec_visual")
addToggle(VisualPage, "esp", false, function(v)
    espEnabled = v
    refreshESP()
end)
addToggle(VisualPage, "crosshair", false, function(v)
    crossFrame.Visible = v
end)
addToggle(VisualPage, "fullbright", false, function(v)
    fullbrightEnabled = v
    applyFullbright()
end)
addSlider(VisualPage, "fullbright_brightness", 0, 5, 3, 1, "", function(v)
    fullbrightBrightness = v
    if fullbrightEnabled then applyFullbright() end
end)

addSection(VisualPage, "sec_visual_extras")
addToggle(VisualPage, "tracer", false, function(v)
    tracerEnabled = v
    tracerGui.Enabled = v
    if not v then for _, l in pairs(tracerLines) do l.Visible = false end end
end)
addToggle(VisualPage, "name_esp", false, function(v)
    nameEspEnabled = v
    if not v then hideNameTags() end
end)

-- Movement
local MovePage = createTab("move", "tab_move", 6)
addSection(MovePage, "sec_cheat_movement")
addToggle(MovePage, "noclip", false, function(v)
    noclipEnabled = v
end)
addToggle(MovePage, "fly", false, function(v)
    flyEnabled = v
    if v then startFly() else stopFly() end
end)
addSlider(MovePage, "fly_speed", 20, 200, 60, 5, "", function(v)
    flySpeed = v
end)

addSection(MovePage, "sec_freecam")
addToggle(MovePage, "freecam", false, function(v)
    freecamEnabled = v
    if v then startFreecam() else stopFreecam() end
end)
addSlider(MovePage, "freecam_speed", 1, 10, 2, 1, "", function(v)
    freecamSpeed = v
end)

addSection(MovePage, "sec_god")
addToggle(MovePage, "god", false, function(v)
    godModeEnabled = v
    if v then startGodMode() else stopGodMode() end
end)
-- === END CHEATS TABS ===

selectTab("speed")

MinButton.Activated:Connect(function()
    if busy then return end
    minimized = not minimized
    if minimized then
        MinButton.Text = "+"
        Sidebar.Visible = false
        Pages.Visible = false
        sideLine.Visible = false
        tween(Main, 0.3, {Size = UDim2.new(1, 0, 0, TOP_H + 1)})
    else
        MinButton.Text = "-"
        tween(Main, 0.3, {Size = UDim2.fromScale(1, 1)})
        task.delay(0.15, function()
            if Main.Parent and not minimized then
                Sidebar.Visible = true
                Pages.Visible = true
                sideLine.Visible = true
            end
        end)
    end
end)

CloseButton.Activated:Connect(function()
    walkSpeed = 16
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = 16 end
    ScreenGui:Destroy()
end)

local function setMenuVisible(visible)
    if busy or guiActive == visible then return end
    busy = true
    guiActive = visible
    local p = MainRoot.Position
    if visible then
        MainRoot.Visible = true
        MainRoot.Position = p + UDim2.fromOffset(0, 16)
        tween(MainRoot, 0.35, {Position = p})
        task.delay(0.36, function() busy = false end)
    else
        tween(MainRoot, 0.2, {Position = p + UDim2.fromOffset(0, 12)})
        task.delay(0.22, function()
            if MainRoot.Parent then
                MainRoot.Visible = false
                MainRoot.Position = p
            end
            busy = false
        end)
    end
end

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.fromOffset(58, 58)
ToggleButton.Position = UDim2.new(0, 18, 0.5, -29)
ToggleButton.BackgroundColor3 = C.Black
ToggleButton.Image = ""
ToggleButton.AutoButtonColor = false
ToggleButton.ZIndex = 10
ToggleButton.Visible = false
ToggleButton.Active = true
ToggleButton.Parent = ScreenGui
corner(ToggleButton, 16)
local toggleStroke = stroke(ToggleButton, C.Blood, 2.5)
local toggleGradient = Instance.new("UIGradient")
toggleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 50, 8)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(32, 12, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 0, 1)),
})
toggleGradient.Rotation = 45
toggleGradient.Parent = ToggleButton
createSpinner(ToggleButton, 42, UDim2.fromScale(0.5, 0.5), 13, 0)

local dragging = false
local dragMoved = false
local dragInput = nil
local dragStart = nil
local startPosition = nil
local suppressClickUntil = 0
local DRAG_THRESHOLD = 6

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragMoved = false
        dragStart = input.Position
        startPosition = ToggleButton.AbsolutePosition
        if input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or (dragInput and input == dragInput)
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD then
            dragMoved = true
        end
        if dragMoved then
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize
            local x = startPosition.X + delta.X
            local y = startPosition.Y + delta.Y
            if viewport then
                x = math.clamp(x, 0, math.max(0, viewport.X - ToggleButton.AbsoluteSize.X))
                y = math.clamp(y, 0, math.max(0, viewport.Y - ToggleButton.AbsoluteSize.Y))
            end
            ToggleButton.Position = UDim2.fromOffset(x, y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            dragInput = nil
            if dragMoved then suppressClickUntil = os.clock() + 0.3 end
        end
    end
end)

ToggleButton.Activated:Connect(function()
    if os.clock() < suppressClickUntil then return end
    setMenuVisible(not guiActive)
end)
ToggleButton.MouseEnter:Connect(function()
    tween(toggleStroke, 0.2, {Color = C.Ember, Thickness = 3.5})
end)
ToggleButton.MouseLeave:Connect(function()
    tween(toggleStroke, 0.2, {Color = C.Blood, Thickness = 2.5})
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not authorized then return end
    if input.KeyCode == Enum.KeyCode.K then
        setMenuVisible(not guiActive)
    end
end)

local function openAfterAuth()
    ToggleButton.Visible = true
    ToggleButton.BackgroundTransparency = 1
    tween(ToggleButton, 0.3, {BackgroundTransparency = 0})
    notify(T("granted_title"), T("granted_body"), 3)
    task.wait(0.35)
    setMenuVisible(true)
end

local function verifyPassword()
    if authorized or not KeyRoot.Parent then return end
    local now = os.clock()

    if now < lockedUntil then
        setStatus("retry_in", C.Ember, math.ceil(lockedUntil - now))
        return
    end

    if PasswordInput.Text == CORRECT_PASSWORD then
        authorized = true
        _G.NoRIAuthorized = true
        AuthButton.Active = false
        setStatus("access_status", C.Silver)
        PasswordInput:ReleaseFocus()
        tween(KeyScale, 0.25, {Scale = KeyScale.Scale * 0.9})
        tween(KeyRoot, 0.25, {BackgroundTransparency = 1})
        task.wait(0.27)
        if KeyRoot.Parent then KeyRoot:Destroy() end
        if ScreenGui.Parent then openAfterAuth() end
        return
    end

    attemptsLeft -= 1
    PasswordInput.Text = ""
    if attemptsLeft <= 0 then
        lockedUntil = os.clock() + LOCK_DURATION
        AuthButton.Active = false
        AuthButton.BackgroundColor3 = C.PanelLight
        setStatus("locked", C.Ember)
    else
        setStatus("wrong_key", C.Ember, attemptsLeft)
        notify(T("error_title"), string.format(T("error_body"), attemptsLeft), 2.5)
    end
end

AuthButton.Activated:Connect(verifyPassword)
PasswordInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then verifyPassword() end
end)

task.spawn(function()
    while ScreenGui.Parent and not authorized do
        task.wait(0.25)
        if not KeyRoot.Parent then break end
        local remaining = math.ceil(lockedUntil - os.clock())
        if lockedUntil > 0 and remaining <= 0 then
            lockedUntil = 0
            attemptsLeft = MAX_ATTEMPTS
            AuthButton.Active = true
            AuthButton.BackgroundColor3 = C.Blood
            setStatus("attempts_restored", C.Silver)
        elseif remaining > 0 then
            setStatus("retry_in", C.Ember, remaining)
        end
    end
end)

local function showKeyWindow()
    if not KeyRoot.Parent then return end
    local p = KeyRoot.Position
    KeyRoot.Visible = true
    KeyRoot.Position = p + UDim2.fromOffset(0, 24)
    tween(KeyRoot, 0.4, {Position = p})
end

local function runLoader(onDone)
    local Loader = Instance.new("Frame")
    Loader.Name = "LoaderScreen"
    Loader.Size = UDim2.fromScale(1, 1)
    Loader.BackgroundColor3 = Color3.fromRGB(9, 3, 13)
    Loader.BackgroundTransparency = 0.08
    Loader.BorderSizePixel = 0
    Loader.ZIndex = 100
    Loader.Parent = ScreenGui

    local loaderGradient = Instance.new("UIGradient")
    loaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(84, 34, 96)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(14, 6, 18)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(74, 32, 8)),
    })
    loaderGradient.Rotation = 60
    loaderGradient.Parent = Loader

    createSpinner(Loader, 150, UDim2.fromScale(0.5, 0.46), 101, 10)

    local LoaderText = text(Loader, "LoaderText", "", UDim2.fromOffset(240, 24),
        UDim2.new(0.5, -120, 0.46, 100), Enum.Font.GothamBlack, C.Silver, 16, Enum.TextXAlignment.Center)
    LoaderText.TextStrokeColor3 = C.Blood
    LoaderText.TextStrokeTransparency = 0.4
    LoaderText.ZIndex = 101
    local LoaderSub = text(Loader, "LoaderSub", "BETA GPT  •  NoRI Scripts", UDim2.fromOffset(260, 18),
        UDim2.new(0.5, -130, 0.46, 126), Enum.Font.GothamMedium, C.Ember, 12, Enum.TextXAlignment.Center)
    LoaderSub.ZIndex = 101

    local active = true
    task.spawn(function()
        local n = 0
        while active and Loader.Parent do
            n = (n % 3) + 1
            LoaderText.Text = T("loading") .. string.rep(".", n)
            task.wait(0.35)
        end
    end)

    task.delay(2.5, function()
        if not Loader.Parent then return end
        active = false
        for _, obj in ipairs(Loader:GetDescendants()) do
            if obj:IsA("Frame") then
                tween(obj, 0.3, {BackgroundTransparency = 1})
            elseif obj:IsA("TextLabel") then
                tween(obj, 0.3, {TextTransparency = 1, TextStrokeTransparency = 1})
            elseif obj:IsA("UIStroke") then
                tween(obj, 0.3, {Transparency = 1})
            end
        end
        tween(Loader, 0.3, {BackgroundTransparency = 1})
        task.wait(0.32)
        Loader:Destroy()
        if ScreenGui.Parent then onDone() end
    end)
end

task.spawn(function()
    while ScreenGui.Parent do
        tween(mainStroke, 1.2, {Color = C.Ember})
        task.wait(1.2)
        if not ScreenGui.Parent then break end
        tween(mainStroke, 1.2, {Color = C.BloodDark})
        task.wait(1.2)
    end
end)

task.spawn(function()
    local emberColors = {C.Ember, Color3.fromRGB(255, 176, 44), C.Blood, C.Silver}
    while ScreenGui.Parent do
        if MainRoot.Visible and particlesOn and not minimized then
            local particle = Instance.new("Frame")
            local diameter = math.random(3, 7)
            particle.Size = UDim2.fromOffset(diameter, diameter)
            particle.Position = UDim2.new(math.random(), 0, 1, 0)
            particle.BackgroundColor3 = emberColors[math.random(1, #emberColors)]
            particle.BackgroundTransparency = 0.25
            particle.BorderSizePixel = 0
            particle.ZIndex = 1
            particle.Parent = EmberLayer
            round(particle)
            local startX = particle.Position.X.Scale
            tween(particle, math.random(25, 45) / 10, {
                Position = UDim2.new(startX + (math.random(-12, 12) / 100), 0, -0.1, 0),
                BackgroundTransparency = 1,
            })
            task.delay(4.7, function()
                if particle.Parent then particle:Destroy() end
            end)
        end
        task.wait(0.14)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = keepSpeedOnRespawn and walkSpeed or 16
        if not keepSpeedOnRespawn then
            walkSpeed = 16
            setSpeedSlider(16, true)
        end
    end
end)

RunService:BindToRenderStep(viewBindName, Enum.RenderPriority.Camera.Value + 1, function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if fovCustom then cam.FieldOfView = fovValue end
    if stretchOn then
        cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, stretchValue, 0, 0, 0, 1)
    end
end)

ScreenGui.Destroying:Connect(function()
    pcall(function() RunService:UnbindFromRenderStep(viewBindName) end)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = defaultFov end
    aimbotEnabled = false
    silentAimEnabled = false
    hitboxEnabled = false
    refreshHitboxes()
    if tracerGui.Parent then tracerGui:Destroy() end
    if freecamEnabled then stopFreecam() end
    stopGodMode()
    if overlayGui.Parent then overlayGui:Destroy() end
    if crosshairGui.Parent then crosshairGui:Destroy() end
end)

overlayGui.Destroying:Connect(function()
    if overlayGui.Parent then overlayGui:Destroy() end
end)

if authorized then
    KeyRoot:Destroy()
    ToggleButton.Visible = true
    setMenuVisible(true)
else
    runLoader(showKeyWindow)
end
