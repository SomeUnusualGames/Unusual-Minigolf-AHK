Class Raylib {
  __New(dll) {
    This.dll := dll
    if !This.hLib := DllCall("LoadLibrary", "Str", dll, "Ptr") {
      throw "Failed to load raylib dll. Error: " . A_LastError
    }
  }

  InitWindow(width, height, title) {
    DllCall(This.dll . "\InitWindow", "Int", width, "Int", height, "AStr", title)
  }

  SetTargetFPS(fps) {
    DllCall(This.dll . "\SetTargetFPS", "Int", fps)
  }

  WindowShouldClose() {
    Return DllCall(This.dll . "\WindowShouldClose")
  }

  GetRenderWidth() {
    Return DllCall(This.dll . "\GetRenderWidth")
  }

  GetRenderHeight() {
    Return DllCall(This.dll . "\GetRenderHeight")
  }

  ClearBackground(color) {
    DllCall(This.dll . "\ClearBackground", "UInt", color.RGBA)
  }

  BeginDrawing() {
    DllCall(This.dll . "\BeginDrawing")
  }

  EndDrawing() {
    DllCall(This.dll . "\EndDrawing")
  }

  CloseWindow() {
    DllCall(This.dll . "\CloseWindow")
    DllCall("FreeLibrary", "Ptr", This.hLib)
  }

  GetFrameTime() {
    Return DllCall(This.dll . "\GetFrameTime", "CDecl Double")
  }

  LoadTexture(path) {
    Return DllCall(This.dll . "\LoadTexture", "AStr", path, "Cdecl Ptr")
  }

  UnloadTexture(texture) {
    DllCall(This.dll . "\UnloadTexture", "Ptr", texture)
  }

  DrawTexture(texture, x, y, color) {
    DllCall(This.dll . "\DrawTexture", "Ptr", texture, "Int", x, "Int", y, "UInt", color.RGBA)
  }

  DrawTexturePro(texture, source, dest, origin, rotation, color) {
    DllCall(This.dll . "\DrawTexturePro", "Ptr", texture, "Ptr", source.rect, "Ptr", dest.rect, "Ptr", origin.vec2, "Float", rotation, "UInt", color.RGBA)
  }

  DrawRectangleRec(rect, color) {
    DllCall(This.dll . "\DrawRectangleRec", "Ptr", rect.rect, "UInt", color.RGBA)
  }

  DrawFPS(x, y) {
    DllCall(This.dll . "\DrawFPS", "Int", x, "Int", y)
  }

  IsKeyDown(key) {
    Return DllCall(This.dll . "\IsKeyDown", "Int", key, "CDecl Int")
  }

  IsKeyPressed(key) {
    Return DllCall(This.dll . "\IsKeyPressed", "Int", key, "Cdecl Int")
  }

  DrawText(text, x, y, size, color) {
    DllCall(This.dll . "\DrawText", "AStr", text, "Int", x, "Int", y, "Int", size, "UInt", color.RGBA)
  }

  DrawLine(startPosX, startPosY, endPosX, endPosY, color) {
    DllCall(This.dll . "\DrawLine", "Int", startPosX, "Int", startPosY, "Int", endPosX, "Int", endPosY, "UInt", color.RGBA)
  }

  DrawCircle(x, y, radius, color) {
    DllCall(This.dll . "\DrawCircle", "Int", x, "Int", y, "Float", radius, "UInt", color.RGBA)
  }

  IsMouseButtonPressed(button) {
    Return DllCall(This.dll . "\IsMouseButtonPressed", "Int", button)
  }

  IsMouseButtonDown(button) {
    Return DllCall(This.dll . "\IsMouseButtonDown", "Int", button)
  }

  GetMouseX() {
    Return DllCall(This.dll . "\GetMouseX")
  }

  GetMouseY() {
    Return DllCall(This.dll . "\GetMouseY")
  }
  
  GetMousePosition() {
    Return {x: This.GetMouseX(), y: This.GetMouseY()}
  }

  DrawLineEx(startPos, endPos, thick, color) {
    DllCall(This.dll . "\DrawLineEx", "Ptr", startPos.vec2, "Ptr", endPos.vec2, "Float", thick, "UInt", color.RGBA)
  }

  CheckCollisionCircleRec(center, radius, rec) {
    Return DllCall(This.dll . "\CheckCollisionCircleRec", "Ptr", center.vec2, "Float", radius, "Ptr", rec.rect)
  }

  MeasureText(text) {
    Return DllCall(This.dll . "\MeasureText", "AStr", text)
  }

  InitAudioDevice() {
    DllCall(This.dll . "\InitAudioDevice")
  }

  CloseAudioDevice() {
    DllCall(This.dll . "\CloseAudioDevice")
  }
  
  LoadMusicStream(path) {
    Return DllCall(This.dll . "\LoadMusicStream", "AStr", path, "Cdecl Ptr")
  }

  PlayMusicStream(music) {
    DllCall(This.dll . "\PlayMusicStream", "Ptr", music)
  }

  UpdateMusicStream(music) {
    DllCall(This.dll . "\UpdateMusicStream", "Ptr", music)
  }

  UnloadMusicStream(music) {
    DllCall(This.dll . "\UnloadMusicStream", "Ptr", music)
  }
}