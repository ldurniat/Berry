# berry
*berry* is a simple Tiled Map Loader for Corona SDK.

![Screenshot of berry in action](https://i.imgur.com/DbHD6EL.png)

**berry** supports only part of functionality offered to user by Tiled Map Editor. This includes tile and object layers, tilesets and collections of images. Neverthless it can be extended by using custom properties and executing custom code to gain more flexibility and control.  

Tested with Tiled v1.2.0

### List of features: 

- [x] Loads .JSON export from www.mapeditor.org
- [x] Adds basic properties from Tiled including physics
- [x] Supports object layers and tile layers
- [x] Supports collections of images and tileset images
- [x] Supports object x/y flipping and re-centering of anchorX/anchorY for Corona
- [x] Supports object animations using Tile Animation Editor
- [x] Rectangle shape with fillColor and strokeColor support
- [x] Supports custom collision shapes. Only rectangles and polygons for now
- [x] Supports Text object via plugins

### Quick Start Guide

```lua
local berry = require( 'pl.ldurniat.berry' )
local map   = berry.new( filename, tilesetsDirectory )
-- If you use composer you will need it as well
scene.view:insert( map ) 
```

### filename

The filename specify path to file with map.

![Saved Map](https://i.imgur.com/pCvRX2q.png)

#### tilesetsDirectory

Most of the time you will store you maps and images/tilesets in a directory. The tileSetsDirectory parameter overides where **berry** looks for images.

```lua
local map = berry.new( 'scene/game/map/level1.json', 'scene/game/map' ) -- look for images in /scene/game/map/
```

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

### What's next

- [ ] Support for isometric maps
- [ ] Support for hex maps
- [ ] Collision filter
- [ ] Parallax effect
- [ ] Camera effect
- [ ] Support for external tilesets
- [ ] Support for custom object types
- [ ] Support for multi-element bodies

### Donations

If you think that any information you obtained here is worth of some money and are willing to pay for it, feel free to send any amount through paypal. Thanks :) 

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/ldurniat)

### Contributing

If you have any idea, feel free to fork it and submit your changes back to me.

### License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/ldurniat/Berry/blob/master/LICENSE.txt) file for details.

### Acknowledgements 

**berry** is inspired by projects like [ponytiled](https://github.com/ponywolf/ponytiled) and [lime](https://github.com/OutlawGameTools/Lime2DTileEngine). 

