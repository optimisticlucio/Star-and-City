class_name EGOGifts

class EgoGift:
	var name: String
	var image: Resource # TODO
	var short_desc: String
	var long_desc: String
	var init_function: Callable
	
	func _init(init_name := "TEST",
		init_image: Resource = null,
		init_short_desc := "Missing Data",
		init_long_desc := "Should not appear during gameplay.",
		init_init_function := func(): print("ERROR - TEST EGO IN GAMEPLAY")
	):
		self.name = init_name
		self.image = init_image
		self.short_desc = init_short_desc
		self.long_desc = init_long_desc
		self.init_function = init_init_function

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

# The EGOs is it possible to get.
static var EGO_POOL = [
	Gift.SHORTTIME,
	Gift.FASTWALK,
	Gift.METERTHEFT,
	Gift.PARRY
]

static var EGO_LIST = {
# NOTE: You need to use lambda functions here because... fuck idk. Godot.
	Gift.DUMMY: EgoGift.new(),
	Gift.SHORTTIME: EgoGift.new(
		"The 13th Toll",
		null,
		"Shorten Timer",
		"Reduce Round Timer By 30 Seconds", 
		func(x): EGOGifts.lower_timer(x, -30)
	),
	
	Gift.FASTWALK: EgoGift.new(
		"Obsession",
		null,
		"Faster Walk",
		"Increase Walking Speed", 
		func(x): EGOGifts.increase_speed_by(x, Math.Quotient.new(4,3))
	),
	
	Gift.METERTHEFT: EgoGift.new(
		"Melty Eyeball",
		null,
		"Steal Meter",
		"On Hit, Steal From Opponent's Meter",
		func(x): x.extrafunc.add_on_hitting(func(i): EGOGifts.steal_meter(i, 2000))
	),
	
	Gift.AIRDASH: EgoGift.new(
		"Illusory Hunt",
		null,
		"Air Dash",
		"Grants Mid-Air Dash"
	),
	
	Gift.RHYTHM_GAME: EgoGift.new(
		"Fervent Beats",
		null,
		"Timed Buff",
		"Increase Damage Timed To Heartbeat"
	),
	
	Gift.JESUS_SKULL: EgoGift.new(
		"Penitence",
		null,
		"Super Move",
		"Gain a Powerful Super Move"
	),
	
	Gift.CARMEN: EgoGift.new(
		"Apostles",
		null,
		"Gain Follower",
		"Gain a Follower to Attack Opponent"
	),
	
	Gift.TINY_BIRD: EgoGift.new(
		"Punishment",
		null,
		"Counter Boost",
		"Counterhits Deal Extra Damage"
	),
	
	Gift.HELLO: EgoGift.new(
		"Hello?",
		null,
		"Copy Move",
		"Copy an Opponent's Super Move"
	),
	
	Gift.CENSORED: EgoGift.new(
		"CENSORED",
		null,
		"Hide Character",
		"Briefly Hide Your Moves"
	),
	
	Gift.PARRY: EgoGift.new(
		"Well-Worn Parasol",
		null,
		"Perfect Block",
		"Block Attack Perfectly to Negate Damage",
		func(x): x.extrafunc.add_on_block(func(i): EGOGifts.perfect_block(i, 20))
	),
}

static func get_ego(gift: Gift):
	return EGO_LIST[gift]

static func increase_speed_by(character: Character, i: Math.Quotient):
	var x = i.duplicate()
	x.dividend *= character.SPEED
	character.SPEED = x.int_divide()

static func lower_timer(character: Character, i: int):
	character.get_parent().timer.add_to_default(i)

# Steals up to "meter" amounts of meter from the other character.
static func steal_meter(character: Character, meter: int):
	character.add_meter(character.other_player.remove_meter(meter))

# Does a "perfect block" if it's inputted within "leniency" frames of an attack.
static func perfect_block(character: Character, leniency: int):
	if character.input.buffer.read_action([["p_in4", leniency]]):
		print("DEBUG: Wow! Perfect Block!")
