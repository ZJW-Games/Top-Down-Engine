extends Area2D

signal hit

export var speed = 400
var screen_size

# Controls
export var touchInput = true
var right
var left
var up
var down
var click
var clickedPos = position
var velocity = Vector2()
var dead = false


func start(pos):
	$AnimatedSprite.animation = "idle"
	position = pos
	clickedPos = position
	show()
	screen_size = get_viewport().get_visible_rect().size
	# Re-enable collisions
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

func get_input():
	if touchInput:
		click = Input.is_action_pressed("ui_click")
	else:
		right = Input.is_action_pressed("ui_right")
		left = Input.is_action_pressed("ui_left")
		up = Input.is_action_pressed("ui_up")
		down = Input.is_action_pressed("ui_down")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dead:
		get_input()
		
		# Check for input 
		# Move in a given direction
		if touchInput:
			if click:
				clickedPos = get_viewport().get_mouse_position()
				velocity = clickedPos - position
			if clickedPos:
				var dist = position - clickedPos
				if dist.length() < 5:
					velocity = Vector2()
		else:
			if right:
				velocity.x += 1
			if left:
				velocity.x -= 1
			if down:
				velocity.y += 1
			if up:
				velocity.y -= 1
		
		# Normalise velocity and trigger animation
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			$AnimatedSprite.play()
			$CollisionShape2D.disabled = false
		else:
			$CollisionShape2D.disabled = true
		
		# Update position
		position += velocity * delta
		
		# Clamp position to be within screen
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)
		
		# Change what animation plays
		if (clickedPos - position).length() > 16:
			if abs(velocity.x) > abs(velocity.y):
				$AnimatedSprite.animation = "walk"
				$AnimatedSprite.flip_v = false
				$AnimatedSprite.flip_h = velocity.x < 0
			else:
				$AnimatedSprite.animation = "up"
				#$AnimatedSprite.flip_v = velocity.y > 0
		else:
			$AnimatedSprite.flip_v = false
			$AnimatedSprite.animation = "idle"
	
#	if velocity.x != 0:
#		$AnimatedSprite.animation = "walk"
#		$AnimatedSprite.flip_v = false
#		$AnimatedSprite.flip_h = velocity.x < 0
#	elif velocity.y != 0:
#		$AnimatedSprite.animation = "up"
#		$AnimatedSprite.flip_v = velocity.y > 0


func _on_Player_body_entered(body):
	#hide()
	$AnimatedSprite.animation = "death"
	dead = true
	emit_signal("hit")
	# Ensure hit signal only triggers once
	$CollisionShape2D.set_deferred("disabled", true)

func _on_AnimatedSprite_animation_finished():
	#if $AnimatedSprite.animation == "post_death":
		#hide()
	if $AnimatedSprite.animation == "death":
		#Trigger particle effect
		$AnimatedSprite.animation = "post_death"
