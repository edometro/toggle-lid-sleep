# toggle-lid-sleep

Ubuntu 等の systemd 環境において、ノートPCの「蓋を閉じたときのスリープ機能」をCLIで簡単に切り替える（トグルする）ためのツールです。

`systemd-inhibit` コマンドを利用してスリープを一時的にブロックする方式を採用しているため、**管理者権限（sudo）が不要**で、システムの恒久的な設定ファイル（`logind.conf`など）を汚しません。また、切り替え時にデスクトップ通知（`notify-send`）を表示します。

## 特徴
- **コマンド一発でトグル:** 実行するたびに スリープ有効 ↔ スリープ無効 が切り替わります。
- **sudo不要:** ユーザー権限のまま実行可能です。
- **一時的な変更:** システムを再起動するとデフォルト（スリープ有効）に戻るため安全です。
- **デスクトップ通知:** 状態が切り替わったことをポップアップでわかりやすく通知します。

## 対象環境
- Ubuntu / Debian など、`systemd` および `notify-send` が利用可能な Linux デスクトップ環境

## インストール方法

```bash
git clone https://github.com/edometro/toggle-lid-sleep.git
cd toggle-lid-sleep
chmod +x toggle-lid-sleep.sh
# ユーザーごとの実行パス (例: ~/.local/bin) に配置することをおすすめします
cp toggle-lid-sleep.sh ~/.local/bin/toggle-lid-sleep
```
※ `~/.local/bin` に PATH が通っていることを確認してください。

## 使い方

ターミナルやランチャーから以下のコマンドを実行するだけです。

```bash
toggle-lid-sleep
```

実行するたびに、以下の動作を交互に行います：
1. **スリープ無効化**: 蓋を閉じてもスリープしなくなります（`systemd-inhibit` をバックグラウンドで起動）。
2. **スリープ有効化**: 蓋を閉じるとスリープする通常の状態に戻ります（バックグラウンドのプロセスを終了）。

## 仕組み
1. 実行時、`/tmp/toggle-lid-sleep.pid` にプロセスの状態を記録します。
2. スリープを無効にする際、`systemd-inhibit --what=handle-lid-switch:sleep` をバックグラウンドで実行し、ラップトップがスリープに入るのをブロックします。
3. 再度実行されると、記録されたPIDをもとにブロックプロセスを終了（kill）し、通常のスリープ挙動に戻します。

## ライセンス
MIT License
