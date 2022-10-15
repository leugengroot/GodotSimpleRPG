extends Panel



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Button_pressed():
	# old version
	# get_node("Label").text = "Hello World!"
	# better version (since 3.0)
	$Label.text = "Hello World!"
