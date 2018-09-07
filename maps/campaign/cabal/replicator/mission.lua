load(function()
	local objectiveReplicator = objectives:add("replicator", true, "Capture the Scrin Replicator", {"Cabal"});
	local objectiveReinforcementsDiscover = objectives:add("reinforcements1", false, "Investigate the lost contact to the group on the east", {"Cabal"});
	
	actors:getById("replicator"):addCaptureListener(function(self, captor, oldOwner, newOwner)
		if newOwner:getId() == "Cabal" then
			objectiveReplicator:complete();
		end
	end);

	world:addDiscoveredListener(actors:getById("lostreaper"), function(actor, player)
		if player:getId() == "Cabal" and not objectiveReinforcementsDiscover:isCompleted() then
			objectiveReinforcementsDiscover:complete();
			
			local objectiveReinforcementsActivate = objectives:add("reinforcements2", false, "Reactivate the group on the east with the Commando", {"Cabal"});
			
			world:addProximityEnterListener(CPos.New(177, 73), WDist.FromCells(4), function(self, actor)
				if actor:getEffectiveOwner():getId() == "Cabal" and actor:getType() == "cyc2" then
					objectiveReinforcementsActivate:complete();
					self:cancel();
					
					for _, other in ipairs(actors:getInBox(CPos.New(172, 74), CPos.New(184, 74))) do
						other:setOwner(players:getById("Cabal"));
					end
				end
			end);
		end
	end);

	world:initCamera({
			[players:getById("Cabal")] = actors:getById("commando"):getPosition(),
			[players:getById("Nod1")] = actors:getById("replicator"):getPosition(),
			[players:getById("Nod2")] = actors:getById("helipad"):getPosition()
	});
end);
