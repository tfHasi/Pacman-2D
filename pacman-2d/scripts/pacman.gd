extends CharacterBody2D

const GRID := 8
const SPEED := 15.0
var direction = Vector2.ZERO
var next_direction = Vector2.ZERO
var target_pos = Vector2.ZERO
var last_valid_pos = Vector2.ZERO
var score = 0

signal coin_eaten(points)

func _ready():
	position = position.snapped(Vector2(GRID, GRID))
	last_valid_pos = position
	target_pos = position
	$AnimatedSprite2D.play("move")
	
	# Add Pacman to the "pacman" group for easy identification
	add_to_group("pacman")

func _process(delta):
	for dir in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
		if Input.is_action_just_pressed(direction_to_action(dir)):
			next_direction = dir
			break

func _physics_process(delta):
	var snapped = position.snapped(Vector2(GRID, GRID))
	if snapped == position:  # Centered on grid
		last_valid_pos = snapped
		
		if next_direction != Vector2.ZERO:
			var turn_pos = snapped + next_direction * GRID
			if can_move_to(turn_pos):
				direction = next_direction
				update_animation()
			else:
				direction = Vector2.ZERO
			next_direction = Vector2.ZERO
		elif direction != Vector2.ZERO and not can_move_to(snapped + direction * GRID):
			direction = Vector2.ZERO
			
		target_pos = snapped + direction * GRID
	
	if direction != Vector2.ZERO:
		var to_target = target_pos - position
		velocity = to_target.normalized() * SPEED
		
		if position.distance_to(target_pos) < SPEED * delta:
			position = target_pos
			velocity = Vector2.ZERO
			
		var collision = move_and_collide(velocity * delta)
		if collision:
			position = last_valid_pos
			direction = Vector2.ZERO
			velocity = Vector2.ZERO
			target_pos = last_valid_pos
		else:
			move_and_slide()
	else:
		velocity = Vector2.ZERO

# Check for coin collisions
func _on_coin_detector_area_entered(area):
	if area.is_in_group("coins"):
		# Tell the coin it was eaten
		area.eat()
		
		# Update score and emit signal
		score += 10
		emit_signal("coin_eaten", 10)

func can_move_to(pos: Vector2) -> bool:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = collision_mask
	query.exclude = [self]
	return get_world_2d().direct_space_state.intersect_point(query).is_empty()

func direction_to_action(dir: Vector2) -> String:
	return {
		Vector2.RIGHT: "ui_right",
		Vector2.LEFT: "ui_left",
		Vector2.DOWN: "ui_down",
		Vector2.UP: "ui_up"
	}[dir]

func update_animation():
	match direction:
		Vector2.RIGHT:
			$AnimatedSprite2D.rotation = 0
			$AnimatedSprite2D.flip_h = false
		Vector2.LEFT:
			$AnimatedSprite2D.rotation = 0
			$AnimatedSprite2D.flip_h = true
		Vector2.DOWN:
			$AnimatedSprite2D.rotation = PI/2
			$AnimatedSprite2D.flip_h = false
		Vector2.UP:
			$AnimatedSprite2D.rotation = -PI/2
			$AnimatedSprite2D.flip_h = false

# Getter for score
func get_score() -> int:
	return score
