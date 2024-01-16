Hello everyone, today I'm going to take a look at AutoHotkey.

AutoHotkey is a scripting language for Windows made for automating any kind of task that
involves the keyboard and mouse, execute commands, set macros, ~~cheating on games~~ and many other features.
Its main usage is the setting of hotkeys (or hotstrings) to execute a piece of code defined for that key.

Here you can see how easy is to setup hotkeys or hotstrings, and executing commands with `Run`:

```autohotkey
; hotstrings - expand 'btw' to 'By the way' as you type
::btw::By the way

; hotkeys - press winkey-z to go to Google
#z::Run "http://google.com"
```

This is another example where you can get and set the contents of the clipboard and send keystrokes very easily.

```autohotkey
; copy text to the clipboard, modify it, paste it back
^+k:: ; ctrl-shift-k
{
    ClipSave := ClipboardAll() ; store current clipboard
    A_Clipboard := "" ; clear the clipboard
    Send "^c" ; copy selected text
    if ClipWait(1) ; wait up to a second for content
    {
        ; wrap it in html-tags
        A_Clipboard := "<i>" A_Clipboard "</i>"
        Send "^v" ; paste
        Sleep 500 ; wait for Windows to complete paste
    }
    A_Clipboard := ClipSave ; restore old clipboard content
    ClipSave := "" ; clear variable
}
```

You can also interact with the script by creating graphical user interfaces, which is built-in into the language. Very useful to configure your scripts.

```autohotkey
; Easy to make GUIs
MyGui := Gui()
MyGui.Add("Text",, "Enter your name")
MyGui.Add("Edit", "w150 vName")
MyGui.Add("Button",, "OK").OnEvent("Click", SayHello)
MyGui.Show()
Return

SayHello(*)
{
    Saved := MyGui.Submit()
    MsgBox "Hello " Saved.Name
    ExitApp
}
```

You can see in these examples that you can declare variables like any other scripting language, but it also has arrays, control flow, different ways to loop, and even object oriented programming support. It pretty much has everything a general purpose programming language should have.

```autohotkey

; Array Objects
Colors := "Red,Green,Blue"           ; string
ColorArray := StrSplit(Colors, ",")  ; create array

ColorArray.Push("Purple")            ; add data

for index, element in ColorArray     ; Read from the array
    MsgBox "Color " index " = " element 
```

The origin of AutoHotkey is very interesting.
It starts up with a another very similar programming language called AutoIt. AutoIt started in 1999 when its developer, John Bennett, wanted to automate the installation of Windows, and there wasn't any reliable way to do that.
Fast forward to 2003, Chris Mallett made a proposal to integrate hotkey support to AutoIt, but it didn't get much attention from the community, so he built a new program from scratch based on AutoIt. That's where AutoHotkey came to live.
What's interesting is that, in 2005, AutoIt went from being open source using the GPL license to closed source because, apparently, there were several projects that "leeched" AutoIt code to their own projects without giving proper credit, violating the GPL license. I think it's understandable, I would also be pissed if someone took my code without giving me credit and disregarded the license.

Anyway, going back to AutoHotkey, even though it supports creating graphical user interfaces, I decided to use raylib to make the game. Let's see how we can call C code.

To execute C code, AutoHotkey provides a simple but powerful function called `DllCall`, which can be used to call any function compiled in dll files. To organize the code, I wrapped the raylib functions I used into a class, and set the functions as methods. All you have to do is pass the function you want to call and the parameters preceded by their type.

Functions that take ints, floats or strings are defined like this and that's it, but when it comes to passing C structs it's a bit more complicated. Let's take a look at, for example, this function `DrawRectangleRec`, which takes a rectangle and a color.

[color class]

Here I created a class to handle the `Color` struct, which is pretty simple: just _pack_ the rgba values into a single integer by shifting the values and that's it, we can pass that integer to the C function. I also added a getter and a setter to make it easier to change the colors, when we set or get `color[value]` (the variable and a value between square brackets) and pass r, g, b or a as the color, that value is "inserted" between the percent signs, so you don't have to specify the different values, which I think it's a nice feature.

