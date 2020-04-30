script_name("MultiBinder by FORMYS")
script_authors("FORMYS, TheChampGuess")

local key = require 'vkeys'
local imgui = require 'imgui'
local inicfg = require 'inicfg'
local encoding = require 'encoding'
local sampev = require 'lib.samp.events'
local bindPath = "moonloader\\MultiBinder\\binder.ini";
local bindPathShort = "moonloader\\MultiBinder";

require "lib.moonloader"
encoding.default = 'CP1251'
u8 = encoding.UTF8

local bind_slot = 50 -- кол-во слотов биндера

if not doesDirectoryExist(bindPathShort) then
	createDirectory(bindPathShort)
end

if not doesFileExist(bindPath) then
	f = io.open(bindPath, 'a')
	for i=1, bind_slot do
		f:write("[".. i .."]\n")
	end
	f:write("1=")
	f:close()
end

local mainBind = inicfg.load(nil, bindPath)
local binder_window = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local wmine = 700

about_bind = {}
binder_text = {}
binder_vars = {}
binder_text[1] = imgui.ImBuffer(1024) -- multiline
binder_text[2] = imgui.ImBuffer(192) -- активация команда
binder_text[3] = imgui.ImBuffer(16) -- задержка
selected_item_binder = imgui.ImInt(0)

cb_render_in_menu = imgui.ImBool(imgui.RenderInMenu)
cb_lock_player = imgui.ImBool(imgui.LockPlayer)
cb_show_cursor = imgui.ImBool(imgui.ShowCursor)

function SetStyle()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.ChildWindowRounding = 4.0
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
end
SetStyle()

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	thread = lua_thread.create_suspended(thread_function)

	_, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = string.gsub(sampGetPlayerNickname(myId), "_", " ")
	youId = getClosestPlayerId()
	youNick = string.gsub(sampGetPlayerNickname(youId), "_", " ")

	binder_vars = {["myId"]=myId, ["myNick"]=myNick, ["youId"]=youId, ["youNick"]=youNick}

	AddChatMessage("Успешно запущен")

	while true do
		wait(0)

		for i = 1, bind_slot do
			if mainBind[i] ~= nil then
				if mainBind[i].act ~= nil and not string.find(mainBind[i].act, "/", 1, true) then
					if isKeysDown(strToIdKeys(mainBind[i].act)) then
						thread:run("binder" .. i)
					end
				end
			end
		end
	end

end

function sampev.onSendCommand(command)
	if command == "/binder" then
		binder_window.v = not binder_window.v
		imgui.Process = binder_window.v
	end
	for i = 1, bind_slot do
		if mainBind[i] ~= nil and mainBind[i].act ~= nil then
			if command == mainBind[i].act then
				thread:run("binder" .. i)
				return false
			end
		end
	end
end

function thread_function(option)
	if string.sub(option, 0, 6) == "binder" then
		ind = tonumber(string.sub(option, 7))
		for i = 1, 30 do
			if mainBind[ind][i] ~= nil then
				if mainBind[ind][i] == "" then
					sampAddChatMessage("[Binder | Warning]: Обнаружена пустая строка", -1)
				else
					bindStr = u8:decode(mainBind[ind][i])
					for word in string.gmatch(bindStr, "{(%a+)}") do
						bindStr = string.gsub(bindStr, "{" .. word .. "}", binder_vars[word])
					end
					sampSendChat(bindStr, -1)
					wait(tonumber(mainBind[ind].wait .. "000"))
				end
			else
				return
			end
		end
		return
	end
end

function AddChatMessage(text)
	sampAddChatMessage("[MultiBinder]: {FFFFFF}" .. text, 0x5A90CE)
end

function ShowHelpMarker(text)
	imgui.SameLine()
    imgui.TextDisabled("(?)")
    if (imgui.IsItemHovered()) then
        imgui.SetTooltip(u8(text))
    end
end

function ShowCenterTextColor(text, wsize, color)
	imgui.SetCursorPosX((wsize / 2) - (imgui.CalcTextSize(text).x / 2))
	imgui.TextColored(color, text)
end

function ShowCenterText(text, wsize)
	imgui.SetCursorPosX((wsize / 2) - (imgui.CalcTextSize(text).x / 2))
	imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), text)
end

function isReservedCommand(command)
	ArrRCommand = {"binder"}
	for i = 1, #ArrRCommand do
		if command == ArrRCommand[i] then
			return true
		end
	end
	return false
end

function getDownKeys()
    local curkeys = ""
    local bool = false
    for k, v in pairs(key) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(key) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function getDownKeysText()
	tKeys = string.split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = key.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. key.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end


