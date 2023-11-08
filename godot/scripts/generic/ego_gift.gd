class_name EGOGifts


class EgoGift:
	var name: String
	var representing_enum: Gift
	var image: Resource # TODO
	var short_desc: String
	var long_desc: String
	var init_function: Callable
	
	func _init(name := "TEST",
		representing_enum := Gift.DUMMY,
		image: Resource = null,
		short_desc := "Missing Data",
		long_desc := "Should not appear during gameplay.",
		init_function := func(): print("ERROR - TEST EGO IN GAMEPLAY")):
		self.name = name
		self.representing_enum = representing_enum
		self.image = image
		self.short_desc = short_desc
		self.long_desc = long_desc
		self.init_function = init_function

# An enum representing every item we have.
# TODO - Implement SHORTTIME, FASTWALK, METERTHEFT
enum Gift {
	DUMMY, # A dummy EGO. Does nothing.
	SHORTTIME, #13th toll
	FASTWALK, #obsession
	METERTHEFT, #melty eyeball
	AIRDASH, #illusory hunt
	RHYTHM_GAME, #fervent beats
	JESUS_SKULL, #Pentinence
	CARMEN, #Apostles
	TINY_BIRD, #punishment
	HELLO, #Hello?
	CENSORED, #censored
	PARRY, #well-worn parasol
}

static var EGO_LIST = {
# NOTE: You need to use lambda functions here because... fuck idk. Godot.
	Gift.DUMMY: EgoGift.new(),
	Gift.SHORTTIME: EgoGift.new("The 13th Toll", Gift.SHORTTIME,
		null, "Shorten Timer", "Reduce Round Timer By 30 Seconds", 
		func(x): EGOGifts.lower_timer(x, -30)),
	Gift.FASTWALK: EgoGift.new("Obsession", Gift.FASTWALK,
		null, "Faster Walk", "Double Walking Speed", 
		func(x): EGOGifts.increase_speed_by(x, 2)),
	Gift.METERTHEFT: EgoGift.new("Melty Eyeball", Gift.METERTHEFT,
		null, "Steal Meter", "On Hit, Steal From Opponent's Meter",
		func(x): x.extrafunc.add_on_hitting(func(i): EGOGifts.steal_meter(i, 2000))),
	Gift.AIRDASH: EgoGift.new("Illusory Hunt", Gift.AIRDASH,
		null, "Air Dash", "Grants Mid-Air Dash"),
	Gift.RHYTHM_GAME: EgoGift.new("Fervent Beats", Gift.RHYTHM_GAME,
		null, "Timed Buff", "Increase Damage Timed To Heartbeat"),
	Gift.JESUS_SKULL: EgoGift.new("Penitence", Gift.JESUS_SKULL,
		null, "Super Move", "Gain a Powerful Super Move"),
	Gift.CARMEN: EgoGift.new("Apostles", Gift.CARMEN,
		null, "Gain Follower", "Gain a Follower to Attack Opponent"),
	Gift.TINY_BIRD: EgoGift.new("Punishment", Gift.TINY_BIRD,
		null, "Counter Boost", "Counterhits Deal Extra Damage"),
	Gift.HELLO: EgoGift.new("Hello?", Gift.HELLO,
		null, "Copy Move", "Copy an Opponent's Super Move"),
	Gift.CENSORED: EgoGift.new("CENSORED", Gift.CENSORED,
		null, "Hide Character", "Briefly Hide Your Moves"),
	Gift.PARRY: EgoGift.new("Well-Worn Parasol", Gift.PARRY,
		null, "Perfect Block", "Block Attack Perfectly to Negate Damage",
		func(x): x.extrafunc.add_on_block(func(i): EGOGifts.perfect_block(i, 20)))
}

static func get_ego(gift: Gift):
	return EGO_LIST[gift]

static func increase_speed_by(char: Character, i: int):
	char.SPEED *= i

static func lower_timer(char: Character, i: int):
	char.get_parent().timer.add_to_default(i)

# Steals up to "meter" amounts of meter from the other character.
static func steal_meter(char: Character, meter: int):
	char.add_meter(char.other_player.remove_meter(meter))

# Does a "perfect block" if it's inputted within "leniency" frames of an attack.
static func perfect_block(char: Character, leniency: int):
	if char.input.buffer.read_action([["p_in4", leniency]]):
		print("DEBUG: Wow! Perfect Block!")
	
	
