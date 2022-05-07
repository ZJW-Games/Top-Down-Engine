extends Node

export (PackedScene) var Mob
var score
var screen_size

var difficulty = 1.0 # increase as time goes on

# filename to store score
var score_file = "user://highscore.txt"
var highscore = 0

func load_score():
	var f = File.new()
	if f.file_exists(score_file):
		f.open(score_file, File.READ)
		var content = f.get_as_text()
		highscore = int(content)
		f.close()

func save_score():
	var f = File.new()
	f.open(score_file, File.WRITE)
	f.store_string(str(highscore))
	f.close()

# Called when the node enters the scene tree for the first time.
func _ready():
	#VisualServer.texture_set_shrink_all_x2_on_set_data(true)
	randomize()
	$HUD/SplashTimer.start()
	screen_size = get_viewport().get_visible_rect().size
#	var pos = Vector2(screen_size.x / 2, screen_size.y / 2)
#	$HUD/SpashScreen.position = pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func game_over():
	# Update highscore
	load_score()
	if highscore:
		if score > highscore:
			highscore = score
			save_score()
	else:
		highscore = score
		save_score()
	# Stop timer
	$ScoreTimer.stop()
	$MobTimer.stop()
	# Show game over and highscore
	var msg = "Game Over!\n\n" + "Highscore: " + str(highscore)
	$HUD.show_game_over(msg)
	# Kill entities
	get_tree().call_group("mobs", "queue_free")
	$DeathSound.play()
	$Music.stop()


func createEnemyPath():
	# Dynamically set path based on viewport
	var windowWidth = (get_viewport().get_visible_rect().size).x
	var windowHeight = (get_viewport().get_visible_rect().size).y
	# Define curve and corners of viewport
	var curve = Curve2D.new()
	var topLeft = Vector2(0, 0)
	var topRight = Vector2(windowWidth, 0)
	var bottomRight = Vector2(windowWidth, windowHeight)
	var bottomLeft = Vector2(0, windowHeight)
	# Create curve
	curve.add_point(topLeft)
	curve.add_point(topRight)
	curve.add_point(bottomRight)
	curve.add_point(bottomLeft)
	curve.add_point(topLeft)
	# Assign new curve to path
	$MobPath.curve = curve


func new_game():
	score = 0
	difficulty = 1.0
	# Update position of player based on start button
	var startBtnPosition = $HUD/StartButton.get_rect().position
	var startBtnSize = $HUD/StartButton.get_rect().size
	$StartPosition.position = Vector2(startBtnPosition.x + startBtnSize.x/2, startBtnPosition.y - 64)
	$Player.start($StartPosition.position)
	# Begin score timer
	$StartTimer.start()
	# Update HUD
	$HUD.update_score(score)
	$HUD.show_message("Stop to hide!\nCollect the gems!")
	$Music.play()
	# Update enemy path based on screen size
	screen_size = get_viewport().get_visible_rect().size
	createEnemyPath()


func _on_MobTimer_timeout():
	# Choose random location on MobPath to spawn
	$MobPath/MobSpawnLocation.offset = randi()
	
	# Create a mob instance
	var mob = Mob.instance()
	add_child(mob)
	
	# Set the mob's direction, perpendicular to path direction
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	
	# Set the mob's position to a random location
	mob.position = $MobPath/MobSpawnLocation.position
	
	# Add some randomness to the direction
	direction += rand_range(-PI/4, PI/4)
	mob.rotation = direction
	
	# Set the velocity
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)
	
	# Make harder

	var windowWidth = screen_size.x
	var windowHeight = screen_size.y
	var longestSide = max(windowHeight, windowWidth);
	$MobTimer.wait_time = 0.5*(720 / pow(longestSide, difficulty))


func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	# Increase difficulty
	difficulty += 0.001


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_MobTimer_ready():
	# Update wait time based on screen size
	# Longer screen => smaller wait time => more enemies
	pass
