local QBCore = exports["qb-core"]:GetCoreObject();
CreateThread(function()
	if Config.Target == "OX" then
		for k, v in pairs(Config.LockerZone) do
			local length = v.length or 1.5;
			local width = v.width or 1.5;
			exports.ox_target:AddBoxZone("LockerZone" .. k, v.coords, length, width, {
				name = "LockerZone" .. k,
				heading = v.heading,
				debugPoly = Config.Debug,
				minZ = v.minZ,
				maxZ = v.maxZ
			}, {
				options = {
					{
						event = "qb-lockers:OpenMenu",
						icon = "fas fa-lock",
						label = "Open Locker",
						lockerArea = k
					}
				},
				onSelect = function()
					lib.callback("qb-lockers:getLockers", false, function(data)
						TriggerEvent("qb-lockers:OpenMenu", {
							locker = k,
							info = data
						});
					end, k);
				end,
				distance = v.DrawDistance
			});
		end;
	elseif Config.Target == "QB" then
		for k, v in pairs(Config.LockerZone) do
			local length = v.length or 1.5;
			local width = v.width or 1.5;
			exports["qb-target"]:AddBoxZone("LockerZone" .. k, v.coords, length, width, {
				heading = v.heading,
				debugPoly = Config.Debug,
				minZ = v.minZ,
				maxZ = v.maxZ,
				name = "LockerZone" .. k
			}, {
				options = {
					{
						event = "qb-lockers:OpenMenu",
						icon = "fas fa-lock",
						label = "Open Locker",
						lockerArea = k,
						action = function()
							lib.callback("qb-lockers:getLockers", false, function(data)
								TriggerEvent("qb-lockers:OpenMenu", {
									locker = k,
									info = data
								});
							end, k);
						end
					}
				},
				distance = v.DrawDistance
			});
		end;
	else
		for k, v in pairs(Config.LockerZone) do
			v.point = lib.points.new(v.coords, v.DrawDistance);
			function v.point:nearby()
				DrawText3Ds(v.coords.x, v.coords.y, v.coords.z + 1, "Press ~r~[G]~s~ To Open ~y~Locker~s~");
				DisableControlAction(0, 47);
				if IsDisabledControlJustPressed(0, 47) then
					lib.callback("qb-lockers:getLockers", false, function(data)
						TriggerEvent("qb-lockers:OpenMenu", {
							locker = k,
							info = data
						});
					end, k);
				end;
			end;
		end;
	end;
end);
RegisterNetEvent("qb-lockers:OpenMenu", function(data)
	lib.registerContext({
		id = "locker_menu",
		title = "Lockers",
		options = {
			["Create Locker"] = {
				description = "Create A Locker",
				arrow = true,
				event = "qb-lockers:CreateLocker",
				args = {
					locker = data.locker
				}
			},
			["Open Locker"] = {
				description = "Open Existing Locker",
				arrow = true,
				event = "qb-lockers:LockerList",
				args = {
					arg = data.info,
					locker = data.locker
				}
			},
			["Open Your Locker"] = {
				description = "Open Self Locker",
				arrow = true,
				event = "qb-lockers:OpenSelfLocker",
				args = {
					arg = data.info,
					locker = data.locker
				}
			},
			["Delete Locker"] = {
				description = "Delete Existing Locker",
				arrow = true,
				event = "qb-lockers:LockerListDelete",
				args = {
					arg = data.info,
					locker = data.locker
				}
			},
			["Change Locker Password"] = {
				description = "Change Existing Locker Password",
				arrow = true,
				event = "qb-lockers:LockerChangePass",
				args = {
					arg = data.info,
					locker = data.locker
				}
			}
		}
	});
	lib.showContext("locker_menu");
end);
RegisterNetEvent("qb-lockers:LockerList", function(data)
	local optionTable = {};
	local arg = data.arg;
	local idt = 2;
	if arg then
		for k, v in pairs(arg) do
			idt = idt + 1;
			optionTable["Locker ID: " .. v.id] = {
				description = "Citizen: " .. v.playername,
				arrow = true,
				event = "qb-lockers:client:OpenLocker",
				args = v
			};
		end;
	end;
	lib.registerContext({
		id = "locker_list",
		title = data.locker .. " Locker Menu",
		menu = "locker_menu",
		options = optionTable
	});
	lib.showContext("locker_list");
end);
RegisterNetEvent("qb-lockers:LockerChangePass", function(data)
	local plyIdentifier = (QBCore.Functions.GetPlayerData()).citizenid;
	local lockers = data.arg;
	if lockers then
		local exist = false;
		for k, v in pairs(lockers) do
			if plyIdentifier == v.citizenid then
				exist = true;
				TriggerEvent("qb-lockers:client:ChangePassword", {
					data = v
				});
			end;
		end;
		if not exist then
			QBCore.Functions.Notify("You dont have a locker", "error", 5000);
		end;
	else
		QBCore.Functions.Notify("You dont have a locker", "error", 5000);
	end;
end);
RegisterNetEvent("qb-lockers:LockerListDelete", function(data)
	local plyIdentifier = (QBCore.Functions.GetPlayerData()).citizenid;
	local lockers = data.arg;
	if lockers then
		local exist = false;
		for k, v in pairs(lockers) do
			if plyIdentifier == v.citizenid then
				exist = true;
				TriggerEvent("qb-lockers:client:DeleteLocker", {
					data = v,
					id = v.lockerid
				});
			end;
		end;
		if not exist then
			QBCore.Functions.Notify("You dont have a locker", "error", 5000);
		end;
	else
		QBCore.Functions.Notify("You dont have a locker", "error", 5000);
	end;
end);
RegisterNetEvent("qb-lockers:client:ChangePassword", function(info)
	local data = info.data;
	local id = data.lockerid;
	local input = lib.inputDialog("Lockers", {
		{
			type = "input",
			label = "Locker Password",
			password = true,
			icon = "lock"
		}
	});
	if input and input[1] then
		TriggerServerEvent("qb-lockers:server:ChangePass", id, input[1]);
	end;
end);
RegisterNetEvent("qb-lockers:client:DeleteLocker", function(info)
	local id = info.id;
	lib.registerContext({
		id = "delete_locker_confirmation",
		title = "Delete Locker",
		menu = "locker_menu",
		options = {
			Confirm = {
				description = "Confirm Deletion of Your Locker",
				arrow = true,
				serverEvent = "qb-lockers:server:DeleteLocker",
				args = id
			},
			Cancel = {
				description = "Cancel Deletion of Your Locker",
				arrow = true,
				menu = "locker_menu"
			}
		}
	});
	lib.showContext("delete_locker_confirmation");
end);
function OpenLocker(lid)
	TriggerServerEvent("qb-lockers:openInventory", lid);
