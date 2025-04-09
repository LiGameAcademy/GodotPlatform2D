# source/systems/save/screenshot_capture.gd
extends Node
class_name ScreenshotCapture

func capture_game_screen() -> Image:
    # 等待一帧以确保UI更新
    await get_tree().process_frame
    
    # 捕获屏幕
    return get_viewport().get_texture().get_image()