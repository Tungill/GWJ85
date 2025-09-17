extends Resource

class_name SpawnerSequence

@export var enemies: Array[String]
var index: int = 0

func next_enemy() -> String:
	var enemy : String = enemies[index]
	index = (index + 1) % enemies.size()
	return enemy
