extends CharacterBody2D

const GRID := 16
const SPEED := 30.0

var target_pos := Vector2.ZERO
var direction := Vector2.ZERO

func _ready():
	position = position.snapped(Vector2(GRID, GRID))
	target_pos = position
	$AnimatedSprite2D.play("move")

func _process(_delta):
	for dir in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
		if Input.is_action_pressed(direction_to_action(dir)):
			direction = dir
			break

func _physics_process(delta):
	if position == target_pos:
		var next_pos = position + direction * GRID
		if can_move_to(next_pos):
			target_pos = next_pos
			update_animation()

	var move_dir = (target_pos - position).normalized()
	velocity = move_dir * SPEED

	if position.distance_to(target_pos) < SPEED * delta:
		position = target_pos
		velocity = Vector2.ZERO

	move_and_slide()

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
	}.get(dir, "")

func update_animation():
	match direction:
		Vector2.RIGHT:
			$AnimatedSprite2D.rotation = 0
			$AnimatedSprite2D.flip_h = false
		Vector2.LEFT:
			$AnimatedSprite2D.rotation = 0
			$AnimatedSprite2D.flip_h = true
		Vector2.DOWN:
			$AnimatedSprite2D.rotation = PI / 2
			$AnimatedSprite2D.flip_h = false
		Vector2.UP:
			$AnimatedSprite2D.rotation = -PI / 2
			$AnimatedSprite2D.flip_h = false
