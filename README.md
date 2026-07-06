# toggle-lid-sleep

Ubuntu (systemd環境) において、ノートPCの「蓋を閉じたときのスリープ機能」をCLIで簡単に切り替える（トグルする）ためのツールです。

現在の環境（Ubuntu 24.04.4 LTS / systemd 255）に最適化されており、`/etc/systemd/logind.conf` の `HandleLidSwitch` を安全に書き換え、自動でサービスを再起動して設定を反映させます。

## 特徴
- **コマンド一発で切り替え:** 長い設定ファイルを毎回エディタで開く必要はありません。
- **現在の状態表示:** 現在「蓋を閉じるとスリープする」状態なのか、「何もしない」状態なのかを素早く確認できます。
- **安全な操作:** `logind.conf` の元の設定を壊さないように、`HandleLidSwitch` 行のみを正確に更新します。

## 対象環境
- Ubuntu 20.04 / 22.04 / 24.04 LTS (確認済み: Ubuntu 24.04.4 LTS)
- systemd を採用しているLinuxディストリビューション全般

## インストール方法

```bash
git clone https://github.com/yourusername/toggle-lid-sleep.git
cd toggle-lid-sleep
chmod +x toggle-lid-sleep.sh
sudo cp toggle-lid-sleep.sh /usr/local/bin/toggle-lid-sleep
```

## 使い方

システム設定を変更するため、実行には `sudo` 権限が必要です。

### 状態の確認
現在の設定状態を確認します。
```bash
toggle-lid-sleep status
```

### スリープを無効にする（蓋を閉じても起動したままにする）
クラムシェルモードやサーバー用途で、蓋を閉じても動作を続けさせたい場合に使用します。
```bash
sudo toggle-lid-sleep off
```

### スリープを有効にする（デフォルトに戻す）
蓋を閉じたらスリープするように戻します。
```bash
sudo toggle-lid-sleep on
```

### 状態をトグルする（切り替える）
現在の状態を読み取り、逆の状態に切り替えます。
```bash
sudo toggle-lid-sleep toggle
```

## 仕組み
このスクリプトは以下のシステム操作を行っています：
1. `/etc/systemd/logind.conf` の `HandleLidSwitch` パラメータを `ignore` (無効) または `suspend` (有効) に書き換えます。
2. `sudo systemctl restart systemd-logind` を実行し、変更を即座にシステムに反映させます。

## ライセンス
MIT License
