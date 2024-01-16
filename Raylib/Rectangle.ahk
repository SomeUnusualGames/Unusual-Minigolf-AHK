Class Rectangle {
  __New(x, y, width, height) {
    This.rect := Buffer(4*4)
    NumPut("Float", x, This.rect, 0)
    NumPut("Float", y, This.rect, 4)
    NumPut("Float", width, This.rect, 8)
    NumPut("Float", height, This.rect, 12)
  }

  collides(rect) {
    Return (
      This["x"] <= rect["x"]+rect["width"] And
      This["x"]+This["width"] >= rect["x"] And
      This["y"] <= rect["y"] + rect["height"] And
      This["y"] + This["height"] >= rect["y"]
    )
  }

  Static Shift := {x: 0, y: 4, width: 8, height: 12}

  __Item[n] {
    Set => NumPut("Float", Value, This.rect, Rectangle.Shift.%n%)
    Get => NumGet(This.rect, Rectangle.Shift.%n%, "Float")    
  }

  Add(vec2) {
    Return Rectangle(
      This["x"]+vec2["x"],
      This["y"]+vec2["y"],
      This["width"], This["height"]     
    )
  }
}