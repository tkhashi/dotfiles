# 0001. NocFreeのBluetooth接続中にスリープ復帰するとKarabinerプロファイルがLaptopのままになるバグ

- Status: Accepted
- Date: 2026-08-11

## Context(背景・問題)

NocFree&(Bluetooth接続のキーボード)がペアリング・接続済みの状態でMacをスリープさせ、その後復帰させると、本来 `NocFree&` プロファイルが選択されるべきところ `Laptop` プロファイルのままになってしまう不具合が発生した。

調査は3段階に分かれた。最初の2つの仮説はいずれも部分的な問題ではあったが、実際の不具合を解消するには至らなかった。

## Decision(原因)

### 仮説1(不十分): リトライ回数不足

`triggers/watchers/power.lua` の復帰時トリガーが、スリープ復帰イベント発火時に `0.5秒後`→1回目、さらに`1.2秒後`(復帰から計約2.3秒後)→2回目(保険)の**固定2回**しか `input.profile.reconcile` を dispatch していなかった。macOSはスリープ復帰直後、Bluetoothスタックが既知デバイスを再接続するまで数秒〜十数秒かかることがあるため、2.3秒以内の判定では間に合わないケースがあると考え、リトライを `{0.5, 2, 4, 7, 11, 15}` 秒・6回に拡張した。

→ この修正だけでは直らなかった。

### 仮説2(不十分): Hammerspoonのbluetooth権限不足

`blueutil --paired --format json` を手動実行すると `Error: Received abort signal, ... absence of access to Bluetooth API` が発生。macOSのTCC権限データベース(`~/Library/Application Support/com.apple.TCC/TCC.db`)を確認したところ、Hammerspoon(`org.hammerspoon.Hammerspoon`)にBluetooth権限のエントリが存在しなかった。システム設定 > プライバシーとセキュリティ > Bluetooth でHammerspoonを許可してもらい、`repositories/blueutil.lua` に権限エラーを検知して通知するコードも追加した。

→ 権限自体は必要な修正だったが、これでも直らなかった(reload直後にLaptopになる別事象は残った)。

### 仮説3(不十分): reload/起動時パスのリトライ不足

`init.lua` の起動時reconcileが `hs.timer.doAfter(1.0, ...)` の**1回のみ**で、`power.lua` 同様の複数回リトライを行っていなかった。これを `{1.0, 2.5, 5}` 秒・3回に拡張した。

→ reloadでも改善しなかった。

### 本当の原因: NocFree&のBLEマルチチャンネルによるBluetoothアドレス不一致

`system_profiler SPBluetoothDataType` で実機のBluetooth接続状況を確認したところ、NocFree&はBLEマルチチャンネル対応キーボードで、チャンネル(BLE1/BLE2/BLE3)ごとに**異なるBluetoothアドレス**を持つことが判明した。

```
Connected:
    NocFree & BLE1:
        Address: D9:02:8A:19:EB:E1
Not Connected:
    NocFree & BLE3:
        Address: C8:49:68:C2:70:35
```

修正前の `repositories/blueutil.lua` の `M.NOCFREE.ADDR` は `c8-49-68-c2-70-35`(BLE3)を固定で監視していたが、実際に接続されるのはBLE1のアドレス(`D9:02:8A:19:EB:E1`)だった。そもそも監視しているBluetoothアドレス自体が実際に接続されるチャンネルと異なっていたため、権限を修正しリトライ回数をいくら増やしても `blueutil.isDeviceConnected()` は恒久的に `false` を返し続け、`Laptop` が選択されていた。

仮説1・2の修正(リトライ拡張・権限修正)自体は無関係ではなく、実環境で必要な前提条件だった(権限がなければ`blueutil`は常にabortする)。しかし決定的な原因はアドレス固定によるミスマッチだった。

## Consequences(修正内容・影響)

1. **`repositories/blueutil.lua`**: `M.NOCFREE` からアドレス固定の判定をやめ、名前部分一致で判定する `M.isDeviceConnectedByName(namePattern)` / `M.isNocFreeConnected()` を追加。`getPairedDevices()` で取得した各デバイスの `name` フィールドが `"nocfree"` を含み、かつ `connected` であれば接続中と判定する。どのBLEチャンネル(BLE1/BLE2/BLE3)で接続されても検出できるようになった。
2. Bluetooth権限エラー発生時に `hs.notify` で明示的に警告する処理を追加(`isPermissionError` / `warnIfPermissionError`)。今後同種の権限エラーが起きても「BT未接続」と静かに誤判定せず、目に見える形で気づけるようにした。
3. **`commands/input.lua`**: NocFree BT判定を `blueutil.isDeviceConnected(blueutil.NOCFREE.ADDR)` から `blueutil.isNocFreeConnected()` に変更。
4. **`triggers/watchers/power.lua`**: 復帰時reconcileを `{0.5, 2, 4, 7, 11, 15}` 秒・6回のリトライに変更(仮説1修正分。決定的な原因ではなかったが、BT再接続の遅延に対する保険として有効なため維持)。
5. **`init.lua`**: 起動/reload時reconcileを `{1.0, 2.5, 5}` 秒・3回のリトライに変更(仮説3修正分。同様に保険として維持)。

実機でのスリープ復帰テストにより、`NocFree&` プロファイルへ正しく切り替わることを確認済み。

### 残課題

- `triggers/watchers/usb.lua` の `reconcileAfter()` にも「固定回数・短時間打ち切り」の構造が残っている。USB接続イベントは接続/切断そのものがトリガーになるため問題が顕在化しにくいが、理論上は同種の不具合が起こり得る。
- 同じBLEマルチチャンネル問題が `Naya Create`(`blueutil.TARGET.ADDR` によるアドレス固定判定)にも当てはまる可能性がある。今回はNocFree&のみ報告されたため`Naya Create`側は未修正。同様の症状が出た場合は同じ名前一致方式への切り替えを検討する。
- 教訓: Bluetoothデバイス、特にマルチデバイスペアリング/マルチチャンネル対応機器は、macOS側で複数の論理デバイス(異なるアドレス)として扱われることがある。固定アドレスでの接続判定は避け、名前などの安定した属性で判定する方が堅牢。
