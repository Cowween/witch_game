extends Resource
const ELEMENTS := ["Wood", "Fire", "Water", "Earth", "Metal"]
const STATES := ["Polar", "Non-polar", "Salt", "Elemental"]
#amount = {Metal: {Polar:1, NonPolar: 2}...
func get_composition_from_amount(amount: Dictionary) -> Dictionary[String, float]:
	var total_amount := 0.0
	var composition :Dictionary[String, float]= {"Metal":0.0, "Wood":0.0, "Water":0.0,"Earth":0.0,"Fire":0.0,}
	for element in amount:
		for state in amount[element]:
			total_amount += amount[element][state]
			composition[element] += amount[element][state]
	for element in composition:
		composition[element] = composition[element]/total_amount
	return composition

func get_empty_dict() -> Dictionary[String, Dictionary]:
	var amounts : Dictionary[String, Dictionary]
	for i in ELEMENTS:
		if not i in amounts:
			amounts[i] = {}
		for j in STATES:
			amounts[i][j] = 0.0
	return amounts
