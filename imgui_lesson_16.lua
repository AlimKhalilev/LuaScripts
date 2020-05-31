script_name('Autoupdate script') -- название скрипта
script_author('FORMYS') -- автор скрипта
script_description('Autoupdate') -- описание скрипта

require "lib.moonloader" -- подключение библиотеки
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local script_vers = 1
local script_vers_text = "1"
local script_path = thisScript().path
local script_url = thisScript().path
local update_path = getWorkingDirectory() .. "/update.ini"
local update_url = "https://raw.githubusercontent.com/AlimKhalilev/LuaScripts/master/update.ini"


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    sampRegisterChatCommand("update", cmd_update)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then

            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Обнаружено обновление, новая версия скрипта: {FF00FF}" .. updateIni.info.vers_text, -1)
                sampAddChatMessage(script_path, -1)
                downloadUrlToFile(script_url, script_path, function(id, status)
                    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                        thisScript():reload()
                        sampAddChatMessage("Новая версия скрипта успешно скачана и запущена!", -1)
                    end
                end)
            else
                sampAddChatMessage("Обновлений не обнаружено", -1)
            end

            os.remove(update_path)
        end
    end)
    
	while true do
		wait(0)

	end
end

function cmd_update(arg)
    sampShowDialog(1000, "Автообновление", "Это текст диалога", "Закрыть", "", 0)
end