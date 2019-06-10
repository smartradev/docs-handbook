# APIリファレンス

## ctx{#ctx}

  initialize や handle_signals の引数として渡されるオブジェクト。
アルゴリズムの状態(Context)を保持します。

#### logger: [TinyLogging](#TinyLogging)

  後述する [TinyLogging](#TinyLogging) オブジェクト
  
#### portfolio: [Portfolio](#Portfolio)

  handle_signalsに渡された時にセットされます。現在のアルゴリズムの取引状況を保持します。
  
#### localStorage: dict

  次回handle_signals()が呼び出された時に保存しておきたいデータを保存しておく領域です。
ここに設定した値は、次回以降も設定されたままでhandle_signals()が呼び出されることが保証されます。

#### configure(target, channels) : void

  initialize内でContextの設定をするためのメソッド。

|パラメータ名|型|意味|例|
|---|---|---|---|
|target|String|タイプ(市場+足)を指定する|jp.stock.daily|
|channels|dict|各市場をキーにして、取引対象銘柄名(symbols)や使用する指標値(columns)を指定する|　|

```python
    channels={          # 利用チャンネル
      "jp.stock": {
        "symbols": [
          "jp.stock.7201",
          "jp.stock.9201",
          "jp.stock.9202",
          "jp.stock.7203"
        ],
        "columns": [
          "open_price_adj",    # 始値(株式分割調整後)
          "high_price_adj",    # 高値(株式分割調整後)
          "low_price_adj",     # 安値(株式分割調整後)
          "close_price",        # 終値
          "close_price_adj",    # 終値(株式分割調整後) 
          "volume_adj",         # 出来高
          "txn_volume",         # 売買代金
        ]
```

#### regist_signal(name, handler) : void

  initialize内でシグナルハンドラ関数を登録するためのメソッド。
  
|パラメータ名|型|意味|例|
|---|---|---|---|
|name|String|名称(何でもよい)|"my_signal"|
|handler|function|シグナルハンドラ関数|　|


#### getSecurity(sym) : [Security](#Security)

  指定された銘柄のSecurityオブジェクトを取得します。

|パラメータ名|型|意味|例|
|---|---|---|---|
|sym|String|銘柄|"jp.stock.7201"|

---

## TinyLogging{#TinyLogging}

  Pythonのlogging APIと同じ仕様で、以下のメソッドがあります。

```python
    def debug()
    def info()
    def warn()
    def error()
    def critical()
```

  それぞれのログレベルで、コンソールにログメッセージが出力されます。

---

## Portfolio{#Portfolio}

  ポートフォリオを管理するオブジェクト

#### portfolio.positions : dict
   保有している各銘柄にす関する情報を格納しているdict
   keyはsymbolで、次のような値を持ちます

```python
     {
                "amount": asset.amount,                          # 保有株数
                "total_buy_price": asset.total_buy_price,        # 今までの総購入額
                "total_sell_price": asset.total_sell_price,      # 今までの総売却額
                "buy_price": bp,                                 # 現在のポジションの総購入額(amountが0になると0にリセットされる)
                "sell_price": sp,                                # 現在のポジションの総売却額(amountが0になると0にリセットされる)
                "value": value,                                  # 現在の評価額
                "position_ratio": position_ratio,                # 保有銘柄の中での割合,
                "portfolio_ratio": portfolio_ratio,              # 資産全体での割合
                "pnl": value - (bp - sp),                        # 損益額
                "returns": returns                               # 損益率

     }
```

---

## Security{#Security}

  銘柄を表すオブジェクト。 ctx.getSecurity() で取得できます。
  このオブジェクトを使用して注文を行ないます。
  
#### code(): number

  code値を返す(ex. 9984)
  
#### unit(): number

  売買単位を返す(ex. 100)
  
#### order(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

数量を指定して注文を行ないます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|注文数。株式の場合は株数となります。|sec.unit() * 1|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 | |
|limit_price|number|order_typeが `OrderType.LIMIT_PRICE` のときの指値を指定します。 | LIMIT_PRICE=1000 |


#### order_value(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

金額を指定して注文を行ないます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|金額。指定された金額内で注文を行ないます。|100000|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 | |
|limit_price|number|order_typeが `OrderType.LIMIT_PRICE` のときの指値を指定します。 | LIMIT_PRICE=1000 |

#### order_percent(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

現在のポートフォリオに比した割合で注文を行ないます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|割合(<1)を指定します。|.3 (30%)|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 | |
|limit_price|number|order_typeが `OrderType.LIMIT_PRICE` のときの指値を指定します。 | LIMIT_PRICE=1000 |

#### order_target(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

この銘柄の総保有数を指定して注文を行ないます。
例えば、現在100株保有している状況で `amount=200` を指定すれば、100株の注文が実行されます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|この銘柄の総保有数を指定します。|300|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 | |
|limit_price|number|order_typeが `OrderType.LIMIT_PRICE` のときの指値を指定します。 | LIMIT_PRICE=1000 |

#### order_target_value(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

この銘柄の総額を指定して注文を行ないます。
例えば、現在この銘柄のポジションが 100,000円の状況で `amount=200,000` を指定すれば、100,000円以内で購入できる分の注文を行ないます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|この銘柄の総額を指定します。|300000|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 | |
|limit_price|number|order_typeが `OrderType.LIMIT_PRICE` のときの指値を指定します。 | LIMIT_PRICE=1000 |

#### order_target_percent(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

この銘柄の総保有額が総資産評価額(現金+保有ポジション評価額)に対して指定の割合となるように注文を行ないます。
amountには割合(例:5%なら0.05)を指定します。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|この銘柄の総保有額の目標割合を指定します。|0.05|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 | |
|limit_price|number|order_typeが `OrderType.LIMIT_PRICE` のときの指値を指定します。 | LIMIT_PRICE=1000 |

---

## pandas情報{#pandas}

### pandas.Panel(3次元)

[pandas.Panel](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Panel.html)

### pandas.DataFrame(2次元)

[pandas.DataFrame](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.html)

### pandas.Series(1次元)

[pandas.Series](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.html)

