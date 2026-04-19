extends Resource
const ELEMENTS := ["Wood", "Fire", "Water", "Earth", "Metal", "Junk"]
const STATES := ["Polar", "Non-polar", "Salt", "Elemental"]
const DISTIL_TEMPS := {"Wood": 30.0, "Fire": 120.0, "Water": 100.0, "Earth": 35.0, "Metal": 60.0}
const STR_RANGE := [50, 100, 200, 300]
const COLORS := {"Wood": Color.SADDLE_BROWN, "Earth": Color.DARK_GREEN, "Water": Color.AQUA, "Fire": Color.RED, "Metal": Color.BISQUE, "Junk": Color.BLACK}

#amount = {Metal: {Polar:1, NonPolar: 2}...
func get_composition_from_amount(amount: Dictionary) -> Dictionary[String, float]:
	var total_amount := 0.0
	var composition :Dictionary[String, float]= {"Metal":0.0, "Wood":0.0, "Water":0.0,"Earth":0.0,"Fire":0.0, "Junk": 0.0}
	for element in amount:
		for state in amount[element]:
			total_amount += amount[element][state]
			composition[element] += amount[element][state]
	for element in composition:
		if total_amount == 0.0:
			composition[element] = 0.0
		else:
			composition[element] = composition[element]/total_amount
	return composition
func get_total_from_amount(amount: Dictionary) -> float:
	var total_amount := 0.0
	for element in amount:
		for state in amount[element]:
			total_amount += amount[element][state]
	return total_amount
	
func get_empty_dict() -> Dictionary[String, Dictionary]:
	var amounts : Dictionary[String, Dictionary]
	for i in ELEMENTS:
		if not i in amounts:
			amounts[i] = {}
		for j in STATES:
			amounts[i][j] = 0.0
	return amounts

func generate_color(composition: Dictionary) -> Color:
	var c := Color.ALICE_BLUE
	for i in composition:
		c = c.lerp(COLORS[i], composition[i])
	
	return c

func get_element_amount(element: String, amount: Dictionary[String, Dictionary]) -> float:
	var res := 0.0
	for i in amount[element].values():
		res += i
	return res
