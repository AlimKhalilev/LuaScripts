script_name('Imgui Script') -- �������� �������
script_author('FORMYS') -- ����� �������
script_description('Imgui') -- �������� �������

require "lib.moonloader" -- ����������� ����������
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local tag = "[My First Script]:" -- ��������� ����������
local label = 0
local main_color = 0x5A90CE
local main_color_text = "{5A90CE}"
local white_color = "{FFFFFF}"

local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)

local text_buffer_age = imgui.ImBuffer(256)
local text_buffer_name = imgui.ImBuffer(256)

-- for CHECKBOX
	local checked_test = imgui.ImBool(false)
	local checked_test_2 = imgui.ImBool(false)
--

-- for RADIO
	local checked_radio = imgui.ImInt(1)
--

-- for COMBO
	local combo_select = imgui.ImInt(0)
--

local sw, sh = getScreenResolution()

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
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)-- (0.1, 0.9, 0.1, 1.0)
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

	sampRegisterChatCommand("imgui1", cmd_imgui)
	sampRegisterChatCommand("imgui2", cmd_imgui2)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

	imgui.Process = false

	--sampAddChatMessage("������ imgui ������������", -1)

	while true do
		wait(0)

		if isKeyJustPressed(VK_F3) then
			sampAddChatMessage("�� ������ ������� {FFFFFF}F3." .. main_color_text .. "��� ���: {FFFFFF}" .. nick .. ", " .. main_color_text .. "��� ID: {FFFFFF}" .. id, main_color)
		end

		if isKeyDown(VK_MENU) and isKeyJustPressed(VK_9) then
			sampAddChatMessage("�� ����, �� ������ ���������� ������!", main_color)
			wait(500)
			sampAddChatMessage("������ ��� �������", main_color)
		end
		-- ���� ������������� ���������� (���� ���� �������)

	end
end

function cmd_imgui(arg)
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end

function cmd_imgui2(arg)
	secondary_window_state.v = not secondary_window_state.v
	imgui.Process = secondary_window_state.v
end

function imgui.OnDrawFrame()

	if not main_window_state.v and not secondary_window_state.v then
		imgui.Process = false
	end

	if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	
		imgui.Begin(u8"���������", main_window_state)
		imgui.PushItemWidth(120)
		imgui.InputText(u8'������� ��� ����', text_buffer_name)
		imgui.PushItemWidth(160)
		imgui.InputText(u8'������� ������� ����', text_buffer_age)
		x, y, z = getCharCoordinates(PLAYER_PED)
		imgui.Text(u8("������� ������: X:" .. math.floor(x) .. " | Y: " .. math.floor(y) .. " | Z: " .. math.floor(z)))
	
		--sampAddChatMessage(u8:decode(text_buffer_name.v), -1)
	
	
		imgui.SetCursorPosY(120) -- CHECKBOX
		imgui.Separator()
		imgui.SetCursorPosY(140)
		imgui.Text(u8"��� ���� �������")
		imgui.SameLine()
		imgui.SetCursorPosX(200)
		imgui.Checkbox(u8"Text1", checked_test)
		imgui.SameLine()
		imgui.Checkbox(u8"Text2", checked_test_2)
		imgui.SetCursorPosY(180)
	
		imgui.Separator() -- RADIO
	
		imgui.RadioButton("Test1", checked_radio, 1)
		imgui.SameLine()
		imgui.RadioButton("Test2", checked_radio, 2)
		imgui.SameLine()
		imgui.RadioButton("Test3", checked_radio, 3)
	
		sampAddChatMessage("test", 12)
	
	
		imgui.Separator() -- RADIO
	
		my_arr = {"text", "text2", "text3", "text4"}
		str_combo = "������� 1\0������� 2\0������� 3\0������� 4\0������� 5\0������� 6\0������� 7\0\0"
	
		my_arr = {u8"������", u8"����", u8"������ ����", u8"���� ������"}
		imgui.Combo(u8"", combo_select, my_arr, #my_arr)
		
	
		if imgui.Button("Go") then
			sampAddChatMessage(u8:decode(my_arr[combo_select.v + 1]), -1)
		end
	
		imgui.End()
	end

	if secondary_window_state.v then
		imgui.Begin(u8"��������� 2", secondary_window_state)
		imgui.Text(u8"������")
		imgui.End()
	end
	
	

end
