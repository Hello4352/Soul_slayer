extends Panel

func _ready():
	$PistolButton.pressed.connect(_on_pistol_pressed)
	$ShotgunButton.pressed.connect(_on_shotgun_pressed)
	$SniperButton.pressed.connect(_on_sniper_pressed)
	$CloseButton.pressed.connect(_on_close_pressed)

func _on_pistol_pressed():
	GameData.selected_weapon = "pistol"
	print("선택된 무기: 권총")

func _on_shotgun_pressed():
	GameData.selected_weapon = "shotgun"
	print("선택된 무기: 샷건")

func _on_sniper_pressed():
	GameData.selected_weapon = "sniper"
	print("선택된 무기: 저격총")

func _on_close_pressed():
	visible = false
	GameData.ui_open = false
