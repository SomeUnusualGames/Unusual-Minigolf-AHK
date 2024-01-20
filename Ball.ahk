#Include Utils.ahk

Class Ball {
  __New(x, y) {
    This.x := x
    This.y := y
    This.radius := 7.0
    This.offsetX := 0
    This.aiming := False
    This.moving := False
    This.angle := 0.0
    This.levelDone := False
    This.hits := 0
  }

  getSurroundTiles(gridX, gridY, tiles) {
    tileList := [tiles[gridY+1][gridX+1]]
    ; Push left tiles
    If gridX > 0 And gridY > 0 And gridY < 15 {
      tileList.Push(
        tiles[gridY][gridX],
        tiles[gridY+1][gridX],
        tiles[gridY+2][gridX]
      )
    }
    ; Push top tiles
    If gridY > 0 And gridX > 0 And gridX < 20  {
      tileList.Push(
        tiles[gridY][gridX],
        tiles[gridY][gridX+1],
        tiles[gridY][gridX+2]
      )
    }
    ; Push right tiles
    If gridX < 20 And gridY > 0 And gridY < 15 {
      tileList.Push(
        tiles[gridY][gridX+2],
        tiles[gridY+1][gridX+2],
        tiles[gridY+2][gridX+2]
      )
    }
    ; Push bottom tiles
    If gridY < 15 And gridX > 0 And gridX < 20  {
      tileList.Push(
        tiles[gridY+2][gridX],
        tiles[gridY+2][gridX+1],
        tiles[gridY+2][gridX+2]
      )
    }
    Return tileList
  }

  movement(angle, tiles, alreadyBounced, currentMap) {
    newX := This.x + (This.force/15) * Cos(angle)
    newY := This.y + (This.force/15) * Sin(angle)
    intersections := []
    gridX := Integer(newX)//64
    gridY := Integer(newY)//64
    Try {
      tileList := This.getSurroundTiles(gridX+1, gridY+1, tiles)
    } Catch {
      This.resetPosition(currentMap)
      Return
    }
    newAngle := angle
    For _, tile in tileList {
      For i, point In tile.walls {
        If i == tile.walls.Length {
          Break
        }
        tilePos := tile.getPos()
        wall := tile.getWall(i, tilePos.x, tilePos.y)
        intersects := Utils.intersectLineCircle(
          wall.x1, wall.y1, wall.x2, wall.y2,
          This.x, This.y, This.radius
        )
        If intersects {
          wallAngle := Utils.ATan2(wall.y2-wall.y1, wall.x2-wall.x1)
          intersections.Push({angle: This.angle, wallAngle: wallAngle})
        }
      }
    }
    If intersections.Length == 1 {
      newAngle := 2*intersections[1].wallAngle - This.angle
    } Else If intersections.Length > 1 {
      wallAngle := (intersections[1].wallAngle + intersections[2].wallAngle) / 2
      newAngle := 2*wallAngle - This.angle
    }
    If newAngle != angle And Not alreadyBounced {
      This.movement(newAngle, tiles, True, currentMap)
    } Else {
      This.angle := newAngle
      This.x := newX
      This.y := newY
    }
  }

  resetPosition(currentMap) {
    This.moving := False
    This.levelDone := False
    This.x := currentMap.ballSpawnX
    This.y := currentMap.ballSpawnY
  }

  updateSpecial(currentMap) {
    collidesCar := False
    logCol := 0
    For tr in currentMap.traffic {
      If tr.update(currentMap.width*64, This.x, This.y, This.radius) {
        This.resetPosition(currentMap)
      }
    }
    For l in currentMap.logs {
      collides := l.update(currentMap.width*64, This.x, This.y, This.radius)
      If collides != 0 {
        logCol := collides
      }
    }
    If logCol != 0 {
      This.offsetX := logCol.direction * logCol.speed
    } Else {
      This.offsetX := 0.0
    }
  }

  update(currentMap) {
    This.updateSpecial(currentMap)
    If This.levelDone {
      Return
    }
    If rl.IsMouseButtonPressed(0) And Not This.moving {
      This.aiming := Not This.aiming
      This.moving := Not This.aiming
      If This.moving {
        This.hits++
      }
    }
    If This.offsetX != 0 {
      This.x += This.offsetX
    }
    If This.moving {
      holeId := currentMap.checkHoleIntersection(This.x, This.y)
      If holeId > 0 {
        This.x := currentMap.holeX[holeId]
        This.y := currentMap.holeY[holeId]
        This.levelDone := True
        This.moving := False
        Return
      }
      ; Check portal
      portalPos := currentMap.checkPortalIntersection(
        This.x, This.y,
        currentMap.portal.orangePortal, currentMap.portal.bluePortal
      )
      If portalPos[1] > 0 {
        This.x -= (This.x - portalPos[1]*64) + 32
        This.y -= (This.y - portalPos[2]*64) + 32
        If This.force < 300 {
          This.force += 50.0
        }
      }
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
      If This.force > 0 {
        This.force -= tile.friction
        If This.force <= 0 {
          This.moving := False
        }
      }
      This.movement(This.angle, currentMap.tiles, False, currentMap)
    }
  }

  draw() {
    rl.DrawText("Hits: " . This.hits, 0, 920, 40, Color(255, 255, 255))
    rl.DrawCircle(This.x, This.y, This.radius, Color(255, 255, 255))
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
  }
}