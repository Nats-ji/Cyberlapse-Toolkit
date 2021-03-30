-- Cyberlapse Toolkit is a toolkit with a simple GUI for making timelapse
-- videos and specialized screenshots inside Cyberpunk 2077.

-- Copyright (C) 2021 Mingming Cui
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

registerForEvent("onInit", function()
	CPS = require("CPStyling")
	theme = CPS.theme
	color = CPS.color
	wWidth, wHeight = GetDisplayResolution()
	TimeSystem = Game.GetTimeSystem()

  drawWindow = false
	drawBody = true

	Settings = {
		AspectRatio = wWidth / wHeight,
		timeH = 12,
		timeM = 0,
		timeS = 0,
		IsTimePaused = false,
		TimeDilation = 1,
		TimeDilationSilderText = "%dx Time Dilation",
		TimeDilationFS = 0,
		NoSpeedUpTime = true,
		HFOV = 80,
		Zoom = 1,
		CameraPos = ToVector4{ x = 0.0, y = 0.0, z = 0.0, w = 1.0 },
		CameraOrientation = ToQuaternion{ i = 0.0, j = 0.0, k = 0.0, r = 1.0 },
		AirTraffic = false,
		Crowd = false,
		Autosave = false,
		BoostLOD = false,
		CameraShake = false,
		CityLight = false,
	}
	if CPS.fileExists("icon.png") then
		icon = CPS.loadPNG("icon.png")
	else
		icon = nil
	end
    print("Timelapse Toolkit Loaded.")
  end)

-- registerHotkey("open_overlay", "Open Interface", function()
-- 	drawWindow = not drawWindow
-- 	UpdateSettings()
-- end)

