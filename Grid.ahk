Class Tile {
  Static State := {Empty: 0, Wall: 1, Player: 2}

  __New(x, y) {
    This.rect := Rectangle(x, y, 64, 64)
    This.state := Tile.State.Empty
    This.color := Color(0, 0, 0, 40)
  }

  draw(offsetPos) {
    rl.DrawRectangleRec(
      Rectangle(
        This.rect["x"] - offsetPos["x"] + rl.GetRenderWidth() // 2,
        This.rect["y"] - offsetPos["y"] + rl.GetRenderHeight() // 2,
        This.rect["width"], This.rect["height"]
      ),
      This.color
    )
  }
}


Class Grid {
  __New(width, height) {
    This.tiles := []
    This.structures := []
    Loop height {
      y := A_Index
      This.tiles.Push([])
      Loop width {
        x := A_Index
        This.tiles[y].Push(Tile((x-1)*64, (y-1)*64))
      }
    }
  }

  addStructure(st) {
    This.structures.Push(st)
    For i, wall In st.walls {
      y := wall.rect["y"]
      x := wall.rect["x"]
      Loop {
        Loop {
          gridX := (Floor(x) // 64) + 1
          gridY := (Floor(y) // 64) + 1
          This.tiles[gridY][gridX].state := Tile.State.Wall
          This.tiles[gridY][gridX].color := wall.color
          x += 64
        } Until x > wall.rect["x"] + wall.rect["width"]
        x := wall.rect["x"]
        y += 64
      } Until y > wall.rect["y"] + wall.rect["height"]
    }
  }

  collision(playerGridPos) {
    For i, st In This.structures {
      For j, wall In st.walls {
        If wall.getGridPosition().equals(playerGridPos) {
          Return True
        }
      }
    }
    Return False
  }

  draw(offsetPosition) {
    For y, row In This.tiles {
      For x, tile In row {
        ;If t.state != Tile.State.Empty {
          tile.draw(offsetPosition)
        ;}
      }
    }
  }
}