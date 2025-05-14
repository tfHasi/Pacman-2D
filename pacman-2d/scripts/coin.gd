extends Area2D

signal coin_collected(points)

# Points awarded for collecting this coin
@export var points: int = 10

func _ready():
	# Add to the coins group for easier management
	add_to_group("coins")
	
	# If you're using an AnimatedSprite2D for the coin
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("idle")

# Called when Pacman eats this coin
func eat():
	# Play collection animation or sound if you have one
	if has_node("CollectSound"):
		$CollectSound.play()

	# Emit signal for score tracking
	emit_signal("coin_collected", points)
	
	# Make the coin invisible immediately
	visible = false
	
	# Disable collision to prevent multiple collections
	$CollisionShape2D.set_deferred("disabled", true)

	# Remove the coin from the scene
	queue_free()
