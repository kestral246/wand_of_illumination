Wand of Illumination [wand\_of\_illumination]
===========================================
Provides a wand that when used lights up an entire room, but only for a moment.


![Wand of Illumination Screenshot](screenshot.png "Wand of Illumination")


Features
--------

- On right click, places an array of invisible light nodes around the player, in a sphere with a current radius of 15 nodes, and with a light spacing of four nodes.
- Scans only through air, and only replaces air nodes.
- Uses an abm to cause these light nodes to revert back to air nodes after a short amount of time.
- Uses mana mod if available. Current cost for use is 100 mana.
- Note that narrow passages, like dungeon corridors, may not light up, if they don't fall on the 4x light spacing grid.



WIP—Things that still need to be done.
----------------------------------

- Come up with a crafting recipe.
- Determine if I should be using an abm or something else.
- Optimize mana cost.
- Tune light generated: brightness, spacing, radius, and decay rate.
- Come up with a better wand texture.
- Maybe add option to give bigger sphere of light on shift-right-click, at the cost of more mana.


Dependencies
------------

- Currently has no default dependency. *(However, I'll probably have to add default when a crafting recipe is added.)*
- Optionally depends on Wuzzy's mana mod. *(Thanks to his Mirror of Returning mod, it was easy to figure out how to add mana support.)*


Licenses
--------

Source code

> The MIT License (MIT)

Media (textures)

> Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

Current wand texture based on farming\_tool\_stonehoe.png by BlockMen