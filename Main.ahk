#Requires AutoHotkey v2.0.3

#Include Raylib/Raylib.ahk
#Include Game.ahk

; TODO: Fix wall hitting corners and going through the walls
Global rl := Raylib("dll/raylib.dll")
rl.InitWindow(1280, 960, "Unusual MiniGolf")
rl.SetTargetFPS(60)

g := Game()

While (!rl.WindowShouldClose() And !g.menu.exitGame) {
  g.update()
  rl.BeginDrawing()
  rl.ClearBackground(Color(0, 0, 0))
  g.draw()
  ;rl.DrawFPS(0, 0)
  rl.EndDrawing()
}
rl.UnloadTexture(g.currentMap.texture)
rl.CloseWindow()
ExitApp 0