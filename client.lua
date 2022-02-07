local function StartPlaybackRecordedVehicleUsingAi(veh,num,str,flo,style)
	return Citizen.InvokeNative(0x29DE5FA52D00428C,veh, num, str, flo, style);
end 
local function StartPlaybackRecordedVehicleWithFlags(veh,num,str,flo,style)
	return Citizen.InvokeNative(0x7D80FD645D4DA346,veh, num, str, flo, style);
end 
local lists = {} 
local defaultRouteName = "test"
local defaultRouteId = 1
local IsAnythingRecording = false 
local DisablePopulationWhileRecording = true 
local TransferServerDataListMax = 100
local RecordingFrameTime = 0
local nowcarhash = `osiris`
CreateThread(function()
	while true do Wait(0)
		if IsAnythingRecording and DisablePopulationWhileRecording then 
			SetVehiclePopulationBudget(0)
			SetPedPopulationBudget(0)
		end 
	end 
end)

Command = setmetatable({},{__newindex=function(t,k,fn) RegisterCommand(k,function(source, args, raw) fn(table.unpack(args)) end) return end })

Command["car"] = function(veh)   
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5))
    if veh == nil then veh = "adder" end
    vehiclehash = GetHashKey(veh)
	RequestModel(vehiclehash)
	while not HasModelLoaded(vehiclehash)  do Wait(100) end 
	local vehicle = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId())+90, 1, 0)
	SetPedIntoVehicle(PlayerPedId(), vehicle, -1);
	nowcarhash = vehiclehash
end

Command["record"] = function(action, routeName, routeId, other)
	if action == "start" then 
		local routeName = routeName or defaultRouteName
		local routeId = routeId or defaultRouteId
		local isboost = (not not other) or PlayerPedId()
		if not IsAnythingRecording then 
			CreateThread(function()
				print("RecordStarted:", string.format("%s%03d", routeName,routeId) ..'.ovr',"Boost:"..tostring(isboost))
				RecordStart(routeName,routeId,isboost) 
			end)
		else 
			print("something is recording...")
		end 
	elseif action == "stop" then 
		if RecordEnd then RecordEnd (); print("RecordEnd Make sure transfer your ovr to yvr with OpenIV or something.")  end 
	elseif action == "play" then 
		if not IsAnythingRecording then 
			local routeName = routeName or defaultRouteName
			local routeId = routeId or defaultRouteId
			local ped = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(ped,false)
			local ai = (not not other) 
			RequestModel(nowcarhash)
			RequestModel(`a_m_y_soucent_04`)
			while not HasModelLoaded(nowcarhash) or not HasModelLoaded(`a_m_y_soucent_04`)  do Wait(100) end 
			if ai then 
				
				local coord = GetEntityCoords(PlayerPedId())
				if vehicle == 0 then 
					vehicle = CreateVehicle(nowcarhash,coord.x,coord.y+3.0,coord.z+3.0, 0.0, 1, 0)
					ped = CreatePedInsideVehicle(vehicle --[[ Vehicle ]],4 --[[ integer ]],`a_m_y_soucent_04` --[[ Hash ]],-1 --[[ integer ]],true --[[ boolean ]],true --[[ boolean ]])
					SetPedIntoVehicle(PlayerPedId(), vehicle, 0);
				else 
					SetEntityCoords(PlayerPedId(),GetEntityCoords(vehicle))
					ped = CreatePedInsideVehicle(vehicle --[[ Vehicle ]],4 --[[ integer ]],`a_m_y_soucent_04` --[[ Hash ]],-1 --[[ integer ]],true --[[ boolean ]],true --[[ boolean ]])
					SetPedIntoVehicle(PlayerPedId(), vehicle, 0);
				end 
			else 

				local coord = GetEntityCoords(PlayerPedId())
				if vehicle == 0 then 
					vehicle = CreateVehicle(nowcarhash,coord.x,coord.y+3.0,coord.z+3.0, 0.0, 1, 0)
				else 
					local driver = GetPedInVehicleSeat(vehicle,-1)
					if driver ~= PlayerPedId() then 
						DeleteEntity(driver)
					end 
				end 
				SetPedIntoVehicle(PlayerPedId(), vehicle, -1);
			end 
			SetEntityProofs(ped, true, true, true, true, true, true, true, true);
			SetEntityProofs(vehicle, true, true, true, true, true, true, true, true);
			print(vehicle,ped)
			PlayRecordOnVehicle(vehicle,routeName or defaultRouteName, routeId or defaultRouteId, ai )
			print("Playing Record:", string.format("%s%03d", routeName or defaultRouteName,routeId or defaultRouteId) ..'.yvr')
		else 
			print("something is recording...")
		end 
	end 
