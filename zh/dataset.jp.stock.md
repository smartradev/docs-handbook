# 数据包{#dataset}

以下将介绍在策略制作时可读取的数据已经读取方法。

## jp.stock

是日本股票市场的数据。


| Key | 说明 |
|---	|---	|---	|
| symbols	| 一维数组储存股票池中的证券代码。可以最多指定50个证券代码。 |
| columns	| 一维数组指定所读取个股的信息。 | 

### symbols

证券代码以jp.stock.{证券代码} 的形式进行指定。

#### 实例

假如要获取证券代码为7201, 7203的证券数据：

```python
channels={
  symbols: [ "jp.stock.7201", "jp.stock.7203" ]
  ...
```

### columns

指定个股所需获取的数据种类。目前可提供的数据种类有：

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

#### 实例

获取调整股票拆细后的收盘价和开盘价：

```python
  ...
  columns: ["close_price_adj", "open_price_adj"]
  ...
```


## 例子

如要获取证券代码为"7201"、"7203"的股票（调整股票拆细后）收盘价和（调整股票拆细后）开盘价，则
在initialize()函数中，可使用ctx.configure()定义如下：

```python
  ctx.configure(channels={
      "jp.stock": {
          "symbols": [ "jp.stock.7201", "jp.stock.7203" ],
          "columns": [ "close_price_adj", "open_price_adj" ]
      }
  }

```
