# 数据包{#dataset}

以下是制作策略组合时可以使用的数据包。

## jp.stock

日本股票市场的数据。


| Key | 说明 |
|---	|---	|---	|
| symbols	| 用配列指定获取数据的证券代码。可以最多指定50个证券代码。 |
| columns	| 关于symbols指定的证券，指定获取的数据种类。 | 

### symbols

证券代码以jp.stock.{证券代码} 的形式进行指定。

#### 指定的例子

获取证券代码为7201, 7203的证券数据时的表述

```python
channels={
  symbols: [ "jp.stock.7201", "jp.stock.7203" ]
  ...
```

### columns

指定各股票需获取的数据种类。以下是能使用的数据种类。

| 识别名 | 内容 | 是否调整股票拆细 |
|:-----------|:------------:|:------------:|
|open_price|开盘价 |     否     |
|close_price|收盘价 |     否     |
|high_price|最高价 |     否     |
|low_price|最低价 |     否     |
|volume|成交量 |     否     |
|txn_volume|成交金额 |     否     |
|open_price_adj|开盘价 |     是     |
|close_price_adj|收盘价|     是     |
|high_price_adj|最高价 |     是     |
|low_price_adj|最低价 |     是     |
|volume_adj|成交量|     是     |

#### 指定的例子

获取调整股票拆细后的收盘价和开盘价时的表述

```python
  ...
  columns: ["close_price_adj", "open_price_adj"]
  ...
```


## 例子

获取证券代码为"7201"、"7203"的股票（调整股票拆细后）收盘价和（调整股票拆细后）开盘价时
在initialize()函数中，用以下形式调出ctx.configure()。

```python
  ctx.configure(channels={
      "jp.stock": {
          "symbols": [ "jp.stock.7201", "jp.stock.7203" ],
          "columns": [ "close_price_adj", "open_price_adj" ]
      }
  }
         
```