end
function PlayRecordOnVehicle(vehicle,routeName,routeId,ai,speed) --race001, "race",1
	local vehicle = tonumber(vehicle)
	local routeId = tonumber(routeId)
	local routeName = tostring(routeName)
	RequestVehicleRecording(routeId,routeName)
	--print("Loading record on "..vehicle.." ...",routeId,routeName)
	while not HasVehicleRecordingBeenLoaded(routeId,routeName) do 
		Wait(1000)
	end 
	print("Loading Sucessed")
	if (HasVehicleRecordingBeenLoaded(routeId,routeName)) then 
		if (IsVehicleDriveable(vehicle, 0)) then 
			--print(ai,vehicle,routeId,routeName)
			if ai then 
				StartPlaybackRecordedVehicle(vehicle, routeId, routeName, true);--teleport to record start position
				Wait(500)
				if IsPlaybackGoingOnForVehicle(vehicle) then
					StopPlaybackRecordedVehicle(vehicle);
				end
				StartPlaybackRecordedVehicleUsingAi(vehicle, routeId, routeName, 5.0, 17039364); --npc ai driving according to the route
			else 
				StartPlaybackRecordedVehicle(vehicle, routeId, routeName, true);
			end 
		end 
	end 
	SetPlaybackSpeed(vehicle,speed or 1.0)
	SetVehicleActiveDuringPlayback(vehicle, true);
	--[=[
	if IsPlaybackGoingOnForVehicle(vehicle) then
		StopPlaybackRecordedVehicle(vehicle); -- just end
		SkipToEndAndStopPlaybackRecordedVehicle(vehicle); -- teleport to the record end position
	end
	--]=]
