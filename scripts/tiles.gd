extends Node3D

# List of tiles present in the world, indexed by world position
var _tile_data: Dictionary

# Generate a fresh world with the given tileset
func _generate(n: String):
	var settings = Data.settings[n]
	var tileset = Data.tilesets[n]
	var grid = Vector3(settings.grid.h, settings.grid.v, settings.grid.h)
	var bound = Vector3(
		Data.rng.randi_range(settings.size.min_x, settings.size.max_x) * grid.x / 2,
		Data.rng.randi_range(settings.size.min_y, settings.size.max_y) * grid.y / 2,
		Data.rng.randi_range(settings.size.min_z, settings.size.max_z) * grid.z / 2)

	# Delete any existing tiles
	if len(_tile_data) > 0:
		for tile in _tile_data:
			_tile_data[tile].scene.queue_free()
	_tile_data = {}

	# Keep adding tiles as long as new required positions exist
	# Connections are indexed by position, each entry is an array of positions indexed by the connection name
	# Starts from a requirement with no connections at the world center which spawns a random tile
	var pos_required = [Vector3(0, 0, 0)]
	var pos_connections = {Vector3(0, 0, 0): {}}
	while len(pos_required) > 0:
		var pos_required_new = []
		for pos in pos_required:
			var tile_spawn = []
			for i in len(tileset):
				# Ensure this tile contains definitions for all required connections
				var valid = true
				for req_con_name in pos_connections[pos]:
					if not tileset[i].connections.has(req_con_name):
						valid = false
						break

				# Test each tile at all possible rotations across the Y axis (0, 90, 180, 270)
				for angle in (4 if valid else 0):
					for req_con_name in pos_connections[pos]:
						for req_con_dir in pos_connections[pos][req_con_name]:
							valid = false
							for con_dir in tileset[i].connections[req_con_name]:
								if con_dir.rotated(Vector3.UP, deg_to_rad(angle * 90)).round() == req_con_dir:
									valid = (req_con_name != "")
									break
							if not valid: break
						if not valid: break
					if valid: tile_spawn.append({"index": i, "angle": angle})

			# Pick and spawn a random tile and scene from the list of valid configurations
			if len(tile_spawn) == 0: continue
			var tile = tile_spawn[Data.rng.randi_range(0, len(tile_spawn) - 1)]
			var tile_scene = tileset[tile.index].scenes[Data.rng.randi_range(0, len(tileset[tile.index].scenes) - 1)]
			tile.scene = tile_scene.instantiate()
			tile.scene.position = pos
			tile.scene.rotation = Vector3(0, deg_to_rad(tile.angle * 90), 0)
			add_child(tile.scene)
			_tile_data[pos] = tile

			# Translate the tile's connections to a list of new positions if valid, connecting tiles will be spawned during next batch
			# Position is the tile's position plus the connection offset, connection is mirrored so the direction points back to it
			for con_name in tileset[tile.index].connections:
				for con_dir in tileset[tile.index].connections[con_name]:
					var world_con_dir = con_dir.rotated(Vector3.UP, deg_to_rad(tile.angle * 90)).round()
					var world_pos = pos + (world_con_dir * grid)
					if abs(world_pos.x) <= bound.x and abs(world_pos.y) <= bound.y and abs(world_pos.z) <= bound.z and not _tile_data.has(world_pos):
						if not pos_required_new.has(world_pos):
							pos_required_new.append(world_pos)
						if not pos_connections.has(world_pos):
							pos_connections[world_pos] = {}
						if not pos_connections[world_pos].has(con_name):
							pos_connections[world_pos][con_name] = []
						pos_connections[world_pos][con_name].append(-world_con_dir)

		pos_required = pos_required_new

func _init():
	_generate("test")