registerForEvent("onUpdate", function()
	if btnSetTime then
		TimeSystem:SetGameTimeByHMS(Settings.timeH, Settings.timeM, Settings.timeS)
	end
	if btnGetTime then
		local GameTime = TimeSystem:GetGameTime()
		Settings.timeH = GameTime:Hours(GameTime)
		Settings.timeM = GameTime:Minutes(GameTime)
		Settings.timeS = GameTime:Seconds(GameTime)
	end
	if sldTimeDilation then
		if Settings.TimeDilation == 1 then
			Game.SetTimeDilation(1)
			Settings.TimeDilationSilderText = "%dx Time Dilation"
			if Settings.NoSpeedUpTime == false then
				GameOptions.SetBool("CrowdMovement", "NoSpeedUpTime", true)
				Settings.NoSpeedUpTime = true
			end
		elseif Settings.TimeDilationFS == 0 then
			Game.SetTimeDilation(Settings.TimeDilation)
			if Settings.NoSpeedUpTime == true then
				GameOptions.SetBool("CrowdMovement", "NoSpeedUpTime", false)
				Settings.NoSpeedUpTime = false
			end
		elseif Settings.TimeDilationFS == 1 then
			Settings.TimeDilationSilderText = "1/%dx Time Dilation"
			Game.SetTimeDilation(1/Settings.TimeDilation)
		end
	end
	if cobTimeDilationFS then
		if Settings.TimeDilationFS == 0 then
			Game.SetTimeDilation(Settings.TimeDilation)
			GameOptions.SetBool("CrowdMovement", "NoSpeedUpTime", false)
			Settings.TimeDilationSilderText = "%dx Time Dilation"
		elseif Settings.TimeDilationFS == 1 and Settings.TimeDilation ~= 1 then
			Game.SetTimeDilation(1/Settings.TimeDilation)
			GameOptions.SetBool("CrowdMovement", "NoSpeedUpTime", true)
			Settings.TimeDilationSilderText = "1/%dx Time Dilation"
		end
	end
	if btnResetTimeDilation then
		Settings.TimeDilation = 1
		Settings.TimeDilationFS = 0
		Game.SetTimeDilation(1)
		GameOptions.SetBool("CrowdMovement", "NoSpeedUpTime", true)
	end
	if cbIsTimePaused then
		if Settings.IsTimePaused then
			TimeSystem:SetPausedState(true, nil)
		else
			TimeSystem:SetPausedState(false, nil)
		end
	end
	if btnResetCam then
		local VFOV = math.deg(2 * math.atan( math.tan(math.rad(40)) / Settings.AspectRatio ))
		Settings.HFOV = 80
		Settings.Zoom = 1
		Settings.CameraPos = ToVector4{ x = 0.0, y = 0.0, z = 0.0, w = 1.0 }
		Settings.CameraOrientation = ToQuaternion{ i = 0.0, j = 0.0, k = 0.0, r = 1.0 }
		Game.GetPlayer():GetFPPCameraComponent():SetFOV(VFOV)
		Game.GetPlayer():GetFPPCameraComponent():SetZoom(1)
		Game.GetPlayer():GetFPPCameraComponent():SetLocalPosition(ToVector4{ x = 0.0, y = 0.0, z = 0.0, w = 1.0 })
		Game.GetPlayer():GetFPPCameraComponent():SetLocalOrientation(ToQuaternion{ i = 0.0, j = 0.0, k = 0.0, r = 1.0 })
	end
	if sldHFOV then
		local VFOV = math.deg(2 * math.atan( math.tan(math.rad(Settings.HFOV/2)) / Settings.AspectRatio ))
		Game.GetPlayer():GetFPPCameraComponent():SetFOV(VFOV)
	end
	if sldZoom then
		Game.GetPlayer():GetFPPCameraComponent():SetZoom(Settings.Zoom)
	end
	if sldCamX or sldCamY or sldCamZ then
		Game.GetPlayer():GetFPPCameraComponent():SetLocalPosition(Settings.CameraPos)
	end
	if sldCamI or sldCamJ or sldCamK then
		Game.GetPlayer():GetFPPCameraComponent():SetLocalOrientation(Settings.CameraOrientation)
	end
	if cbAirTraffic then
		if Settings.AirTraffic then
			Game.GetQuestsSystem():SetFactStr("air_traffic_off", 1)
		else
			Game.GetQuestsSystem():SetFactStr("air_traffic_off", 0)
		end
	end
	if cbCrowd then
		if Settings.Crowd then
			GameOptions.SetBool("Crowd", "Enabled", false)
		else
			GameOptions.SetBool("Crowd", "Enabled", true)
		end
	end
	if cbAutosave then
		if Settings.Autosave then
			GameOptions.SetBool("SaveConfig", "AutoSaveEnabled", false)
		else
			GameOptions.SetBool("SaveConfig", "AutoSaveEnabled", true)
		end
	end
	if cbBoostLOD then
		if Settings.BoostLOD then
			GameOptions.SetFloat("LevelOfDetail", "DecalsHideDistance", 120)
			GameOptions.SetFloat("LevelOfDetail", "DynamicDecalsHideDistance", 60)
		else
			GameOptions.SetFloat("LevelOfDetail", "DecalsHideDistance", 40)
			GameOptions.SetFloat("LevelOfDetail", "DynamicDecalsHideDistance", 20)
		end
	end
	if cbCameraShake then
		local settings = Game.GetSettingsSystem():GetRootGroup():GetGroups(true)
		local gameplay_ss = settings[3]:GetGroups(true)
		local acessibility_ss = gameplay_ss[1]:GetVars(true)
		local camshake_ss = acessibility_ss[4]
		if Settings.CameraShake then
			camshake_ss:SetIndex(0)
			Game.GetSettingsSystem():ConfirmChanges()
		else
			camshake_ss:SetIndex(2)
			Game.GetSettingsSystem():ConfirmChanges()
		end
	end
	if cbCityLight then
		local scriptSystem =  Game.GetScriptableSystemsContainer()
    local cityLightSystem = scriptSystem:Get('CityLightSystem')
		if Settings.CityLight then
			cityLightSystem:AddForcedStateRequest("ForcedOFF", "DEBUG", "Absolute", false)
      cityLightSystem.state = 2
		else
			cityLightSystem:AddForcedStateRequest("DEFAULT", "DEBUG", "Absolute", false)
      cityLightSystem.state = 0
		end
		cityLightSystem:UpdateCLSForcedState()
	end
	if btnVehicleLight then
		local target = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(),false,false)
		if target:IsVehicle() then
			if target:GetVehiclePS():GetVehicleControllerPS().lightMode.value == "Off" then
				target:GetVehiclePS():GetVehicleControllerPS():SetLightMode(2)
			else
				target:GetVehiclePS():GetVehicleControllerPS():SetLightMode(0)
			end
		end
	end
