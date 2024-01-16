Class Vector2 {
    __New(x, y) {
      This.vec2 := Buffer(4*2)
      NumPut("Float", x, This.vec2, 0)
      NumPut("Float", y, This.vec2, 4)
    }

    magnitude() {
      Return Sqrt(This["x"]*This["x"] + This["y"]*This["y"])
    }

    normalize(magnitude, newMagnitude) {
      This["x"] := (This["x"] / magnitude) * newMagnitude
      This["y"] := (This["y"] / magnitude) * newMagnitude
    }

    equals(other) {
      Return This["x"] == other["x"] And This["y"] == other["y"]
    }

    Static Shift := {x: 0, y: 4}
  
    __Item[n] {
      Set => NumPut("Float", Value, This.vec2, Vector2.Shift.%n%)
      Get => NumGet(This.vec2, Vector2.Shift.%n%, "Float")
    }
  }

