# jp.bitflyer

----

### 注

*本データセットは、QuantX Engine Ver. maron-0.1.0 以降で利用可能です。*  
*また、データセット仕様は確定しておらず、正式リリースの際には変更される可能性があります。*

----

[bitflyer.jp](https://bitflyer.jp/) の取引所のデータです。利用する場合は、アルゴリズム初期化時に、次のようなパラメータを指定してctx.configure()を呼び出す必要があります。

| パラメータ名 | 說明 |
|---	|---	|---	|
| target	| 対象とするデータセットを指定します。 `jp.bitflyer` を指定する必要があります。なお、 `target="jp.bitflyer"` を指定した場合には、その他の時間軸の異なるデータ・セット(`jp.stock.daily`, etc.)を利用することはできません。jp.bitflyerを設定すると、ベンチマークとして、jp.bitflyer.BTC_JPY.close_price が利用されます。 |
| frequency	| 本データセットでは、日足未満のデータを扱うことが可能で、4本値の周期を開発者が指定可能で、その周期を文字列で指定します。<br>15分足を用いてアルゴリズムを記述する場合: `ctx.configure(..., frequency="15Min", ....)`<br>15秒足を用いてアルゴリズムを記述する場合: `ctx.configure(..., frequency="15S", ....)` |
| channels | 利用するデータセットを指定します。 |

### channelsの書式

利用するデータ・セットの定義をDictionaryで指定します。
 

channelsは次のように指定します。


```python
  ctx.configure(target="jp.bitflyer", channels={
      "jp.bitflyer": {
          "symbols": [ "jp.bitflyer.BTC_JPY" ],
          "columns": [ "close_price", "open_price" ]
      }
  }, ...)
         
```

#### symbols

利用する通貨ペアを指定します。現在、次の2種類が利用可能です。

* jp.bitflyer.BTC_JPY
* jp.bitflyer.FX_BTC_JPY

#### columns

各通貨ペアにおいて取得するデータの種類を指定します。  
指定可能な値は次の通りです。open, close, high, lowは、指定したfrequencyに基づいた定義となります。

| 識別名 | 内容 | 
|:-----------|:------------:|:------------:|
|open_price|取引価格の始値 |
|close_price|取引価格の終値 |
|high_price|取引価格の高値 |
|low_price|取引価格の安値 |
|open_best_bid_price|bid価格の始値 |
|close_best_bid_price|bid価格の終値 |
|high_best_bid_price|bid価格の高値 |
|low_best_bid_price|bid価格の安値 |
|open_best_ask_price|ask価格の始値 |
|close_best_ask_price|ask価格の終値 |
|high_best_ask_price|ask価格の高値 |
|low_best_ask_price|ask価格の安値 |
|bid_size| best_bid_priceの板の厚さ |
|ask_size| best_ask_priceの板の厚さ |
|total_bid_depth| bid板の厚さ |
|total_ask_depth| ask板の厚さ |
|volume|取引高 |


##### 指定例

bid価格の終値と、ask価格の終値

```python
  ...
  columns: ["close_best_bid_price", "close_best_ask_price"]
  ...
```


### データの範囲

2018年2月1日以降のデータが存在します。
2018年以前は断片的なデータが存在します。

### バックテストの挙動

* 約定価格として、 `close_best_ask`, `close_best_bid` が利用されます。
* 約定のタイムラグとして、1-tick利用されます。1-tickの単位は、開発者がfrequencyで設定した時間となります。