end)

registerForEvent("onDraw", function()
	if (drawWindow) then
		CPS.setThemeBegin()
		ImGui.SetNextWindowPos(0,500, ImGuiCond.FirstUseEver)
		ImGui.Begin("Cyberlapse Toolkit", true, bit32.bor(ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.AlwaysAutoResize))

		if icon then
			CPS.CPDraw("icon", icon, 1)
			if ImGui.IsItemClicked() then drawBody = not drawBody end
			ImGui.SameLine()
			ImGui.AlignTextToFramePadding()
		end
		ImGui.Text("Cyberlapse Toolkit")

		if drawBody then
			ImGui.Dummy(0,10)
			ImGui.Text("Time")
			ImGui.PushItemWidth(30)
			Settings.timeH = ImGui.InputInt("h:", Settings.timeH, 0, 23)
			ImGui.SameLine()
			Settings.timeM = ImGui.InputInt("m:", Settings.timeM, 0, 59)
			ImGui.SameLine()
			Settings.timeS = ImGui.InputInt("s", Settings.timeS, 0, 59)
			ImGui.PopItemWidth()
			ImGui.SameLine()
			btnSetTime = ImGui.Button("Set Time")
			ImGui.SameLine()
			btnGetTime = ImGui.Button("Get Current Time")

			ImGui.PushItemWidth(200)
			Settings.TimeDilation, sldTimeDilation = ImGui.SliderInt("##TimeDilation", Settings.TimeDilation, 1, 10, Settings.TimeDilationSilderText)
			ImGui.PopItemWidth()
			ImGui.SameLine()
			ImGui.PushItemWidth(70)
			Settings.TimeDilationFS, cobTimeDilationFS = ImGui.Combo("##TimeDilationFS", Settings.TimeDilationFS, "Faster\0Slower\0")
			ImGui.PopItemWidth()
			ImGui.SameLine()
			btnResetTimeDilation = ImGui.Button("Reset##TimeDilation")
			Settings.IsTimePaused, cbIsTimePaused = ImGui.Checkbox("Stop Day/Night Cycle", Settings.IsTimePaused)
			ImGui.Separator()
			ImGui.Spacing()
			ImGui.AlignTextToFramePadding()
			ImGui.Text("Camera Control")
			ImGui.SameLine()
			btnResetCam = ImGui.Button("Reset Camera")
			ImGui.PushItemWidth(200)
			Settings.HFOV, sldHFOV = ImGui.SliderFloat("Field of Veiw", Settings.HFOV, 30, 150, "%.0f degrees")
			Settings.Zoom, sldZoom = ImGui.SliderFloat("Zoom", Settings.Zoom, 1, 10, "%.0fx")
			Settings.CameraPos.x, sldCamX = ImGui.SliderFloat("Camera Left Right", Settings.CameraPos.x, -20, 20, "%.1f")
			Settings.CameraPos.y, sldCamY = ImGui.SliderFloat("Camera Forward Backward", Settings.CameraPos.y, -20, 20, "%.1f")
			Settings.CameraPos.z, sldCamZ = ImGui.SliderFloat("Camera Up Down", Settings.CameraPos.z, -20, 20, "%.1f")
			Settings.CameraOrientation.i, sldCamI = ImGui.SliderFloat("Camera Pitch", Settings.CameraOrientation.i, -180, 180, "%.2f", ImGuiSliderFlags.Logarithmic)
			Settings.CameraOrientation.j, sldCamJ = ImGui.SliderFloat("Camera Roll", Settings.CameraOrientation.j, -180, 180, "%.2f", ImGuiSliderFlags.Logarithmic)
			Settings.CameraOrientation.k, sldCamK = ImGui.SliderFloat("Camera Yaw", Settings.CameraOrientation.k, -180, 180, "%.2f", ImGuiSliderFlags.Logarithmic)
			ImGui.PopItemWidth()
			ImGui.Separator()
			-- ImGui.Text("Location")
			-- btnGetLocation = ImGui.Button("Get Current Location")
			-- btnSaveLocation = ImGui.Button("Save Location...")
			-- btnLoadLocation = ImGui.Button("Load Location...")
			-- ImGui.Separator()
			ImGui.Text("Misc")
			Settings.AirTraffic, cbAirTraffic = ImGui.Checkbox("Disable Air Traffic (Useful for astrophotography)", Settings.AirTraffic)
			Settings.Crowd, cbCrowd = ImGui.Checkbox("Disable Crowd (NPC pedestrians and vehicles)", Settings.Crowd)
			Settings.Autosave, cbAutosave = ImGui.Checkbox("Disable Auto Save", Settings.Autosave)
			Settings.BoostLOD, cbBoostLOD = ImGui.Checkbox("Boost Level of Details Distance", Settings.BoostLOD)
			Settings.CameraShake, cbCameraShake = ImGui.Checkbox("Disable Camera Shake", Settings.CameraShake)
			Settings.CityLight, cbCityLight = ImGui.Checkbox("Turn off street lights", Settings.CityLight)
			btnVehicleLight = ImGui.Button("Toggle Vehicle Light")
			ImGui.SameLine()
			ImGui.AlignTextToFramePadding()
			ImGui.Text("For using as flash lights")
		end

		ImGui.End()
		CPS.setThemeEnd()
	end
end)

