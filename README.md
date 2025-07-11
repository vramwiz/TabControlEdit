# TabControlEdit.pas - タブキャプション編集対応 TTabControl 拡張ユニット

`TabControlEdit.pas` は、Delphi 標準の `TTabControl` を拡張し、**タブのキャプションをインプレースで編集可能**にするコンポーネント `TTabControlEdit` を提供するユニットです。

---

## 📌 主な特徴

- ダブルクリックやメニュー操作によるタブキャプションの直接編集
- 編集開始・終了・キャンセル時にイベントを発生
- 外部から任意のタブの編集を開始可能
- 編集中の状態を自動的に管理し、フォーカス移動やキー操作にも対応

---

## 🔧 提供されるイベント

| イベント名        | タイミング              | 引数の説明                       |
|-------------------|--------------------------|----------------------------------|
| `OnEditBegin`     | 編集を開始するとき       | 編集対象文字列を `var` で渡す   |
| `OnEditEnd`       | 編集を確定して終了したとき| 編集後の文字列を受け取る        |
| `OnEditCancel`    | 編集がキャンセルされたとき| 引数なし                         |

```pascal
type
  TEditTabControlBegin = procedure(Sender: TObject; var EditStr: string) of object;
  TEditTabControlEnd   = procedure(Sender: TObject; const EditStr: string) of object;
```

---

## 🚀 使い方の例（動的生成）

```pascal
procedure TForm1.FormCreate(Sender: TObject);
begin
  Tab := TTabControlEdit.Create(Self);
  Tab.Parent := Self;
  Tab.Align := alTop;
  Tab.Tabs.Add('タブ1');
  Tab.Tabs.Add('タブ2');
  Tab.OnEditEnd := TabEditEnd;
end;

procedure TForm1.TabEditEnd(Sender: TObject; const EditStr: string);
begin
  ShowMessage('変更後: ' + EditStr);
end;
```

外部から編集を開始したい場合：

```pascal
Tab.BeginEdit(Tab.TabIndex);  // 選択中タブの編集を開始
```

---

## ⚠ 注意事項

- `TTabControl` を継承しているため、`TPageControl` とは互換性がありません。
- 編集を開始するタイミングはマウス操作だけでなく、メニューやショートカットからも可能です。
- 編集フィールド (`TEdit`) は必要に応じて動的に表示／非表示されます。

---

## 📝 ライセンス

このユニットは MIT ライセンス等、任意の自由なライセンス形態で利用できます。商用・非商用問わずご自由にお使いください。

---

## 📁 含まれるファイル

- `TabControlEdit.pas` : 本体ユニット
