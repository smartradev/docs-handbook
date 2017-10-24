# データセット{#dataset}

アルゴリズム作成に利用可能なデータセットは下記の通りです。

## jp.stock

日本の株式市場のデータです。


| キー | 說明  	| 指定例 |
|---	|---	|---	|
| symbols	| データを取得する銘柄コードを配列で指定します。銘柄コードは50種類まで指定可能です。 |
| columns	| symbolsで指定した銘柄において、取得するデータの種類を配列で指定します。 | 

### symbols

銘柄コードは、jp.stock.{銘柄コード} というような形式で指定します。

#### 指定例

7201, 7203の銘柄の時系列データを取得する場合

```python
channels={
  symbols: [ "jp.stock.7201", "jp.stock.7203" ]
  ...
```

### columns

各銘柄において取得するデータの種類を指定します。指定可能な値は次の通りです。

| 識別名 | 内容 | 株式分割調整の有無 |
|:-----------|:------------:|:------------:|
|open_price|始値 |     なし     |
|close_price|終値 |     なし     |
|high_price|高値 |     なし     |
|low_price|安値 |     なし     |
|volume|取引高 |     なし     |
|txn_volume|売買代金 |     なし     |
|open_price_adj|始値 |     あり     |
|close_price_adj|終値 |     あり     |
|high_price_adj|高値 |     あり     |
|low_price_adj|低値 |     あり     |
|volume_adj|取引高|     あり     |

#### 指定例

株式分割補正済終値と、株式分割補正済始値を取得する場合

```python
  ...
  columns: ["close_price_adj", "open_price_adj"]
  ...
```
## cn.stock

中国市場のデータです。

ratio[(0.8 < ratio) & (ratio < 0.91)]


ratio[ratio < 0.8] = 0.8
buy_sig = ratio[(0.8 <= ratio) & (ratio < 0.91)]
