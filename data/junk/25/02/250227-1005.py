import json

# DAP-UIのデフォルトアイコン（可能性がある文字コード）
dap_icons = {
    "expanded": "\u25be",     # ▾
    "collapsed": "\u25b8",    # ▸
    "current_frame": "\u25b8", # ▸
    "pause": "\u23f8",        # ⏸
    "play": "\u25b6",         # ▶
    "step_into": "\u21b5",    # ↵
    "step_over": "\u21c5",    # ⇅
    "step_out": "\u21c4",     # ⇄
    "step_back": "\u2190",    # ←
    "run_last": "\u25b6\u25b6", # ▶▶
    "terminate": "\u23f9"     # ⏹
}

# アイコンとそのUnicodeポイントを表示
for name, icon in dap_icons.items():
    # 複数文字の場合の対応
    if len(icon) > 1:
        hex_codes = " ".join([f"U+{ord(c):04X}" for c in icon])
        print(f"{name}: {icon} - {hex_codes}")
    else:
        print(f"{name}: {icon} - U+{ord(icon):04X}")

# JSON形式でも出力
print("\nJSON形式:")
json_data = {}
for name, icon in dap_icons.items():
    if len(icon) > 1:
        json_data[name] = " ".join([f"U+{ord(c):04X}" for c in icon])
    else:
        json_data[name] = f"U+{ord(icon):04X}"
print(json.dumps(json_data, indent=2))
