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
- [x] **Properties -** *Property copying for objects, tiles, layers, and maps*

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

#### Properties inheritance

**Berry** also applies the tile properties and layer properties and add these to the *image object*. Properties are assigned in prioirty:  

1. Object
2. Tile
3. Layer

If the same property amongst these is present when inheriting, the property with the highest priority gets assigned.

```lua
  -- Object inherits from tile and layer
  Object.foo = 31
  Tile.foo = 'Huzah'
  Layer.foo = true
  print(Object.foo) -- 31

  -- Pretend Object didn't have a foo property
  Object.foo = nil
  Tile.foo = 'Huzah'
  Layer.foo = true
  print(Object.foo) -- Huzah

  etc.
```

#### Physics

One special custom property is *hasBody*. This triggers **berry** to add a physics body to an object/tile and pass the rest of the custom properties as physics options. Rectangle bodies are currently supported by default, adding a **radius** property will give you a round body. More complicated shape you can obtain by using the Collision Editor. No all shapes are supported.

![Setting a hasBody property](https://i.imgur.com/EoyRHK9.png)

#### Animation

Tiled has an animation editor to bring images to life. *Berry* has several features to take advantage of this. By adding certain properties to a tile in the editor the animation can be configured. These properties are the same as they are to [configure CoronaSDK sprites](https://docs.coronalabs.com/api/library/display/newSprite.html#sequencedata):

- name (name of the animation)
- time (time of the animation, 1000 = 1 second)
- loopCount (optional) (number of times to loop the animation, defaults is 0 for infinite)
- loopDirection (optional) (how to play the animation, default is forward)

**Note - CoronaSDK does not support *individual* frame durations for animations.**

Instead *Berry* calculates the sum of all the frame durations for an animation and uses it for the time variable. Every frame will play at the same average duration.  If a `time` custom property is given, it will use this to calculate animation time instead.

Another special property is *isAnimated*. Without it, none of the animations will play by default. `isAnimated` can be set to true or false for the map, layer, object, or tile. Inheritance rules applies to this property in order of prioirty:

1. Object
2. Tile
3. Layer
4. Map

Some examples of this behavior:

```lua
  -- Example 1 --> only the map is set to true
  Map.isAnimated = true  
  -- Result = all animations will play

  -- Example 2 --> map is set to false and objects set to true
  Map.isAnimated = false
  Object1 -- no isAnimated property set
  Object2.isAnimated = true
  -- Result = Object 2 animation plays, Object 1 does not 

  -- Example 3 -->
  Map -- not set
  Layer1.isAnimated = true 
    Object1 -- not set
    Object2.isAnimated = false
  Layer2.isAnimated = false
    Object3 -- not set
    Object4.isAnimated = true
  Layer3 -- not set
    Object5
  -- Result = Object 1 and 4 animations plays, Object 2, 3, and 5 does not

```

![Setting a isAnimated property](https://i.imgur.com/7GrkP6t.png)  

#### Example

See [Sticker-Knight-Platformer-for-Berry](https://github.com/ldurniat/Sticker-Knight-Platformer-for-Berry)

### What's next

- [ ] Support for hex maps
- [ ] Collision filter
- [ ] Parallax effect
- [ ] Camera effect
- [ ] Support for external tilesets
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

