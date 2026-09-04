extends Panel

func _ready():
	$SelectDefaultButton.pressed.connect(_on_select_character.bind("default"))
	$SelectTankButton.pressed.connect(_on_select_character.bind("tank"))
	$SelectSpeedyButton.pressed.connect(_on_select_character.bind("speedy"))
	$SelectGlassCannonButton.pressed.connect(_on_select_character.bind("glass_cannon"))
	$CloseButton.pressed.connect(_on_close_pressed)
					
func _on_select_character(character_name):
	GameData.selected_character = character_name
	print("선택된 캐릭터: ", character_name)
							
func _on_close_pressed():
	visible = false
	GameData.ui_open = false
