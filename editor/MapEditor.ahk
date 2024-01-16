#Requires AutoHotkey v2.0.3 64-bit

#Include ../Raylib/Raylib.ahk
#Include ../Raylib/Rectangle.ahk
#Include ../Raylib/Vector2.ahk
#Include ../Raylib/Color.ahk

; Note: Id goes from A to ~ => 65 to 126

Class Tile {
  __New(id, x, y) {
    This.id := id
    This.sourceRect := Rectangle((Ord(id)-Ord("A"))*16, 0, 16, 16)
    This.destRect := Rectangle((x-1)*64, (y-1)*64, 64, 64)
    This.origin := Vector2(0, 0)
    This.color := Color(255, 255, 255)
  }

  setId(id) {
    This.id := Chr(id)
    This.sourceRect["x"] := (id - Ord("A"))*16
  }

  setPosition(x, y) {
    This.destRect["x"] := x
    This.destRect["y"] := y    
  }

  draw(rl, texture) {
    rl.DrawTexturePro(texture, This.sourceRect, This.destRect, This.origin, 0.0, This.color)
  }
}

Class Grid {
  __New(rl, width, height, texturePath) {
    This.rl := rl
    This.texture := This.rl.LoadTexture(texturePath)
    This.width := width
    This.height := height
    This.mapPath := ""
    This.tiles := []
    Loop This.height {
      y := A_Index
      This.tiles.Push([])
      Loop This.width {
        x := A_Index
        This.tiles[y].Push(Tile("A", x, y))
      }
    }
    This.selectedTile := Tile("B", 1, 1)
  }

  checkSelectedTile() {
    If This.rl.IsKeyPressed(Ord("D")) {
      This.selectedTile.setId(Ord(This.selectedTile.id)+1)
    } Else If This.rl.IsKeyPressed(Ord("A")) {
      This.selectedTile.setId(Ord(This.selectedTile.id)-1)
    }

    ; Enter: save map
    If This.rl.IsKeyPressed(257) {
      This.mapPath := InputBox("Input this map's name:", "Save map")
      mapName := "../custom/" . This.mapPath.Value
      If This.mapPath.Result != "Ok" {
        Return
      }
      If FileExist(mapName) {
        result := MsgBox(
          "Map " . This.mapPath.Value . " already exists, overwrite?",
          "WARNING",
          0x4
        )
        If result == "No" {
          Return
        }
        FileDelete(mapName)
      }
      result := ""
      For y, row In This.tiles {
        For x, tile In row {
          result := result . tile.id
        }
        If y < This.tiles.Length {
          result := result . "`n"
        }
      }
      FileAppend(result, mapName)
    }

    ; Space: Load map
    If This.rl.IsKeyPressed(32) {
      This.mapPath := InputBox("Input the map to load:", "Load map")
      If This.mapPath.Result != "Ok" {
        Return
      }
      If Not FileExist("../custom/" . This.mapPath.Value) {
        MsgBox("File " . This.mapPath.Value . " does not exist.", "Error")
        Return
      }
      mapFile := FileRead("../custom/" . This.mapPath.Value)
      mapSplit := StrSplit(mapFile, "`n")
      For y, row In mapSplit {
        rowSplit := StrSplit(row)
        For x, ch In rowSplit {
          If x < This.width {
            ;MsgBox x " " y " " ch
            This.tiles[y][x].setId(Ord(ch))
          }
        }
      }
    }


    If This.rl.IsMouseButtonDown(0) {
      x := Integer(This.selectedTile.destRect["x"])//64
      y := Integer(This.selectedTile.destRect["y"])//64
      This.tiles[y+1][x+1].setId(Ord(This.selectedTile.id))
    }
  }

  update() {
    This.checkSelectedTile()
    This.selectedTile.setPosition((This.rl.GetMouseX()//64)*64, (This.rl.GetMouseY()//64)*64)
  }

  draw() {
    Loop This.height {
      y := A_Index
      Loop This.width {
        x := A_Index
        This.tiles[y][x].draw(This.rl, This.texture)
      }
    }
    This.selectedTile.draw(This.rl, This.texture)
  }
}

Class MapEditor {
  __New(width, height) {
    This.rl := Raylib("../raylib.dll")
    This.rl.InitWindow(width, height, "Unusual MiniGolf Map Maker")
    This.rl.SetTargetFPS(60)
    This.grid := Grid(This.rl, width/64 + 1, height/64 + 1, "../assets/graphics/tiles2.png")
  }

  gameLoop() {
    While (!This.rl.WindowShouldClose()) {
      This.grid.update()
      This.rl.BeginDrawing()
      This.grid.draw()
      This.rl.EndDrawing()
    }
    This.rl.CloseWindow()
  }
}

me := MapEditor(1280, 960)
me.gameLoop()
; 1280 x 960 => 40 x 30 tiles
; 1280 x 960 => 20 x 15 tiles