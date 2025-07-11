# TabControlEdit Sample

Delphi 向け拡張コンポーネント `TTabControlEdit` のサンプルアプリケーションです。

このサンプルでは、タブのキャプションをユーザーが直接編集できるようにするコンポーネント `TTabControlEdit` を動的に生成し、ポップアップメニューや編集イベントの利用方法を示します。

---

## 📦 使用コンポーネント

- `TTabControlEdit`（カスタム）  
  - タブの編集が可能な `TTabControl` の拡張版  
- `TPopupMenu` / `TMenuItem`  
  - 編集用の右クリックメニュー  
- `TMemo`  
  - 編集イベントのログ出力用  

---

## 🔧 実装ポイント

### TabControl の生成と設定

```pascal
FTabControl := TTabControlEdit.Create(Self);
FTabControl.Parent := Self;
FTabControl.Align := alClient;
FTabControl.PopupMenu := PopupMenu1;
```

### Memo の配置（注意: 行儀は良くない）

```pascal
Memo1.Parent := FTabControl;
Memo1.Align := alBottom;
```

### 編集メニューからタブ編集を開始

```pascal
procedure TFormMain.N1Click(Sender: TObject);
begin
  if FTabControl.TabIndex >= 0 then
    FTabControl.BeginEdit(FTabControl.TabIndex);
end;
```

### タブ編集イベントのログ出力

```pascal
procedure TFormMain.TabEditBegin(Sender: TObject; var EditStr: string);
begin
  Memo1.Lines.Add('EditBegin: ' + EditStr);
end;

procedure TFormMain.TabEditEnd(Sender: TObject; const EditStr: string);
begin
  Memo1.Lines.Add('EditEnd: ' + EditStr);
end;

procedure TFormMain.TabEditCancel(Sender: TObject);
begin
  Memo1.Lines.Add('EditCancel');
end;
```

---

## ▶️ 起動時の初期化処理

- `FormCreate`: コンポーネント生成・イベント登録
- `FormShow`: タブを3つ追加（「タブ1」「タブ2」「タブ3」）

---

## 📁 ファイル構成例

```
TabControlEditSample/
├── TabControlEdit.pas         ← 拡張コンポーネント本体
├── MainForm.pas / .dfm        ← このサンプルのフォーム
└── README.md                  ← この説明書
```

---

## 📘 備考

- Delphi 10.x 以降で動作確認
- `TabControlEdit` ユニットは自由に再利用・改造可能です
