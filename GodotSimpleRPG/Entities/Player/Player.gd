extends KinematicBody2D

# Last direction the player moved before stopping
var last_direction = Vector2(0, 1)

# Player movement speed
export var speed = 75

var attack_playing = false

signal player_stats_changed

# Player stats
var health = 100
var health_max = 100
var health_regeneration = 1
var mana = 100
var mana_max = 100
var mana_regeneration = 2

func _ready():
   emit_signal("player_stats_changed", self)

func _process(delta):
   # Regenerates mana
   var new_mana = min(mana + mana_regeneration * delta, mana_max)
   if new_mana != mana:
	   mana = new_mana
	   emit_signal("player_stats_changed", self)
 
   # Regenerates health
   var new_health = min(health + health_regeneration * delta, health_max)
   if new_health != health:
	   health = new_health
	   emit_signal("player_stats_changed", self)
	
func _physics_process(delta):
	# Get player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
 
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var movement = speed * direction * delta
	move_and_collide(movement)
	
	# Animate player based on direction
	if not attack_playing:
		movement = 0.3 * movement
		animates_player(direction)
	
func _input(event):
	if event.is_action_pressed("attack"):
		attack_playing = true
		var animation = get_animation_direction(last_direction) + "_attack"
		$Sprite.play(animation)
	elif event.is_action_pressed("fireball"):
		if mana >= 25:
			mana = mana - 25
			emit_signal("player_stats_changed", self)
			attack_playing = true
			var animation = get_animation_direction(last_direction) + "_fireball"
			$Sprite.play(animation)
	
func animates_player(direction: Vector2):
	if direction != Vector2.ZERO:
		# gradually update last_direction to counteract the bounce of the analog stick
		last_direction = 0.5 * last_direction + 0.5 * direction
	   
		# Choose walk animation based on movement direction
		var animation = get_animation_direction(last_direction) + "_walk"
	   
		# Set correct animation speed
		$Sprite.frames.set_animation_speed(animation, 2 + 8 * direction.length())
		# Play the walk animation
		$Sprite.play(animation)
	else:
		# Choose idle animation based on last movement direction and play it
		var animation = get_animation_direction(last_direction) + "_idle"
		$Sprite.play(animation)

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"

func _on_Sprite_animation_finished():
	attack_playing = false
