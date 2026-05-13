extends Control


@onready var heart_container: HBoxContainer = $Hearts/MarginContainer/HBoxContainer
@onready var spell_texture: TextureRect = $Spells/MarginContainer/HBoxContainer/TextureRect
@onready var energy_bar_texture: TextureProgressBar = $EnergyBar/MarginContainer/TextureProgressBar
@onready var stamina_progress_bar: TextureProgressBar = $StaminaBar/CenterContainer/MarginContainer/TextureProgressBar

var heart_scene: PackedScene = preload("res://scenes/entities/player/heart.tscn")
var fire_texture: CompressedTexture2D = preload("res://graphics/ui/fire.png")
var heal_texture: CompressedTexture2D = preload("res://graphics/ui/heal.png")

func setup(value: int) -> void:
	for i in value:
		var heart = heart_scene.instantiate()
		heart_container.add_child(heart)
		heart.change_alpha(1.0)
		await get_tree().create_timer(0.3).timeout # remember to set Materials - shader - Resource - Local to Scene to True (make the shader for each heart)
		
func update_health(value: int, direction: int) -> void:
	# remove all health
	for child in heart_container.get_children():
		child.queue_free()
	
	if direction < 0:
		for i in value:
			var heart = heart_scene.instantiate()
			heart_container.add_child(heart)
		var extra_heart = heart_scene.instantiate()
		heart_container.add_child(extra_heart)
		extra_heart.change_alpha(0.0)
	else:
		# adding health
		for i in value-1:
			var heart = heart_scene.instantiate()
			heart_container.add_child(heart)
		var extra_heart = heart_scene.instantiate()
		heart_container.add_child(extra_heart)
		extra_heart.change_alpha(1.0)

func update_spell(spells, current_spell) -> void:
	if current_spell == spells.FIREBALL:
		spell_texture.texture = fire_texture
	elif current_spell == spells.HEAL:
		spell_texture.texture = heal_texture

func update_energy(value: int) -> void:
	energy_bar_texture.value = value

func update_stamina(current_value: int, target_value: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(_change_stamina, current_value, target_value, 0.3)
	
func _change_stamina(value: int) -> void:
	stamina_progress_bar.value = value

func change_stamina_alpha(value: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(_change_stamina_alpha, 1 - value, value, 0.25)

func _change_stamina_alpha(value: float) -> void:
	stamina_progress_bar.modulate.a = value
