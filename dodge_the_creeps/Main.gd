extends Node

@export var mob_scene: PackedScene
var score
@export var life = 5
func been_hit():
	life-=1
	if life == 0:
		game_over()
	else:
		update_color()
		$MobTimer.stop()
		$Player/CollisionShape2D.set_deferred(&"disabled", true)
		await get_tree().create_timer(1.5).timeout
		$Player.start(Vector2(250, 450))
		$MobTimer.start()
func update_color():
	if life == 1:
		$HUD/HealthRef.border_color=Color(255, 0, 0)
	if life == 2:
		$HUD/HealthRef.border_color=Color(255, 128, 0)
	if life == 3:
		$HUD/HealthRef.border_color=Color(255, 255, 0)
	if life == 4:
		$HUD/HealthRef.border_color=Color(128, 255, 0)
	if life == 5:
		$HUD/HealthRef.border_color=Color(0, 255, 0)
	pass
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	life = 5
	update_color()
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()


func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	if score % 10 == 0 and life < 5:
		life += 1
		update_color()


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
