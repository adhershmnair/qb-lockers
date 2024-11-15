local QBCore = nil;
CreateThread(function()
	if GetResourceState("qb-core") ~= "missing" and GetResourceState("qb-core") ~= "unknown" then
		while GetResourceState("qb-core") ~= "started" do
			Wait(0);
		end;
		QBCore = exports["qb-core"]:GetCoreObject();
	end;
end);
local GetPlayer = function(id)
	return QBCore.Functions.GetPlayer(id);
end;
local GetPlayerCID = function(id)
	return QBCore.Functions.GetPlayerByCitizenId(id);
end;
local GetName = function(id)
	local xPlayer = QBCore.Functions.GetPlayer(id);
	local name = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname;
	return name;
end;
RegisterNetEvent("qb-lockers:server:CreateLocker", function(code, area)
	local src = source;
	local xPlayer = GetPlayer(src);
	local locker = area;
	local passcode = code;
	local allowed = true;
	if code and xPlayer then
		local plyIdentifier = xPlayer.identifier or xPlayer.PlayerData.citizenid;
		MySQL.query("SELECT * FROM lockers WHERE locker = ?", {
			locker
		}, function(result)
			if result[1] then
				for k, v in pairs(result) do
					if v.citizenid == plyIdentifier then
						allowed = false;
					end;
				end;
				if allowed then
					local lockerid = plyIdentifier .. locker;
					MySQL.insert("INSERT INTO lockers (lockerid, citizenid, password, locker) VALUES (?, ?, ?, ?)", {
						lockerid,
						plyIdentifier,
						passcode,
						locker
					}, function(id)
						TriggerClientEvent("QBCore:Notify", src, "You Created Locker with Locker ID: " .. id, "success", 5000);
					end);
				else
					TriggerClientEvent("QBCore:Notify", src, "You can only create 1 locker in this area", "error", 5000);
				end;
			else
				local lockerid = plyIdentifier .. locker;
				MySQL.insert("INSERT INTO lockers (lockerid,citizenid, password, locker) VALUES (?, ?, ?, ?)", {
					lockerid,
					plyIdentifier,
					passcode,
					locker
				}, function(id)
					TriggerClientEvent("QBCore:Notify", src, "You Created Locker with Locker ID: " .. id, "success", 5000);
				end);
			end;
		end);
	end;
end);
RegisterNetEvent("qb-lockers:server:DeleteLocker", function(id)
	local lockerid = id;
	local src = source;
	local xPlayer = GetPlayer(src);
	if xPlayer and lockerid then
		local plyIdentifier = xPlayer.identifier or xPlayer.PlayerData.citizenid;
		MySQL.query("SELECT * FROM lockers", {}, function(result)
			if result[1] then
				for k, v in pairs(result) do
					if tostring(v.lockerid) == tostring(lockerid) and v.citizenid == plyIdentifier then
                        MySQL.query('DELETE FROM inventories WHERE identifier = ?', { v.lockerid })
						MySQL.query("DELETE FROM lockers WHERE lockerid = ?", {
							v.lockerid
						}, function(result)
							TriggerClientEvent("QBCore:Notify", src, "You Deleted the Locker with Locker ID: " .. id, "success", 5000);
						end);
					end;
				end;
			end;
		end);
	end;
end);
RegisterNetEvent("qb-lockers:server:ChangePass", function(lid, pass)
	local src = source;
	local lockerid = lid;
	local password = pass;
	local xPlayer = GetPlayer(src);
	if xPlayer and lockerid then
		local plyIdentifier = xPlayer.identifier or xPlayer.PlayerData.citizenid;
		MySQL.query("SELECT * FROM lockers", {}, function(result)
			if result[1] then
				for k, v in pairs(result) do
					if tostring(v.lockerid) == tostring(lockerid) then
						if v.citizenid == plyIdentifier then
							MySQL.update("UPDATE lockers SET password = ? WHERE lockerid = ? ", {
								password,
								lockerid
							}, function(affectedRows)
								if affectedRows then
									TriggerClientEvent("QBCore:Notify", src, "Password Changed", "success", 5000);
								end;
							end);
						else
							TriggerClientEvent("QBCore:Notify", src, "You are not Authorized to change the password!", "error", 5000);
						end;
					end;
				end;
			end;
		end);
	end;
end);
lib.callback.register("qb-lockers:getLockers", function(source, area)
	local result = MySQL.query.await("SELECT * FROM lockers WHERE locker = ?", {
		area
	});
	if result[1] then
		for k, v in pairs(result) do
			local xPlayer = GetPlayerCID(v.citizenid);
			if xPlayer then
				v.playername = GetName(xPlayer.source or xPlayer.PlayerData.source);
			else
				v.playername = "Not Online";
			end;
		end;
		return result;
	else
		return nil;
	end;
end);
RegisterNetEvent("qb-lockers:openInventory", function(lockerId)
	local src = source;
	local InventoryItems = {};
	local lockerInventory = exports["qb-inventory"]:GetInventory(lockerId);
	if lockerInventory then
		InventoryItems = lockerInventory.items;
	end;
	TriggerEvent("qb-inventory:server:addInventoryToCache", lockerId, InventoryItems);
	exports["qb-inventory"]:OpenInventory(src, lockerId);
end);
