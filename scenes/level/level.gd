class_name Level
extends Node3D

var fireball_scene: PackedScene = preload("res://scenes/vfx/fireball.tscn")
const scenes = {
	"dungeon": "res://scenes/level/dungeon.tscn",
	"overworld": "res://scenes/level/overworld.tscn",
}

func _ready() -> void:
	for entity in $Entities.get_children():
		if entity.has_signal("cast_spell"):
			entity.connect("cast_spell", instantiate_fireball)

#func _on_player_cast_spell(type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	#instantiate_fireball(type, pos, direction, size)
#
#
#func _on_mage_cast_spell(type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	#instantiate_fireball(type, pos, direction, size)
#
#
#func _on_boss_cast_spell(type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	#instantiate_fireball(type, pos, direction, size)

func instantiate_fireball(_type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	var fireball = fireball_scene.instantiate()
	$Projectiles.add_child(fireball)
	fireball.global_position = pos
	fireball.direction = direction
	fireball.setup(size)

func switch_level(target: String) -> void:
	call_deferred("_switch_level", target)

func _switch_level(target: String) -> void:
	get_tree().change_scene_to_file(scenes[target])
