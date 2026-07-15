#!/bin/bash

PID_FILE="/tmp/toggle-lid-sleep.pid"

# プロセスが生きているか確認
if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    # プロセスが生きている -> 現在はスリープ無効状態
    # ブロックしているプロセスを終了させる
    kill $(cat "$PID_FILE")
    rm -f "$PID_FILE"
    
    echo "ラップトップの蓋を閉じたらスリープするように設定しました（スリープ有効）"
    notify-send "Lid Sleep Enabled" "蓋を閉じるとスリープします。" -i computer
else
    # プロセスが存在しない -> 現在はスリープ有効状態
    # バックグラウンドでブロックを開始する
    systemd-inhibit --what=handle-lid-switch:sleep --who="toggle-lid-sleep" --why="User requested" sleep infinity &
    
    # バックグラウンドで起動した systemd-inhibit の PID を保存
    echo $! > "$PID_FILE"
    
    echo "ラップトップの蓋を閉じてもスリープしないように設定しました（スリープ無効）"
    notify-send "Lid Sleep Disabled" "蓋を閉じてもスリープしません。" -i computer
fi
