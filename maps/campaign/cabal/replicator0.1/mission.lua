
InfantryTypes = { "altnode1", "crusader", "templar" }
VehicleTypes = { "bggy", "rocketbggy", "flamebggy", "stnk", "ttnk" }

Objectives = function()
		Objective1 = player.AddPrimaryObjective("Recapture our lost M.C.V.")
		Objective2 = player.AddPrimaryObjective("Identify the source the unkown signal.")
		Objective3 = player.AddPrimaryObjective("Secure the source the unkown signal.")
		Camera.Position = Actor1022.CenterPosition

end

IntroductionInfo = function()
	UserInterface.SetMissionText("An artifact of alien origin has been detected nearby, explore the area and recapture our M.C.V.")
	Trigger.AfterDelay(DateTime.Seconds(15), CleanMissionText)
end

MCVFoundMessage = function()
	UserInterface.SetMissionText("M.C.V. located, Nod did not try to hide it, I am estimating a low probability of encountering an ambush.")
	Trigger.AfterDelay(DateTime.Seconds(15), CleanMissionText)
end

NodWarnedMessage = function()
	UserInterface.SetMissionText("As expected, the M.C.V. has a tracker, Nod has been notified of our presence, establish a base and capture the alien artifact.")
	Trigger.AfterDelay(DateTime.Seconds(15), CleanMissionText)
	player.MarkCompletedObjective(Objective1)
	Trigger.AfterDelay(DateTime.Seconds(60), MainAIProduceInfantry)
	Trigger.AfterDelay(DateTime.Seconds(60), MainAIProduceVehicles)
	Trigger.AfterDelay(DateTime.Seconds(10), SecondAIProduceVehicles)
end

ReplicatorFoundMessage = function()
	UserInterface.SetMissionText("It seems this structure is the source of the unkown signals, capture it.")
	Trigger.AfterDelay(DateTime.Seconds(15), CleanMissionText)
	player.MarkCompletedObjective(Objective2)
end

ReplicatorFoundMessage = function()
	UserInterface.SetMissionText("Mission Complete.")
	Trigger.AfterDelay(DateTime.Seconds(15), CleanMissionText)
	player.MarkCompletedObjective(Objective3)
end

IdlingUnits = { }
AttackGroupSize = 3

EarlyHunterKillers = function()
	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { Utils.Random(InfantryTypes) }
	ai2.Build(toBuild, function(unit)
		IdlingUnits[#IdlingUnits + 1] = unit[1]
		Trigger.AfterDelay(delay, EarlyHunterKillers)
		if #IdlingUnits >= (AttackGroupSize) then
			SendAttack()
		end
	end)
end

MainAIProduceInfantry = function()
	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(5))
	local toBuild = { Utils.Random(InfantryTypes) }
	ai.Build(toBuild, function(unit)
		IdlingUnits[#IdlingUnits + 1] = unit[1]
		Trigger.AfterDelay(delay, MainAIProduceInfantry)
		if #IdlingUnits >= (AttackGroupSize*10) then
			SendAttack()
		end
	end)
end

MainAIProduceVehicles = function()
	local delay = Utils.RandomInteger(DateTime.Seconds(10), DateTime.Seconds(30))
	local toBuild = { Utils.Random(VehicleTypes) }
	ai.Build(toBuild, function(unit)
		IdlingUnits[#IdlingUnits + 1] = unit[1]
		Trigger.AfterDelay(delay, MainAIProduceVehicles)
		if #IdlingUnits >= (AttackGroupSize*5) then
			SendAttack()
		end
	end)
end

SecondAIProduceVehicles = function()
	local delay = Utils.RandomInteger(DateTime.Seconds(10), DateTime.Seconds(30))
	local toBuild = { Utils.Random(VehicleTypes) }
	ai.Build(toBuild, function(unit)
		IdlingUnits[#IdlingUnits + 1] = unit[1]
		Trigger.AfterDelay(delay, SecondAIProduceVehicles)
		if #IdlingUnits >= (AttackGroupSize*7) then
			SendAttack()
		end
	end)
end

SendAttack = function()
	local units = { }
		units = SetupAttackGroup()
	Utils.Do(units, function(unit)
		IdleHunt(unit)
	end)
end

IdleHunt = function(unit) if not unit.IsDead then Trigger.OnIdle(unit, unit.Hunt) end end

SetupAttackGroup = function()
	local units = { }

	for i = 0, AttackGroupSize, 1 do
		if #IdlingUnits == 0 then
				Media.DisplayMessage("" .. #IdlingUnits)
			return units
		end

		local number = Utils.RandomInteger(1, #IdlingUnits)

		if IdlingUnits[number] and not IdlingUnits[number].IsDead then
			units[i] = IdlingUnits[number]
			table.remove(IdlingUnits, number)
		end
	end

	return units
end

CleanMissionText = function()
	UserInterface.SetMissionText("")
end

Militants = {Actor502, Actor503, Actor504}
MilitantPatrolPath = { Actor1207, Actor1208, Actor1209, Actor1210, Actor1211, Actor1212}

WorldLoaded = function()
	player = Player.GetPlayer("Cabal")
	ai = Player.GetPlayer("Nod1")
	ai2 = Player.GetPlayer("Nod2")
	Objectives()
	IntroductionInfo()
	EarlyHunterKillers()
	Trigger.OnEnteredProximityTrigger(Actor1023.CenterPosition, WDist.New(1024 * 15), function(a, id)
		if a.Owner == player then
			Trigger.RemoveProximityTrigger(id)
			baseCamera = Actor.Create("camera", true, { Owner = player, Location = Actor1023.Location })
			MCVFoundMessage()
		end
	end)

	Trigger.OnEnteredProximityTrigger(replicator.CenterPosition, WDist.New(1024 * 15), function(a, id)
		if a.Owner == player then
			Trigger.RemoveProximityTrigger(id)
			baseCamera = Actor.Create("camera", true, { Owner = player, Location = replicator.Location })
			ReplicatorFoundMessage()
		end
	end)

	Trigger.OnKilledOrCaptured(Actor1023, function() NodWarnedMessage()
	end)

	Trigger.OnKilledOrCaptured(replicator, function() Victory()
	end)

end 