end;
RegisterNetEvent("qb-lockers:OpenSelfLocker", function(info)
	local plyIdentifier = (QBCore.Functions.GetPlayerData()).citizenid;
	local lockers = info.arg;
	if lockers then
		local exist = false;
		for k, v in pairs(lockers) do
			if plyIdentifier == v.citizenid then
				exist = true;
				OpenLocker(v.lockerid);
			end;
		end;
		if not exist then
			QBCore.Functions.Notify("You dont have a locker", "error", 5000);
		end;
	else
		QBCore.Functions.Notify("You dont have a locker", "error", 5000);
	end;
end);
RegisterNetEvent("qb-lockers:client:OpenLocker", function(info)
	local data = info;
	local input = lib.inputDialog("Lockers", {
		{
			type = "input",
			label = "Locker Password",
			password = true,
			icon = "lock"
		}
	});
	if input and input[1] then
		if tostring(input[1]) == tostring(data.password) then
			OpenLocker(data.lockerid);
		else
			QBCore.Functions.Notify("Wrong Password", "error", 5000);
		end;
	end;
end);
RegisterNetEvent("qb-lockers:CreateLocker", function(data)
	local area = data.locker;
	local input = lib.inputDialog("Lockers - Create Password", {
		{
			type = "input",
			label = "Locker Password",
			password = true,
			icon = "lock"
		}
	});
	if input and input[1] then
		TriggerServerEvent("qb-lockers:server:CreateLocker", input[1], area);
	end;
end);
function DrawText3Ds(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z);
	SetTextScale(0.32, 0.32);
	SetTextFont(4);
	SetTextProportional(1);
	SetTextColour(255, 255, 255, 255);
	SetTextEntry("STRING");
	SetTextCentre(1);
	AddTextComponentString(text);
	DrawText(_x, _y);
	local factor = string.len(text) / 500;
	DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 80);
end;
