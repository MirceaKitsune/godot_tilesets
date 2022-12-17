# Tileset
Tileset based world generator for Godot 4.0.

# Credits
- Code: MirceaKitsune

# API
Mod data is stored under the data subdirectory. Mod data includes JSON definitions or model image and sound assets.

- mod/mod.json: Stores the configuration of the mod.
	- settings (dictionary): Global settings for this mod. If multiple mods are active the settings will overwrite each other in alphabetical order.
		- name (string): The name of this mod.
		- description (string): The description of the mod.
		- grid (dictionary): Every tile must be of the exact scale set here. As tiles are randomly rotated on the Y axis (0, 90, 180, 270) the size must be equal horizontally, however it can differ verticallly.
			- h (float): Horizontal scale of tiles (X and Z axes).
			- v (float): Vertical scale of tiles (Y axis).
		- size (dictionary): World size in tile count, tiles will only be placed inside this virtual box. Each axis is randomized between the min and max values.
			- min_x (float): Minimum number of units in the X direction.
			- min_y (float): Minimum number of units in the Y direction.
			- min_z (float): Minimum number of units in the Z direction.
			- max_x (float): Maximum number of units in the X direction.
			- max_y (float): Maximum number of units in the Y direction.
			- max_z (float): Maximum number of units in the Z direction.
	- tilesets (array): List of tiles in use by this mod.
		- scenes (array): The list of scenes that can be spawned when this tile is picked. Every scene must be designed to represent the same connections.
		- connections (array): An array of dictionaries containing the connection points, based on which this scene will spawn or require neighbors. The check is preformed relative to the tile's rotation.
			- x (float): The X edge of the tile this connection is for. Must be either -1, 0, 1.
			- y (float): The Y edge of the tile this connection is for. Must be either -1, 0, 1.
			- z (float): The Z edge of the tile this connection is for. Must be either -1, 0, 1.
			- name (string): The name of this connection, tiles in neighboring positions will need to match it. You can use "" to mark an empty gap no tiles will connect to.
