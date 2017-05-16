## cn.stock

中国の株式市場のデータです。


| キー | 說明 |
|---	|---	|---	|
| symbols	| データを取得する銘柄コードを配列で指定します。銘柄コードは50種類まで指定可能です。 |
| columns	| symbolsで指定した銘柄において、取得するデータの種類を配列で指定します。 | 

### symbols

銘柄コードは、cn.stock.{銘柄コード} というような形式で指定します。

#### 指定例

600037, 603833の銘柄の時系列データを取得する場合

```python
channels={
  symbols: [ "cn.stock.600037", "cn.stock.603833" ]
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


## 例

銘柄、"600037"、"603833" の、株式分割調整後終値と株式分割調整後始値を取得したい場合は、
initialize()関数の中で次のような形式で、ctx.configure()を呼び出します。

```python
  ctx.configure(channels={
      "jp.stock": {
          "symbols": [ "cn.stock.600037", "cn.stock.603833" ],
          "columns": [ "close_price_adj", "open_price_adj" ]
      }
  }
         
```
