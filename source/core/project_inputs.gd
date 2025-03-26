extends RefCounted

class_name ProjectInputs

## 项目输入配置

## 输入动作配置
static var ACTIONS = {
	"ui_up": {
		"display_name": "向上/跳跃",
		"default_events": [
			{
				"type": "key",
				"keycode": KEY_W,
				"physical_keycode": KEY_W,
				"key_label": KEY_W,
				"unicode": KEY_W,
			},
			{
				"type": "key",
				"keycode": KEY_SPACE,
				"physical_keycode": KEY_SPACE,
				"key_label": KEY_SPACE,
				"unicode": KEY_SPACE,
			}
		]
	},
	"ui_down": {
		"display_name": "向下/蹲下",
		"default_events": [
			{
				"type": "key",
				"keycode": KEY_S,
				"physical_keycode": KEY_S,
				"key_label": KEY_S,
				"unicode": KEY_S,
			}
		]
	},
	"ui_left": {
		"display_name": "向左移动",
		"default_events": [
			{
				"type": "key",
				"keycode": KEY_A,
				"physical_keycode": KEY_A,
				"key_label": KEY_A,
				"unicode": KEY_A,
			}
		]
	},
	"ui_right": {
		"display_name": "向右移动",
		"default_events": [
			{
				"type": "key",
				"keycode": KEY_D,
				"physical_keycode": KEY_D,
				"key_label": KEY_D,
				"unicode": KEY_D,
			}
		]
	},
	"ui_attack": {
		"display_name": "攻击",
		"default_events": [
			{
				"type": "key",
				"keycode": KEY_J,
				"physical_keycode": KEY_J,
				"key_label": KEY_J,
				"unicode": KEY_J,
			}
		]
	},
	"ui_skill": {
		"display_name": "技能",
		"default_events": [
			{
				"type": "key",
				"keycode": KEY_K,
				"physical_keycode": KEY_K,
				"key_label": KEY_K,
				"unicode": KEY_K,
			}
		]
	}
}

## 获取动作显示名称
static func get_display_name(action_name: String) -> String:
	if ACTIONS.has(action_name):
		return ACTIONS[action_name]["display_name"]
	return action_name.substr(3).capitalize().replace("_", " ")

## 获取默认输入配置
static func get_default_bindings() -> Dictionary:
	var bindings = {}
	for action_name in ACTIONS:
		bindings[action_name] = ACTIONS[action_name]["default_events"]
	return bindings