The rectangle object is not as simple as the color. Here, I have to create a `Buffer` object, which is a block of memory that holds the values. You have to provide the number of bytes to allocate (each float value is 4 bytes, and we have to store the x, y, width and height so it's 16 bytes) and then use `NumPut` to set the values with their corresponding offset. When I tried to pass this buffer to the C code it crashed. This is because **almost all of raylib functions takes parameters by value and not by reference**. Fortunately, the easiest fix was to go to raylib source code, change that parameter to a pointer, and change all the lines where the code access to the struct from a dot to an arrow. Recompile it, replace the dll and boom, now it works!
The second thing I had to change was the way textures are loaded, since I needed a pointer to the texture. I simply allocated memory and returned the pointer. Now that I can draw rectangles and images, I'm ready to make the game.

Here, I made a top-down minigolf game. It consists of 5 levels, each with a different "mechanic": 
- A regular map
- A map similar to Frogger
- Spikes
- A map with two holes and ice
- And a map with portals

The game can be break down into four main parts:

- The ball movement
- Checking when the ball collides with the walls
- Checking when the ball enters the hole
- Checking when the ball collides with a _special_ object, like cars or spikes

```autohotkey
If rl.IsMouseButtonPressed(0) And Not This.moving {
  This.aiming := Not This.aiming
  This.moving := Not This.aiming
  If This.moving {
    This.hits++
  }
}

; in the draw function:

If This.aiming {
  mouseX := rl.GetMouseX()
  mouseY := rl.GetMouseY()
  This.force := 1.5 * Utils.distance(mouseX, mouseY, This.x, This.y)
  If This.force > 200 {
    This.force := 200
  }
  This.angle := Utils.ATan2(mouseY-This.y, mouseX-This.x) - 3.141592
  rl.DrawLineEx(
    Vector2(This.x, This.y),
    Vector2(This.x+This.force*Cos(This.angle), This.y+This.force*Sin(This.angle)),
    3.0, Color(255, 0, 0)
  )
}

```
First, when the user clicks, the aiming mode is set. The force the ball will be hit is defined as the distance between the mouse and the ball, multiplied by 1.5. Then, we get the angle between the mouse and the ball, substracted by 180 degrees so the line is drawn in the same direction the ball will move.

When the user clicks again, the "moving" mode is set. When the ball is moving, we have to check for different intersections:

Intersection with any hole: simply check the distance between the ball and any hole, and if it is less or equal than the hole radius, then we draw the ball inside the hole and finish the level.

```autohotkey
  holeId := currentMap.checkHoleIntersection(This.x, This.y)
  If holeId > 0 {
    This.x := currentMap.holeX[holeId]
    This.y := currentMap.holeY[holeId]
    This.levelDone := True
    This.moving := False
    Return
  }
```

Intersection with any portal: again, it's as simple as checking the distance between the ball and the portals. In this case, there's an extra variable to check when the players touches the portal for the first time, to avoid teleporting back. The portals also increase the force.

```autohotkey
  portalPos := currentMap.checkPortalIntersection(This.x, This.y, currentMap.portal.orangePortal, currentMap.portal.bluePortal)
  If portalPos[1] > 0 {
    This.x -= (This.x - portalPos[1]*64) + 32
    This.y -= (This.y - portalPos[2]*64) + 32
    If This.force < 300 {
      This.force += 50.0
    }
  }
```

Then, we get the tile the player is currently in. This is wrapped in a try/catch block because right now, there's a problem with the collision where the player can go out of the grid which would crash the game, so this way it is possible to prevent that from happening.
With the tile it is possible to check if the player is touching lava, spikes or a pit, in which case we simply reset the game.

```autohotkey
  Try {
    gridX := Integer(This.x) // 64
    gridY := Integer(This.y) // 64
    tile := currentMap.tiles[gridY+1][gridX+1]
  } Catch {
    This.resetPosition(currentMap)
    Return  
  }
  If tile.id == GolfMap.specialTiles.Lava And This.offsetX == 0 Or tile.id == GolfMap.specialTiles.Spikes {
    This.resetPosition(currentMap)
    Return
  } Else If tile.id == GolfMap.specialTiles.Pit {
    This.resetPosition(currentMap)
    Return
  }
```

Finally, we substract the friction from the force and then we move the ball.
```
  If This.force > 0 {
    This.force -= tile.friction
    If This.force <= 0 {
      This.moving := False
    }
  }
  This.movement(This.angle, currentMap.tiles, False, currentMap)
```

For the movement, I get the nine surrounding tiles and check for collision. The ball new angle is two times the angle of the wall minus the angle of the ball. If the ball touches two walls, I use the middle angle between the two walls.
```autohotkey
	If intersections.Length == 1 {
	  newAngle := 2*intersections[1].wallAngle - This.angle
	  MsgBox "one intersection, new angle: " . newAngle*180.0/3.14159265
	} Else If intersections.Length > 1 {
	  wallAngle := (intersections[1].wallAngle + intersections[2].wallAngle) / 2
	  newAngle := 2*wallAngle - This.angle
	  MsgBox "two intersections, new angle: " . newAngle*180.0/3.14159265
	}
```
Here I made a visualization of the way I get the collision between the wall and the ball:

- Get the x and y components of the wall (called dx and dy) and the components of the ball (ex and ey)
- Calculate the dot product (sum of the multiplication of the components)
- Get the wall length
- Divide the dot product with the length and we get the projection of the ball vector onto the wall
- Get the x and y position of the closest point to the ball inside the wall, represented by this cyan circle
- Finally, measure the distance between the closest point and the ball, if it's less or equal than the ball radius, there's collision. Ez!

For the second level, if the ball collides with any car, the game restarts. The logs simply adds an offset to the movement of the ball, so it moves with the log.
As I said before, each tile has its own friction. In this case, the street tiles have slightly less, and this sand tile has much more so the ball stops immediately.

The third level has tiles that switch between spikes and no-spikes. When the ball touches the spikes the game resets.

The fourth level has two holes. Before starting the game, when a fake hole is detected the real one is randomly set. Also, the light blue tiles are _ice_ so they have very little friction.

In the last level, the player can shoot portals only when the ball is moving. The green dots are drawn one by one before reaching the mouse or a wall.

```autohotkey
  drawLine(ballX, ballY, currentMap) {
    x := ballX
    y := ballY
    targetX := rl.GetMouseX()
    targetY := rl.GetMouseY()
    angle := Utils.ATan2(targetY-y, targetX-x)
    While Abs(x-targetX) > 10 Or Abs(y-targetY) > 10 {
      gridX := (Integer(x)//64) + 1
      gridY := (Integer(y)//64) + 1
      tileId := currentMap.tiles[gridY][gridX].id
      ; Is the tile not a wall?
      If Ord(tileId) < Ord("B") Or Ord(tileId) > Ord("J") {
        rl.DrawCircle(x, y, 3, Color(0, 255, 0))
        If Abs(x-targetX) > 1 {
          x += 20 * Cos(angle)
        }
        If Abs(y-targetY) > 1 {
          y += 20 * Sin(angle)
        }
      } Else {
        Break
      }
    }
    If IsSet(gridX) And IsSet(gridY) {
      This.cursor := [gridX, gridY]
    }
  }
```

To move between the portals is simply substracting the difference between the current position and the target portal, plus 32 so the player spawns in the middle (each tile is 64x64).

```autohotkey
  This.x -= (This.x - portalPos[1]*64) + 32
  This.y -= (This.y - portalPos[2]*64) + 32
```

Finally, I want to show the program I made to make the maps. I don't really know how people store grid maps, but what I do is to set each tile with a specific character in the ASCII table, starting from uppercase A (which is 65) all the way up to the underscore (95). Each character is unique so it's used as an identifier.
Making the map is as simple as geting the x-y position of the mouse when clicking and convert the "world" position to "grid" position, then replace the character with the selected tile's character. Saving the map is just writing that string to a file. This is what I always do when I make gridded maps.

To end this, I want to point out some features of this language that in my opinion makes it unique, or at least different from most programming languages.

### Loop statements

With `Loop` you can specify how many times to repeat a block of code. The only way to get the loop index is to check what it's called a built-in variable `A_Index`, which contains the current loop interation and automatically updates every time the loop is completed. Even if you have nested Loops, the inner loop takes precedence, so you would have to store the value before entering a second Loop.

What's interesting is that `Loop` has other uses beside repeating a block of code:

- Using `Loop Files` you can loop through a list of files or folders. I used it to read the contents of the _custom_ folder, which contains maps made by the player. In this loop, new built-in variables are available to get the name or the path of the file.
- `Loop Parse` can be used to loop through substrings, which uses less memory and it's easier to use than splitting the string and looping manually.
- `Loop Read` loops through lines in a text file.
- `Loop Reg` loops through the contents of a registry subkey.

I want to remark that these are built-in into the language, and it's funny because I didn't know you could loop through the contents of a file like this until I started making this video. To load the maps I read the file and looped manually like this:

```autohotkey
mapText := FileRead(mapPath)
splittedText := StrSplit(mapText, "`n")
For y, text In splittedText {
  This.tiles.Push([])
  ids := StrSplit(text)
  For x, id In ids {
    Switch id {
      ; ...
    }
  }
}
```

By using a combination of `Loop Read` and `Loop Parse`, the resuling code is much more simple:

```autohotkey
Loop Read, mapPath {
  y := A_Index
  This.tiles.Push([])
  Loop Parse, A_LoopReadLine {
    x := A_Index
    id := A_LoopField
    Switch id {
      ; ...
    }
```
Other nice features are:
- Reloading or even pausing the script with `Reload` and `Pause`
- #Directives similar to those in C
- Timer functions similar to those in Javascript

And many more features.

So yeah, AutoHotkey is a powerful scripting language capable of more than just creating macros and hotkeys. It helps a lot that AutoHotkey has a simple syntax very close to Python's syntax, so people who don't have much experience programming have an easier time learning this language, and they could easily transfer that knowledge to Python if they wanted to.



The game:
- How to detect when the ball touches a wall
- How to calculate the ball new angle when boucing
- The map maker
- The second level, how the cars and the logs work
- Third level
- Fourth level, friction
- Fifth level, portals
- Map maker