function string.split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function strToIdKeys(str)
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = key.name_to_id(tKeys[i], false)
			else
				str = str .. " " .. key.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
    local tKeys = string.split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end

function getClosestPlayerId()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist then
                minDist = dist
                closestId = i
            end
        end
    end
    return closestId
end

function imgui.OnDrawFrame()
	if not binder_window.v then
		imgui.Process = false
	end
	if binder_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine+50, 340), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Настройка MultiBinder', binder_window, imgui.WindowFlags.NoResize)

		imgui.BeginChild("test", imgui.ImVec2(wmine-490, 305), true)
						imgui.Columns(2, "mycolumns")
						imgui.Separator()
						imgui.Text(u8"Активация") ShowHelpMarker("Двойной щелчок по пункту открывает\nнастройку редактора биндера") imgui.NextColumn()
						imgui.Text(u8"Статус") imgui.NextColumn()
			imgui.Separator()
			for i = 1, bind_slot do
				if imgui.Selectable(u8"Слот №" .. i, false, imgui.SelectableFlags.AllowDoubleClick) then
					if (imgui.IsMouseDoubleClicked(0)) then
						z = i
						if mainBind[i] == nil then
							imgui.OpenPopup("SetActivation")
						else
							imgui.OpenPopup("ReActivation")
						end
					end
				end
				imgui.NextColumn()
				if mainBind[i] ~= nil and mainBind[i].wait ~= nil and mainBind[i].act ~= nil then
					if change_binder == i and change_binder ~= nil and change_binder ~= "" then
						imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.8, 1.0), u8"Ред. | Занято")
					else
						imgui.TextColored(imgui.ImVec4(0.8, 0.7, 0.1, 1.0), mainBind[i].act) --u8"Занято"
						about_bind[i] = true
					end
				else
					if change_binder == i and change_binder ~= nil and change_binder ~= "" then
						imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.8, 1.0), u8"Редактируется")
					else
						imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), u8"Cвободно")
						about_bind[i] = false
					end
				end
				imgui.NextColumn()
			end
		if imgui.BeginPopup("ReActivation") then
			imgui.Text(u8"Выберите нужное действие для (Слот №" .. z .. ")")
			imgui.SetCursorPosX(20)
			if imgui.Button(u8"Удалить") then
				for i = 1, 30 do
					mainBind[z][i] = nil
				end
				mainBind[z].act = nil
				mainBind[z].wait = nil
				mainBind[z] = nil
				inicfg.save(mainBind, "moonloader\\mz\\binder.ini")
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Редактировать") then
				change_binder = z
				is_changeact = true
				binder_text[2].v = mainBind[z].act
				binder_text[3].v = mainBind[z].wait
				for g = 1, 30 do
					if mainBind[z][g] == nil then
						break
					else
						if g == 1 then
							binder_text[1].v = mainBind[z][g]
						else
							binder_text[1].v = binder_text[1].v .. "\n" .. mainBind[z][g]
						end
					end
				end
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть") then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopup("SetActivation") then
			imgui.Text(u8"Выберите нужную вам активацию для (Слот №" .. z .. ")")
			imgui.PushItemWidth(240)
			imgui.SetCursorPosX(30)
			imgui.Combo("", selected_item_binder, u8"На клавишу (комбинацию клавиш)\0На команду (прим. /command)\0\0")
			imgui.SetCursorPosX(85)
			if imgui.Button(u8"Выбрать") then
				change_binder = z
				binder_text[1].v = ""
				is_changeact = false
				if about_bind[z] then
					binder_text[2].v = mainBind[z].act
					binder_text[3].v = mainBind[z].wait
					for g = 1, 30 do
						if mainBind[z][g] == nil then
							break
						else
							if g == 1 then
								binder_text[1].v = mainBind[z][g]
							else
								binder_text[1].v = binder_text[1].v .. "\n" .. mainBind[z][g]
							end
						end
					end
				else
					binder_text[2].v = ""
					binder_text[3].v = ""
				end

				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			imgui.SetCursorPosX(155)
			if imgui.Button(u8"Закрыть") then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if bind_slot < 15 then
			imgui.Columns(1)
			imgui.Separator()
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("notest", imgui.ImVec2(wmine-(wmine-490)+25, 305), true)

		if change_binder ~= nil and change_binder ~= "" then
			imgui.SetCursorPosY(5)
			ShowCenterTextColor(u8("Редакторивание профиля биндера (Слот №" .. change_binder .. ")"), wmine-200, imgui.ImVec4(0.8, 0.7, 0.1, 1.0))
			imgui.Separator()

			if not is_changeact then

				if selected_item_binder.v == 0 then
					imgui.BeginChild("change", imgui.ImVec2(118, 20), true)
					imgui.SetCursorPosY(2)
					imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.7, 1.0), getDownKeysText())
					imgui.EndChild()
					imgui.SameLine()
					imgui.SetCursorPosY(28)
					imgui.Text(u8"Зажмите клавишу/комбинацию клавиш и нажмите")
					imgui.SameLine()
					if imgui.Button(u8("Сохранить")) then
						if getDownKeysText() ~= "None" then
							binder_text[2].v = getDownKeysText()
							is_changeact = true
						else
							AddChatMessage("Зажмите клавишу/клавиши, после чего повторите попытку")
						end
					end
				else
					imgui.Text(u8"Активация: /")
					imgui.SameLine()
					imgui.PushItemWidth(100)
					imgui.SetCursorPos(imgui.ImVec2(90, 26))
					imgui.InputText(u8"##1", binder_text[2])
					imgui.SameLine()
					if imgui.Button(u8"Сохранить") then
						if isReservedCommand(binder_text[2].v) then
							AddChatMessage("Введенная вами команда является зарезервированной скриптом. Придумайте другую")
						else
							if string.find(binder_text[2].v, '/', 1, true) then
								AddChatMessage('Знак "/" будет прикреплен к команде позже. В данный момент он не нужен')
							else
								is_changeact = true
								binder_text[2].v = "/" .. binder_text[2].v
							end
						end
					end
				end

			else
				imgui.SetCursorPosY(30)
				imgui.Text(u8"Активация:")
				imgui.SameLine()
				imgui.SetCursorPosY(30)
				imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), binder_text[2].v)
				imgui.SameLine()
				imgui.SetCursorPosY(28)
				if imgui.Button(u8("Изменить активацию")) then
					imgui.OpenPopup("ChangeActivation")
				end
			end

			if (imgui.BeginPopup("ChangeActivation")) then
				imgui.Text(u8"Выберите нужную вам активацию для (Слот №" .. z .. ")")
				imgui.PushItemWidth(240)
				imgui.SetCursorPosX(30)
				imgui.Combo("", selected_item_binder, u8"На клавишу (комбинацию клавиш)\0На команду (прим. /command)\0\0")
				imgui.SetCursorPosX(85)
				if imgui.Button(u8"Выбрать") then
					if selected_item_binder.v == 1 then
						if binder_text[2].v ~= "" then
							if string.find(binder_text[2].v, '/', 1, true) then
								binder_text[2].v = string.sub(binder_text[2].v, 2)
							else
								binder_text[2].v = ""
							end
						end
					end
					is_changeact = false
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(155)
				if imgui.Button(u8"Закрыть") then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end

			imgui.Text(u8"Задержка:")
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputText(u8'сек.', binder_text[3], imgui.InputTextFlags.CharsDecimal)
			imgui.SameLine()
			if imgui.Checkbox(u8"Блокировка движений персонажа", cb_lock_player) then
				imgui.LockPlayer = cb_lock_player.v
			end
			imgui.Separator()
			ShowCenterTextColor(u8("Вводимый текст биндера (для переноса строки нажать Enter)"), wmine-200, imgui.ImVec4(0.8, 0.7, 0.1, 1.0))
			imgui.InputTextMultiline(u8'##3', binder_text[1], imgui.ImVec2(500, 178))
			imgui.SetCursorPosX(120)
			if imgui.Button(u8("Сохранить"), imgui.ImVec2(120, 20)) then
				if binder_text[3].v == "" then
					binder_text[3].v = 0
				end
				if binder_text[1].v == "" or binder_text[2].v == "" then
					AddChatMessage("Заполните все поля!")
				else
					for i = 1, 30 do
						if mainBind[change_binder] ~= nil then
							if mainBind[change_binder][i] ~= nil then
								mainBind[change_binder][i] = nil
							else
								break
							end
						else
							break
						end
					end
					i = 0
					for s in string.gmatch(binder_text[1].v, "[^\r\n]+") do
						i = i + 1
						if mainBind[change_binder] == nil then
							mainBind[change_binder] = {}
						end
						mainBind[change_binder][i] = s
					end
					mainBind[change_binder].act = binder_text[2].v
					mainBind[change_binder].wait = binder_text[3].v
					inicfg.save(mainBind, bindPath)
					AddChatMessage("Данные биндера успешно сохранены!")
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(260)
			if imgui.Button(u8("Отмена"), imgui.ImVec2(120, 20)) then
				change_binder = ""
			end

		end

		imgui.EndChild()
		imgui.End()
	end
end
