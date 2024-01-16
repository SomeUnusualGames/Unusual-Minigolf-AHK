Class Portal {

  __New() {
    This.cursor := [1, 1]
    This.bluePortal := [-1, -1]
    This.orangePortal := [-1, -1]
    This.enable := False
  }

  update(currentMap) {
    id := currentMap.tiles[This.cursor[2]][This.cursor[1]].id
    canPlacePortal := (id == GolfMap.specialTiles.PortalFree)
    If rl.IsMouseButtonPressed(0) And canPlacePortal {
      If This.bluePortal[1] > 0 {
        currentMap.tiles[This.bluePortal[2]][This.bluePortal[1]].setId("]")
      }
      This.bluePortal := This.cursor
      currentMap.tiles[This.cursor[2]][This.cursor[1]].setId("^")
    } Else If rl.IsMouseButtonPressed(1) And canPlacePortal {
      If This.orangePortal[1] > 0 {
        currentMap.tiles[This.orangePortal[2]][This.orangePortal[1]].setId("]")
      }
      This.orangePortal := This.cursor
      currentMap.tiles[This.cursor[2]][This.cursor[1]].setId("_")
    }
  }

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
    ;rl.DrawLine(ballX, ballY, rl.GetMouseX(), rl.GetMouseY(), Color(0, 255, 0))
  }
}