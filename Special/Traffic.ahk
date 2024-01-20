#Include ../Raylib/Rectangle.ahk
#Include ../Raylib/Color.ahk
#Include Movable.ahk

Class Car Extends Movable {
  __New(rect, direction) {
    Super.__New(rect, direction, 2.3)
  }
}

Class Traffic {
  __New(originRect, angle, spawnX, spawnY, direction) {
    This.originRect := originRect
    This.angle := angle
    This.vehicles := []
    Loop 4 {
      i := A_Index
      This.vehicles.Push(
        Car(Rectangle(spawnX+350*i*direction, spawnY, 128, 64), direction)
      )
    }
  }

  update(mapWidth, ballX, ballY, ballRadius) {
    collides := False
    For vehicle In This.vehicles {
      vehicle.move(mapWidth)
      If vehicle.collides(ballX, ballY, ballRadius) {
        collides := True
      }
    }
    Return collides
  }


  draw(texture) {
    For vehicle In This.vehicles {
      originVec := Vector2(vehicle.rect["width"]/2, vehicle.rect["height"]/2)
      vehicle.drawTexture(
        texture, This.originRect,
        vehicle.rect.Add(originVec),
        originVec,
        This.angle, Color(255, 255, 255)
      )
      ;vehicle.draw()
    }
  }
}