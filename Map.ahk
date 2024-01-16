#Include Wall.ahk
#Include Special/Traffic.ahk
#Include Special/Log.ahk
#Include Special/Portal.ahk

tileWalls := {
  B: [[16, 16], [0, 16]],
  C: [[0, 0], [16, 0]],
  D: [[0, 16], [0, 0]],
  E: [[16, 0], [16, 16]],
  F: [[0, 16], [16, 0]],
  G: [[0, 0], [16, 16]],
  H: [[0, 0], [16, 16]],
  ;I: [[13, 0], [16, 0], [16, 16], [0, 16], [0, 13], [13, 0]],
  I: [[16, 0], [0, 16]],
  J: [[0, 0], [16, 0], [16, 16], [0, 16], [0, 0]]
}

tileSize := 64

Class Tile {
  __New(id, x, y) {
    This.id := id
    This.sourceRect := Rectangle((Ord(id)-Ord("A"))*16, 0, 16, 16)
    This.destRect := Rectangle((x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
    This.origin := Vector2(0, 0)
    This.color := Color(255, 255, 255)
    This.walls := []
    If id == "O" Or id == "P" {
      This.friction := 0.3 ; Street
    } Else If id == "K" {
      This.friction := 10.0 ; Sand
    } Else If id == "[" {
      This.friction := 0.01 ; Ice
    } Else {
      This.friction := 0.5
    }
    If Ord(id) >= 66 And Ord(id) <= 74 {
      This.walls := tileWalls.%id%
    }
  }

  getPos() {
    Return {x: This.destRect["x"], y: This.destRect["y"]}
  }

  getGridPos() {
    Return {
      x: Integer(This.destRect["x"])//64,
      y: Integer(This.destRect["y"])//64
    }
  }

  setId(id) {
    ; Street
    If id == "O" Or id == "P" {
      This.friction := 0.3
    } Else If id == "K" {
      This.friction := 10.0
    } Else {
      This.friction := 0.5
    }
    This.sourceRect := Rectangle((Ord(id)-Ord("A"))*16, 0, 16, 16)
    This.id := id
  }

  getWall(i, offsetX, offsetY) {
    Return {
      x1: 4*This.walls[i][1] + offsetX,
      y1: 4*This.walls[i][2] + offsetY,
      x2: 4*This.walls[i+1][1] + offsetX,
      y2: 4*This.walls[i+1][2] + offsetY
    }
  }

  draw(texture) {
    rl.DrawTexturePro(texture, This.sourceRect, This.destRect, This.origin, 0.0, This.color)
    If This.walls.Length == 0 {
      Return
    }
    For i, point In This.walls {
      If i == This.walls.Length {
        Break
      }
      wall := This.getWall(i, This.destRect["x"], This.destRect["y"])
      ;rl.DrawLine(wall.x1, wall.y1, wall.x2, wall.y2, Color(255, 255, 255))
    }
  }
}

Class GolfMap {
  Static specialTiles := {
    Pit: "O",
    Spikes: "S",
    Lava: "V",
    FakeHole: "\",
    PortalFree: "]",
    PortalOrange: "_",
    PortalBlue: "^"
  }

  createTiles(mapPath) {
    fakeHoles := []
    Loop Read, mapPath {
      y := A_Index
      This.tiles.Push([])
      Loop Parse, A_LoopReadLine {
        x := A_Index
        id := A_LoopField
        Switch id {
          Case "R":
            This.spikeTimer := 1.0
            This.spikeList.Push([x, y])
          Case "S":
            This.spikeTimer := 1.0
            This.spikeList.Push([x, y])
          Case "U":
            This.ballSpawnX := (x-1)*tileSize + tileSize//2
            This.ballSpawnY := (y-1)*tileSize + tileSize//2
          Case "T":
            This.holeX.Push((x-1)*tileSize + (tileSize//2) - 4)
            This.holeY.Push((y-1)*tileSize + (tileSize//2) - 4)
          Case "W":
            This.traffic.Push(
              Traffic(
                Rectangle(0, 16, 48, 24), 180.0,
                (x-2)*tileSize, (y-1)*tileSize, 1
              )
            )
            id := "P"
          Case "X":
            This.traffic.Push(
              Traffic(
                Rectangle(0, 40, 48, 24), 0.0,
                (x+1)*tileSize, (y-1)*tileSize, -1
              )
            )
            id := "P"
          Case "Y":
            This.logs.Push(Logs(Rectangle(48, 16, 48, 24), (x-2)*tileSize, (y-1)*tileSize, 1))
            id := "V"
          Case "Z":
            This.logs.Push(Logs(Rectangle(48, 16, 48, 24), (x+1)*tileSize, (y-1)*tileSize, -1))
            id := "V"
          Case "\":
            fakeHoles.Push([x, y])
          Case "]":
            This.portalX.Push((x-1)*tileSize + (tileSize//2) - 2)
            This.portalY.Push((y-1)*tileSize + (tileSize//2) - 2)
            This.portal.enable := True
        }
        This.tiles[y].Push(Tile(id, x, y))
      }
    }
    fakeHolesCount := fakeHoles.Length
    If fakeHolesCount == 0 {
      Return
    }
    realHoleIndex := fakeHoles[Random(1, fakeHolesCount)]
    This.tiles[realHoleIndex[2]][realHoleIndex[1]].setId("T")
    This.holeX.Push((realHoleIndex[1]-1)*tileSize + (tileSize//2) - 4)
    This.holeY.Push((realHoleIndex[2]-1)*tileSize + (tileSize//2) - 4)
  }

  __New(width, height, mapLvl, texturePath, isCustom) {
    This.texture := rl.LoadTexture(texturePath)

    This.tiles := []
    This.width := width
    This.height := height
    This.currentLvl := mapLvl
    This.isCustom := isCustom
    This.mapNames := isCustom ? customNames : mapNames

    This.holeRadius := 13
    This.holeX := []
    This.holeY := []
    This.waitReleasePortal := False

    This.portalRadius := 25
    This.portalX := []
    This.portalY := []
    
    This.traffic := []
    This.logs := []
    This.portal := Portal()
    This.spikeList := []
    This.spikeTimer := 0.0

    If isCustom {
      This.createTiles("custom/" . This.mapNames[mapLvl])
    } Else {
      This.createTiles("maps/level" . mapLvl . " - " . StrReplace(This.mapNames[mapLvl], "!?", ""))
    }
  }

  checkHoleIntersection(ballX, ballY) {
    Loop This.holeX.Length {
      i := A_Index
      If (ballX-This.holeX[i])**2 + (ballY-This.holeY[i])**2 <= This.holeRadius*This.holeRadius {
        Return i
      }
    }
    Return 0
  }

  checkPortalIntersection(ballX, ballY, orangePos, bluePos) {
    Loop This.portalX.Length {
      i := A_Index
      If (ballX-This.portalX[i])**2 + (ballY-This.portalY[i])**2 <= This.portalRadius**2 {
        If This.waitReleasePortal {
          Return [-1, -1]
        }
        x := This.portalX[i]//64 + 1
        y := This.portalY[i]//64 + 1
        id := This.tiles[y][x].id
        If id == GolfMap.specialTiles.PortalBlue And orangePos[1] > 0 {
          This.waitReleasePortal := True
          Return orangePos
        } Else If id == GolfMap.specialTiles.PortalOrange And bluePos[1] > 0 {
          This.waitReleasePortal := True
          Return bluePos
        }
        Return [-1, -1]
      }
    }
    This.waitReleasePortal := False
    Return [-1, -1]
  }

  update(playerMoving) {
    If This.portal.enable And playerMoving {
      This.portal.update(This)
    }
    If This.spikeTimer > 0 {
      This.spikeTimer -= 0.0166
      If This.spikeTimer <= 0 {
        This.spikeTimer := 1.0
        For tiles In This.spikeList {
          This.tiles[tiles[2]][tiles[1]].setId(This.tiles[tiles[2]][tiles[1]].id == "R" ? "S" : "R")
        }
      }
    }
  }

  draw(ball) {
    Loop This.height {
      y := A_Index
      Loop This.width {
        x := A_Index
        This.tiles[y][x].draw(This.texture)
      }
    }
    Loop This.holeX.Length {
      i := A_Index
      ;rl.DrawCircle(This.holeX[i], This.holeY[i], This.holeRadius, Color(255, 0, 0, 120))
    }
    ;Loop This.portalX.Length {
    ;  i := A_Index
    ;  rl.DrawCircle(This.portalX[i], This.portalY[i], This.portalRadius, Color(0, 255, 0, 120))
    ;}
    For tr in This.traffic {
      tr.draw(This.texture)
    }
    For l in This.logs {
      l.draw(This.texture)
    }
    If ball.moving and This.portal.enable {
      This.portal.drawLine(ball.x, ball.y, This)
    }
    rl.DrawText("Level: " . This.mapNames[This.currentLvl], 0, 0, 30, Color(255, 255, 255))
  }
}