registerForEvent("onOverlayOpen", function()
	drawWindow = true
	UpdateSettings()
end)
registerForEvent("onOverlayClose", function()
	drawWindow = false
end)

function UpdateSettings()
	Settings.IsTimePaused = TimeSystem:IsPausedState()
	Settings.HFOV = math.deg(2 * math.atan( math.tan(math.rad(Game.GetPlayer():GetFPPCameraComponent():GetFOV()/2)) * Settings.AspectRatio ))
	Settings.Zoom = Game.GetPlayer():GetFPPCameraComponent():GetZoom()
	Settings.CameraPos = Game.GetPlayer():GetFPPCameraComponent():GetLocalPosition()
	Settings.CameraOrientation = Game.GetPlayer():GetFPPCameraComponent():GetLocalOrientation()
	if Game.GetQuestsSystem():GetFactStr("air_traffic_off") == 0 then Settings.AirTraffic = false else Settings.AirTraffic = true end
	Settings.Crowd = not GameOptions.GetBool("Crowd", "Enabled")
	Settings.Autosave = not GameOptions.GetBool("SaveConfig", "AutoSaveEnabled")
	if GameOptions.GetFloat("LevelOfDetail", "DecalsHideDistance") == 40 and GameOptions.GetFloat("LevelOfDetail", "DynamicDecalsHideDistance") == 20 then Settings.BoostLOD = false else Settings.BoostLOD = true end
	local settings = Game.GetSettingsSystem():GetRootGroup():GetGroups(true)
	local gameplay_ss = settings[3]:GetGroups(true)
	local acessibility_ss = gameplay_ss[1]:GetVars(true)
	local camshake_ss = acessibility_ss[4]
	if camshake_ss:GetIndex() == 0 then Settings.CameraShake = true else Settings.CameraShake = false end
	local scriptSystem =  Game.GetScriptableSystemsContainer()
	local cityLightSystem = scriptSystem:Get('CityLightSystem')
	if cityLightSystem:GetState().value == "ForcedOFF" then Settings.CityLight = true else Settings.CityLight = false end
end
