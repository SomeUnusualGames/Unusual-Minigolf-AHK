Class Utils {
  Static distance(x1, y1, x2, y2) {
    Return Sqrt((x1-x2)**2 + (y1-y2)**2)
  }

  Static ATan2(y, x) {
    If x > 0 {
      Return ATan(y/x)
    } Else If y > 0 {
      Return (3.141592/2) - ATan(x/y)
    } Else If y < 0 {
      Return -((3.141592/2) + ATan(x/y))
    } Else If x < 0 {
      Return ATan(y/x) + 3.141592
    } Else {
      Return 0.0
    }
  }

  Static intersectLineCircle(lineStartX, lineStartY, lineEndX, lineEndY, circleCenterX, circleCenterY, radius) {
    dx := lineEndX - lineStartX
    dy := lineEndY - lineStartY
    ex := circleCenterX - lineStartX
    ey := circleCenterY - lineStartY
  
    dotProduct := ex * dx + ey * dy
    lineLength := Sqrt(dx**2 + dy**2)
    projection := dotProduct / lineLength
    projection := Max(0, Min(projection, lineLength))

    closestPointX := lineStartX + (dx * projection) / lineLength
    closestPointY := lineStartY + (dy * projection) / lineLength

    distance := Sqrt((closestPointX - circleCenterX)**2 + (closestPointY - circleCenterY)**2)

    Return Floor(distance) <= radius
  }

  ; From raymath
  Static reflect(v, normal) {
    result := Vector2(0, 0)
    dotProduct := (v["x"]*normal["x"] + v["y"]*normal["y"])
    result["x"] := v["x"] - (2*normal["x"])*dotProduct
    result["y"] := v["y"] - (2*normal["y"])*dotProduct
    Return result
  }

  Static sign(x) {
    If x == 0 {
      Return 0
    }
    Return x < 0 ? -1 : 1
  }

  Static collisionPointRec(rec, x, y) {
    Return x >= rec["x"] And x <= rec["x"]+rec["width"] And y >= rec["y"] And y <= rec["y"]+rec["height"]
  }
}