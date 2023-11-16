extends Control


# Changes the visual to be a specific EGO gift.
func set_ego(gift: EGOGifts.Gift):
	print("DEBUG: EGO frame recieved command to display EGO named " + EGOGifts.Gift.keys()[gift])
