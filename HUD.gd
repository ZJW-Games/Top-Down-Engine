extends CanvasLayer

signal start_game

var logo = TextureRect.new()

func show_message(text):
	$TitleMessage.text = text
	$TitleMessage.show()
	$MessageTimer.start()


func show_game_over(gameOverMsg):
	show_message(gameOverMsg)
	# Wait for message timer to count down
	yield($MessageTimer, "timeout")
	
	$TitleMessage.text = "Dodge Them!"
	$TitleMessage.show()
	# Make a one-shot timer and wait for it to finish
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	logo.texture = load("res://assets/icons/ZJW_Logo.png")
	logo.anchor_left = 0.5
	logo.anchor_right = 0.5
	logo.anchor_top = 0.5
	logo.anchor_bottom = 0.5
	var texture_size = logo.texture.get_size()
	logo.margin_left = -texture_size.x / 2
	logo.margin_right = -texture_size.x / 2
	logo.margin_top = -texture_size.y / 2
	logo.margin_bottom = -texture_size.y / 2
	add_child(logo)
	$SplashBackground.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MessageTimer_timeout():
	$TitleMessage.hide()


func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")


func _on_SplashTimer_timeout():
	logo.hide()
	$SplashBackground.hide()