end 
function RecordStart(routename,routeid, ped)
	local StartTime = GetGameTimer()
	
	--录像加成
	if not IsPedInAnyVehicle(ped) then error("ped not in a vehicle",2) return end 
	IsAnythingRecording = true 
	local boostMyCar = (not not ped)
	local veh = GetVehiclePedIsIn(ped,false)
	if boostMyCar then 
		SetVehicleHandlingFloat(veh,"CHandlingData","fInitialDriveForce",0.456)
		SetVehicleHandlingFloat(veh,"CHandlingData","fClutchChangeRateScaleUpShift",4.8)
		SetVehicleHandlingFloat(veh,"CHandlingData","fClutchChangeRateScaleDownShift",4.8)
		SetVehicleHandlingFloat(veh,"CHandlingData","fInitialDriveMaxFlatVel",159.0)
		SetVehicleHandlingFloat(veh,"CHandlingData","fBrakeForce",1.0)
		SetVehicleHandlingFloat(veh,"CHandlingData","fBrakeBiasFront",0.0)
		SetVehicleHandlingFloat(veh,"CHandlingData","fTractionCurveMax",2.8)
		SetVehicleHandlingFloat(veh,"CHandlingData","fTractionCurveMin",2.6)
		SetVehicleHandlingFloat(veh,"CHandlingData","fDeformationDamageMult",0.0)
		SetVehicleHandlingFloat(veh,"CHandlingData","fEngineDamageMult",0.0)
		SetVehicleHandlingField(veh,"CHandlingData","AIHandling","SPORTS_CAR")
		MaxOut(ped,veh)
	end 
	print(1230)
	RecordEnd = function ()
		IsAnythingRecording = false 
	end 
	local lists = {}
	local first = false
	CreateThread(function()
		TriggerServerEvent('yvr_recorder:writeovrstart',routename,routeid)
		
		while IsAnythingRecording do 
			local infos = {} 
			
			local veh = GetVehiclePedIsIn(ped,false)
			local Coords = GetEntityCoords(veh)
			local Velocity = GetEntitySpeedVector(veh,false) *1.0
			if (not first and #Velocity > 0.0) or (first) then 
				local Power = GetVehicleClutch(veh) *1.0
				local Break = GetVehicleWheelBrakePressure(veh) *1.0
				--local Right,b,Top = GetEntityMatrix(veh)
				local Top , Right , _ , Position = GetEntityMatrix(veh)
				
				local text = ""
				infos.Time= GetGameTimer()-StartTime
				infos.Position = Position --Coords
				infos.Velocity = Velocity
				
				infos.Right = Right
				infos.Top = Top
				infos.SteeringAngle = GetVehicleSteeringAngle(veh) * math.pi / 180
				infos.GasPedalPower = Power
				infos.BreakPedalPower = Break
				infos.UseHandBrake = GetVehicleHandbrake(veh) and "true" or "false"
				if not first then infos.Time = 0 end 
				table.insert(lists,infos)
				if lists and (#(lists) > TransferServerDataListMax or not first) then 
					first = true 
					TriggerServerEvent('yvr_recorder:writeovrline',routename,routeid,lists)
					lists = {}
				end 
			end 
			Wait(RecordingFrameTime)
		end 
		RecordEnd = nil 
		TriggerServerEvent('yvr_recorder:writeovrend',routename,routeid)
	end)
	
	
end 
function MaxOut(ped,veh)
if not veh then 
	veh = GetVehiclePedIsIn(ped, false)
end 
    SetVehicleModKit(veh, 0)
    --SetVehicleWheelType(veh, 0) -- sport 
	--SetVehicleMod(veh, 23, 21, false) -- 超级五号
    SetVehicleMod(veh, 0, GetNumVehicleMods(veh, 0) - 1, false)
    SetVehicleMod(veh, 1, GetNumVehicleMods(veh, 1) - 1, false)
    SetVehicleMod(veh, 2, GetNumVehicleMods(veh, 2) - 1, false)
    SetVehicleMod(veh, 3, GetNumVehicleMods(veh, 3) - 1, false)
    SetVehicleMod(veh, 4, GetNumVehicleMods(veh, 4) - 1, false)
    SetVehicleMod(veh, 5, GetNumVehicleMods(veh, 5) - 1, false)
    SetVehicleMod(veh, 6, GetNumVehicleMods(veh, 6) - 1, false)
    SetVehicleMod(veh, 7, GetNumVehicleMods(veh, 7) - 1, false)
    SetVehicleMod(veh, 8, GetNumVehicleMods(veh, 8) - 1, false)
    SetVehicleMod(veh, 9, GetNumVehicleMods(veh, 9) - 1, false)
    SetVehicleMod(veh, 10, GetNumVehicleMods(veh, 10) - 1, false)
    SetVehicleMod(veh, 11, GetNumVehicleMods(veh, 11) - 1, false)
    SetVehicleMod(veh, 12, GetNumVehicleMods(veh, 12) - 1, false)
    SetVehicleMod(veh, 13, GetNumVehicleMods(veh, 13) - 1, false)
    SetVehicleMod(veh, 14, 16, false)
    SetVehicleMod(veh, 15, GetNumVehicleMods(veh, 15) - 2, false)
    SetVehicleMod(veh, 16, GetNumVehicleMods(veh, 16) - 1, false)
    ToggleVehicleMod(veh, 17, true)
    ToggleVehicleMod(veh, 18, true)
    ToggleVehicleMod(veh, 19, true)
    ToggleVehicleMod(veh, 20, true)
    ToggleVehicleMod(veh, 21, true)
    ToggleVehicleMod(veh, 22, true)
    SetVehicleMod(veh, 24, 1, false)
    SetVehicleMod(veh, 25, GetNumVehicleMods(veh, 25) - 1, false)
    SetVehicleMod(veh, 27, GetNumVehicleMods(veh, 27) - 1, false)
    SetVehicleMod(veh, 28, GetNumVehicleMods(veh, 28) - 1, false)
    SetVehicleMod(veh, 30, GetNumVehicleMods(veh, 30) - 1, false)
    SetVehicleMod(veh, 33, GetNumVehicleMods(veh, 33) - 1, false)
    SetVehicleMod(veh, 34, GetNumVehicleMods(veh, 34) - 1, false)
    SetVehicleMod(veh, 35, GetNumVehicleMods(veh, 35) - 1, false)
    SetVehicleMod(veh, 38, GetNumVehicleMods(veh, 38) - 1, true)
    SetVehicleWindowTint(veh, 1)
    SetVehicleTyresCanBurst(veh, false)
    SetVehicleNumberPlateTextIndex(veh, 5)
end