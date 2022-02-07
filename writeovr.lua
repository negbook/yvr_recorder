CreateThread(function()
	local a = "recording path: "..GetResourcePath(GetCurrentResourceName())..'/stream/'..string.format("%s%03d", "name", 1) ..'.ovr'
	print(a)
end)
local F
RegisterServerEvent("yvr_recorder:writeovrstart")
AddEventHandler("yvr_recorder:writeovrstart", function (routename,routeid)
	local f,err = io.open(GetResourcePath(GetCurrentResourceName())..'/pre-stream/'..string.format("%s%03d", routename, routeid) ..'.ovr','w+')
	if not f then return print(err) end
	local line2 = "{\n"
	f:write("Version 1 30\n")
	f:write("{\n")
	F = f
end)
RegisterServerEvent("yvr_recorder:writeovrline")
AddEventHandler("yvr_recorder:writeovrline", function (routename,routeid, lists)
	if F then 
		local k = 1.0
		local f = F
		for i,infos in pairs(lists) do
			local Velocity,GasPedalPower,BreakPedalPower = infos.Velocity,infos.GasPedalPower,infos.BreakPedalPower
			local Position,Right,Top,SteeringAngle = infos.Position,infos.Right,infos.Top,infos.SteeringAngle
			f:write('	Item'..'\n')
			f:write('	{'..'\n')
			f:write('		Time '..string.format("%d",infos.Time)..'\n')
			f:write('		Position '..string.format("%.4f",Position.x) .. " " .. string.format("%.4f",Position.y) .. " "..string.format("%.4f",Position.z)..'\n')
			f:write('		Velocity '..string.format("%.4f",Velocity.x*k) .. " " .. string.format("%.4f",Velocity.y*k) .. " "..string.format("%.4f",Velocity.z*k)..'\n')
			f:write('		Right '..string.format("%.4f",Right.x) .. " " .. string.format("%.4f",Right.y) .. " "..string.format("%.4f",Right.z)..'\n')
			f:write('		Top '..string.format("%.4f",Top.x) .. " " .. string.format("%.4f",Top.y) .. " "..string.format("%.4f",Top.z)..'\n')
			f:write('		SteeringAngle '..string.format("%.4f",SteeringAngle)..'\n')
			f:write('		GasPedalPower '..string.format("%.4f",(GasPedalPower * k))..'\n')
			f:write('		BreakPedalPower '..string.format("%.4f",(BreakPedalPower * k))..'\n')
			f:write('		UseHandBrake '..infos.UseHandBrake..'\n')
			f:write('	}'..'\n')
		end
	end 
end)

RegisterServerEvent("yvr_recorder:writeovrend")
AddEventHandler("yvr_recorder:writeovrend", function (routename,routeid)
	if F then 
		local f = F
		f:write("}\n")
		f:close()
	end 
end)