# Berry
*Berry* is a simple [Tiled Map](www.mapeditor.org) loader for Corona SDK.  Berry is also able to load and use TexturePacker sprites inside a Tiled map.

![Screenshot of berry in action](https://i.imgur.com/DbHD6EL.png)

**berry** supports only part of functionality offered to user by Tiled Map Editor. This includes tile and object layers, tilesets and collections of images. Neverthless it can be extended by using custom properties and executing custom code to gain more flexibility and control.  

Tested with Tiled v1.2.0

### List of supporting features for Tiled: 

- [x] **File Exensions -** *only JSON map files*
- [x] **Map Types -** *Orthogonal, Isometric, and Isometric Staggered*
- [x] **Tilesets -** *Collections of images and Tileset images*
- [x] **TexturePacker Tilesets -** *Images and lua files created from TexturePacker*
- [x] **Layers -** *Object and Tile layer types, horziontal and vertical offsets*
- [x] **Object -** *x/y flipping and re-centering of anchorX/anchorY for Corona*
- [x] **Shapes -** *Rectangle and polygon shapes with fillColor and strokeColor*
- [x] **Text -** *Text objects, horziontal alignment, word wrap, fonts, and colors*
- [x] **Physics -** *Rectangle and polygon shapes and objects*
- [x] **Animation -** *Tile Animation Editor support for objects*
- [x] **Properties -** *Basic property copying for objects and layers*

### Quick Start Guide

```lua
local berry = require( 'pl.ldurniat.berry' )
local map   = berry:new( filename, tilesetsDirectory, texturePackerDirectory )
-- If you use composer you will need it as well
scene.view:insert( map ) 
```

### filename

The filename specify path to file with map.

![Saved Map](https://i.imgur.com/pCvRX2q.png)

#### tilesetsDirectory

Most of the time you will store your maps and images/tilesets in a directory. The tileSetsDirectory parameter overides where **berry** looks for images.

```lua
local map = berry.new( 'scene/game/map/level1.json', 'scene/game/map' ) -- look for images in /scene/game/map/
```

#### texturePackerDirectory

If you wish to use TexturePacker with Berry you can load the sprites several ways.

1.  Place the TexturePacker images and lua files inside the same directory as `tilesetsDirectory` and it will load them automatically 
2.  Use the `texturePackerDirectory` to select the directory the TexturePacker images and files are located.
3.  Use `map:addTexturePack( image_path, lua_path )` to load each texture pack individually.

Method 1 and 2 assume by default that the image file and the lua file have the same name.  (ex.  items.png and items.lua)  If the files are named differently from one another, then the sprites will need to be loaded via method 3.  (ex.  items.png and weapons.lua) 

To insert a loaded texture pack sprite into the map use `map:addSprite( layer, image_name, x, y )`

#### map

The map object is [display group](https://docs.coronalabs.com/api/library/display/newGroup.html). All objects are inserted into this group. The map object exposes methods to manipulate and find layers, objects and tiles.

*map.designedWidth* and *map.designedHeight* are the width and height of your map as specified in tiled's new map options. The map will be centered on the screen by default.

![Character in game](https://i.imgur.com/b6CpA65.png)

### Extensions

#### map:extend( types )

The *extend()* function attaches a lua code module to a *image object*. You can use this to build custom classes in your game.

### Custom Properties

The most exciting part of working in Tiled & Corona is the idea of custom properites. You can select any *image object* on any *object layer* in Tiled and add any number of custom properties. **berry** will apply those properties to the image object as it loads. This allows you to put physics properties, custom draw modes, user data, etc. on an in-game item via the editor.

![Custom Properties](https://i.imgur.com/bY9vfxC.png)

#### hasBody

One special custom property is *hasBody*. This triggers **berry** to add a physics body to an object/tile and pass the rest of the custom properties as physics options. Rectangle bodies are currently supported by default, adding a **radius** property will give you a round body. More complicated shape you can obtain by using the Collision Editor. No all shapes are supported.

![Setting a hasBody property](https://i.imgur.com/EoyRHK9.png)

#### isAnimated

One more special property you may want to use is *isAnimated*. This triggers **berry** to replace simple image object with animation created in Tiled. 

![Setting a isAnimated property](https://i.imgur.com/7GrkP6t.png)  

#### Example

See [Sticker-Knight-Platformer-for-Berry](https://github.com/ldurniat/Sticker-Knight-Platformer-for-Berry)

### What's next

- [ ] Support for hex maps
- [ ] Collision filter
- [ ] Parallax effect
- [ ] Camera effect
- [ ] Support for external tilesets
- [ ] Support for custom object types
- [ ] Support for multi-element bodies

### Images

All images come from 
 - [https://opengameart.org/content/free-platformer-game-tileset](https://opengameart.org/content/free-platformer-game-tileset)
 - [https://opengameart.org/content/free-dino-sprites](https://opengameart.org/content/free-dino-sprites)

### Donations

If you think that any information you obtained here is worth of some money and are willing to pay for it, feel free to send any amount through paypal. Thanks :) 

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/ldurniat)

### Contributing

If you have any idea, feel free to fork it and submit your changes back to me.

### License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/ldurniat/Berry/blob/master/LICENSE.txt) file for details.

### Acknowledgements 

**berry** is inspired by projects like [ponytiled](https://github.com/ponywolf/ponytiled) and [lime](https://github.com/OutlawGameTools/Lime2DTileEngine). 

