# berry
*berry* is a simple Tiled Map Loader for Corona SDK.

![Screenshot of berry in action](https://i.imgur.com/DbHD6EL.png)

**berry** supports only part of functionality offered to user by Tiled. This includes tile and object layers, tilesets and collections of images. Neverthless it can be extended by using custom properties and executing custom code to gain more flexibility and control.  

### List of features: 

- [x] Loads .JSON export from www.mapeditor.org
- [x] Adds basic properties from Tiled including physics
- [x] Supports object layers and tile layers
- [x] Supports collections of images and tileset images
- [x] Supports object x/y flipping and re-centering of anchorX/anchorY for Corona
- [x] Supports object animations using Corona sequences
- [x] Rectangle shape with fillColor and strokeColor support
- [x] Supports custom collision shapes. Only rectangles and polygons for now
- [x] Supports Text object

### Quick Start Guide

```lua
berry = require( 'pl.ldurniat.berry' )
local map = berry.loadMap( filename, tileSetsDirectory )
local visual = berry.createVisual( map )
berry.buildPhysical( map )
```

### filename

The filename specify path to file with map.

![Saved Map](https://i.imgur.com/pCvRX2q.png)

#### tileSetsDirectory

Most of the time you will store you maps and images/tilesets in a directory. The tileSetsDirectory parameter overides where **berry** looks for images.

```lua
local map = berry.loadMap( 'scene/game/map/sandbox.json', 'scene/game/map' ) -- look for images in /scene/game/map/
```

#### map

The map object exposes methods to manipulate adn find layers, objects and tiles. The most important are listed below:

Method name                              | Description 
-----------------------------------------|-------------------------------------------------------------------------------
*map:hide()*                             | Hides the Map.
*map:show()*                             | Shows the Map.
*map:move( x, y )*                       | Moves the Map.
*map:setRotation( angle )*               | Sets the rotation of the Map.
*map:rotate( angle )*                    | Rotates the Map.
*map:setScale( xScale, yScale )*         | Sets the scale of the Map.
*map:scale( xScale, yScale )*            | Scales the Map.
*map:getScale()*                         | Gets the scale of the Map.
*map:setPosition( x, y )*                | Sets the position of the Map.
*map:getPosition()*                      | Gets the position of the Map.
*map:getTilesWithProperty( name )*       | Gets a list of Tiles across all TileLayers that have a specified property.
*map:getObjectsWithProperty( name )*     | Gets a list of Objects across all ObjectLayers that have a specified property.
*map:getObjectsWithName( name )*         | Gets a list of Objects across all ObjectLayers that have a specified name.
*map:getObjectWithName( name )*          | Gets a first Object across all ObjectLayers that have a specified name.
*map:getObjectsWithType( objectType )*   | Gets a list of Objects across all ObjectLayers that have a specified type.
*map:getTileLayer( indexOrName )*        | Gets a TileLayer.
*map:getObjectLayer( indexOrName )*      | Gets an ObjectLayer.
*map:getTileLayersWithProperty( name )*  | Gets a list of TileLayers across the map that have a specified property.
*map:getObjectLayersWithProperty( name )*| Gets a list of ObjectLayers across the map that have a specified property.


*map.designedWidth* and *map.designedHeight* are the width and height of your map as specified in tiled's new map options. The map will be centered on the screen by default.

![Character in game](https://i.imgur.com/b6CpA65.png)

### visual

**berry** returns a group object that contains all the layers, objects and tiles for the exported map. 

### Extensions

#### map:extendObjects( types )

The *extendObjects()* function attaches a lua code module to a *image object*. You can use this to build custom classes in your game.

### Custom Properties

The most exciting part of working in Tiled & Corona is the idea of custom properites. You can select any *image object* on any *object layer* in Tiled and add any number of custom properties. **berry** will apply those properties to the image object as it loads. This allows you to put physics properties, custom draw modes, user data, etc. on an in-game item via the editor.

Note: Tile properties will not be inherited by objects so you have to add it to objects itself with the exception of animation properties. 

![Custom Properties](https://i.imgur.com/bY9vfxC.png)

#### hasBody

One special custom property is *hasBody*. This triggers **berry** to add a physics body to an object/tile and pass the rest of the custom properties as physics options. Rectangle bodies are currently supported by default, adding a **radius** property will give you a round body. More complicated shape you can obtain by using the Collision Editor. No all shapes are supported.

![Setting a hasBody property](https://i.imgur.com/EoyRHK9.png)

#### isAnimated

One more special property you may want to use is *isAnimated*. This triggers **berry** to replace simple image object with animation created in Tiled using the Animation Editor. 

![Setting a isAnimated property](https://i.imgur.com/7GrkP6t.png)  

### Debug information

To gain some useful information about what is going on use `berry:enableDebugMode()` and `berry:enableDebugMode()` methods. If debug mode is enabled **berry** print out simple messages what he is doing. Use `berry:isDebugModeEnabled()` to check if debug mode is currently enabled or disabled. 

### Example

See [Sticker-Knight-Platformer](https://github.com/ldurniat/Sticker-Knight-Platformer-and-Berry) and wiki. 

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

