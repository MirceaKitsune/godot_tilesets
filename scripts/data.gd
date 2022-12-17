extends Node

# Active mods to be scanned and loaded, currently static
const mod = "default"

# Mod data storage and RNG used by the world generator
var rng: RandomNumberGenerator
var settings: Dictionary
var tilesets: Dictionary

# Print a message to the console or throw an error
const MSG_NOTICE = 0
const MSG_WARNING = 1
const MSG_ERROR = 2
const MSG_PREFIX = ["Notice", "Warning", "Error"]
func _message(msg: String, type: int):
	print(MSG_PREFIX[type], ": ", msg)

# Read JSON file
func _get_json(path: String):
	var json = JSON.new()
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		json.parse(file.get_as_text())
	return json.get_data()

# Load settings and tiles from the active mod
func _init():
	rng = RandomNumberGenerator.new()
	# rng.set_seed(0)

	var file = _get_json("res://data/" + mod + "/mod.json")
	for group in file:
		settings[group] = {}
		for setting in file[group].settings:
			settings[group][setting] = file[group].settings[setting]

		tilesets[group] = []
		for tileset in file[group].tilesets:
			# The preloaded scenes are stored in place of the scene paths
			var scenes = []
			for scene in tileset.scenes:
				scenes.append(load("res://data/" + scene + ".tscn"))

			# Store connections as a list of Vector3 positions indexed by their name
			# This allows the generator to search only positions belonging to a specific connection when comparing
			var connections = {}
			for con in tileset.connections:
				if not connections.has(con.name):
					connections[con.name] = []
				connections[con.name].append(Vector3(con.x, con.y, con.z))

			tilesets[group].append({ "scenes": scenes, "connections": connections })
		_message("Loaded settings and tiles for group \"" + group + "\"", MSG_NOTICE)
