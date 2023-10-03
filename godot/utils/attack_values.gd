class_name AttackValues

# Outgoing damage for an attack.
var damage: int = 0

# The quantity of hitstun frames for the attack.
var hitstun: int = 20

# The quantity of blockstun frames for the attack.
var blockstun: int = 15

# Whether the attack can be blocked high.
var blocked_high: bool = true

# Whether the attack can be blocked low.
var blocked_low: bool = true

# Whether the attack knocks the opponent down.
var knocks_down: bool = false

func set_damage(val: int) -> AttackValues:
	damage = val
	return self

func set_hitstun(val: int) -> AttackValues:
	hitstun = val
	return self

func set_blockstun(val: int) -> AttackValues:
	blockstun = val
	return self

func set_blocked_high(val: bool) -> AttackValues:
	blocked_high = val
	return self

func set_blocked_low(val: bool) -> AttackValues:
	blocked_low = val
	return self

func set_knocks_down(val: bool) -> AttackValues:
	knocks_down = val
	return self

# -- The functions below are aliases of the functions above. --

func dam(val: int) -> AttackValues:
	return self.set_damage(val)

func hs(val: int) -> AttackValues:
	return self.set_hitstun(val)

func bs(val: int) -> AttackValues:
	return self.set_blockstun(val)

func high(val: bool) -> AttackValues:
	return self.set_blocked_high(val)

func low(val: bool) -> AttackValues:
	return self.set_blocked_low(val)

func kd(val: bool) -> AttackValues:
	return self.set_knocks_down(val)
