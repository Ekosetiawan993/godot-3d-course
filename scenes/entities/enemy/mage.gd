extends Enemy

#signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)

func _ready() -> void:
	health = 3

func _physics_process(delta: float) -> void:
	move_toward_player(delta)

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 3.5)
	#print(position.distance_to(player.position))
	if position.distance_to(player.position) <= attack_radius:
		spellcast_animation()
	else:
		pass

func spellcast_animation() -> void:
	stop_movement(1.5, 1.5)
	attack_animation.animation = "Spellcast_Shoot"
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shoot_fireball():
	cast_spell.emit(
		"fireball",
		$skin/Rig/Skeleton3D/BoneAttachment3D/wand2/wand/Marker3D.global_position,
		last_direction,
		1,
	)
