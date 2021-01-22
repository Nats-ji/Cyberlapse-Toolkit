registerForEvent("onInit", function()
	rootPath = "./plugins/cyber_engine_tweaks/mods/timelapse_toolkit/"
	CPS = require(rootPath.."CPStyling")
	theme = CPS.theme
	color = CPS.color
	ts = Game.GetTimeSystem()
	TimeDilation = 1
	IsPaused = false
	air_traffic = true
	autosave = true
	boostLOD = false
	crowd = true
	timeH = 12
	timeM = 0
	timeS = 0
    drawWindow = false
    trapInput = false
	TimeDilationFS = 0
	camFOV = 80
	camZoom = 1
    print("Timelapse Toolkit Loaded. Press Ctrl+T to open menu.")
  end)
registerForEvent("onUpdate", function()
	if (ImGui.IsKeyDown(0x11) and ImGui.IsKeyPressed(0x54, false)) then
		drawWindow = not drawWindow
    end
end)
registerForEvent("onDraw", function()
	if (drawWindow) then
		ImGui.SetNextWindowPos(0,500, ImGuiCond.FirstUseEver)
		if (ImGui.Begin("Timelapse Toolkit")) then
			if (not IsTrapInputInImGui()) then
				inputFlagsExtra = ImGuiInputTextFlags.ReadOnly
			else
				inputFlagsExtra = ImGuiInputTextFlags.None
			end
			ImGui.Text("Time")
			ImGui.PushItemWidth(30)
			timeH = ImGui.InputInt("h:", timeH, 0, 23, inputFlagsExtra)
			ImGui.SameLine(58)
			timeM = ImGui.InputInt("m:", timeM, 0, 59, inputFlagsExtra)
			ImGui.SameLine(108)
			timeS = ImGui.InputInt("s", timeS, 0, 59, inputFlagsExtra)
			ImGui.SameLine(158)
			btnSetTime = ImGui.Button("Set Time")
			if (btnSetTime) then
				ts:SetGameTimeByHMS(timeH, timeM, timeS)
			end
			ImGui.SameLine(230)
			btnGetTime = ImGui.Button("Get Current Time")

			ImGui.PushItemWidth(250)
			TimeDilation = ImGui.SliderInt("", TimeDilation, 1, 10, "%dx")
			ImGui.SameLine(265)
			ImGui.PushItemWidth(70)
			TimeDilationFS = ImGui.Combo("", TimeDilationFS, "Faster\0Slower\0")
			ImGui.SameLine(345)
			btnSetTimeDilation = ImGui.Button("Set Time Dilation")
			IsPaused, IsPaused_checked = ImGui.Checkbox("Stop Day/Night Cycle", IsPaused)
			ImGui.Separator()
			ImGui.Text("Camera Movement (Currently not working)")
			ImGui.PushItemWidth(250)
			camFOV = ImGui.SliderInt("Field of Veiw", camFOV, 30, 150, "%d degrees")
			ImGui.PushItemWidth(250)
			camZoom = ImGui.SliderInt("Zoom", camZoom, 1, 10, "%dx")
			ImGui.Separator()
			ImGui.Text("Location")
			btnGetLocation = ImGui.Button("Get Current Location")
			btnSaveLocation = ImGui.Button("Save Location...")
			btnLoadLocation = ImGui.Button("Load Location...")
			ImGui.Separator()
			ImGui.Text("Misc")
			air_traffic, air_traffic_checked = ImGui.Checkbox("Enable Air Traffic (Useful for doing astrophotography near the city)", air_traffic)
			crowd, crowd_checked = ImGui.Checkbox("Enable Crowd (NPC pedestrians and vehicles)", crowd)
			autosave, autosave_checked = ImGui.Checkbox("Enable Auto Save", autosave)
			boostLOD, boostLOD_checked = ImGui.Checkbox("Boost Decals Hide Distance", boostLOD)
			btnSaveConfig = ImGui.Button("Save Config...")
			btnLoadConfig = ImGui.Button("Load Config...")
			btnDefault = ImGui.Button("Default")
			-- veh = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(),false,false)
			-- veh:TurnOn(true)
		end
		ImGui.End()
	end
end)
