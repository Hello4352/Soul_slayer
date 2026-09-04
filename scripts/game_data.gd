extends Node

var selected_character = "default"
var selected_weapon = "pistol"
var ui_open = false

var weapon_data = {
"pistol": {"speed": 400.0, "damage": 10, "cooldown": 0.08, "bullet_count": 1, "spread": 10},
"shotgun": {"speed": 350.0, "damage": 5, "cooldown": 0.3, "bullet_count": 5, "spread": 5},
"sniper": {"speed": 700.0, "damage": 25, "cooldown": 0.9, "bullet_count": 1, "spread": 0}
}
			
var character_data = {
"default": {"max_hp": 100, "speed": 500.0, "color": Color(1, 1, 1)},
"tank": {"max_hp": 150, "speed": 150.0, "color": Color(0.3, 0.5, 1)},
"speedy": {"max_hp": 70, "speed": 280.0, "color": Color(0.3, 1, 0.4)},
"glass_cannon": {"max_hp": 60, "speed": 200.0, "color": Color(1, 0.3, 0.3)}
}
