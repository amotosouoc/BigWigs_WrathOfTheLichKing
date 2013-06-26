--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Toravon the Ice Watcher", 532)
if not mod then return end
mod:RegisterEnableMob(38433)
mod.toggleOptions = {72034, 72091, 72004, 72090, "bosskill"}

--------------------------------------------------------------------------------
-- Locals
--

local count = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.whiteout_bar = "Whiteout %d"
	L.whiteout_message = "Whiteout %d soon!"

	L.freeze_message = "Freeze"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Whiteout", 72034, 72096)
	self:Log("SPELL_CAST_START", "Orbs", 72091, 72095)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Frostbite", 72004, 72098, 72121)
	self:Log("SPELL_AURA_APPLIED", "Freeze", 72090, 72104)
	self:Death("Win", 38433)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
end

function mod:OnEngage()
	count = 1
	self:Bar(72091, 15) -- Frozen Orb
	self:Bar(72034, 30, L["whiteout_bar"]:format(count))
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Whiteout(args)
	self:Message(72034, "Positive")
	count = count + 1
	self:Bar(72034, 35, L["whiteout_bar"]:format(count))
	self:DelayedMessage(72034, 30, "Attention", L["whiteout_message"]:format(count))
end

function mod:Orbs(args)
	self:Message(72091, "Important")
	self:Bar(72091, 30)
end

function mod:Frostbite(args)
	self:StackMessage(72004, args.destName, args.amount, "Urgent")
end

do
	local freezeTargets, scheduled = nil, mod:NewTargetList()
	local function freezeWarn()
		mod:TargetMessage(72090, freezeTargets, "Personal", nil, L["freeze_message"])
		scheduled = nil
	end
	function mod:Freeze(args)
		freezeTargets[#freezeTargets + 1] = args.destName
		if not scheduled then
			scheduled = self:ScheduleTimer(freezeWarn, 0.2)
		end
	end
end

