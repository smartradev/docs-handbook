# APIリファレンス

## ctx{#ctx}

  initialize() や handle_signals() の引数として渡されるオブジェクト。
アルゴリズムの状態(Context)を保持します。

#### logger: [TinyLogging](#TinyLogging)

  後述する [TinyLogging](#TinyLogging) オブジェクト
  
#### portfolio: [Portfolio](#Portfolio)

  handle_signalsに渡された時にセットされます。組入銘柄の成績や保有状況を保持します。
  
#### localStorage: dict

  次回handle_signals()が呼び出された時に保存しておきたいデータを保存しておく領域です。
  ここに設定した値は、次回以降も設定されたままでhandle_signals()が呼び出されることが保証されます。
  格納するオブジェクトは、Serializableである必要があります。handle_signals()内のみで有効です。initialize()で設定された内容は、handle_signals()に引き継がれません。

#### configure(target, channels) : void

エンジンの初期設定を行うためのメソッドです。
必ず呼び出す必要があります。

|パラメータ名|型|意味|例|
|---|---|---|---|
|target|String|タイプ(市場+足)を指定する|jp.stock.daily|
|channels|dict|各市場をキーにして、取引対象銘柄名(symbols)や使用する指標値(columns)を指定する|　|

```python
    channels={          # 利用チャンネル
      "jp.stock.daily": {
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

initialize内でシグナル生成関数を登録するためのメソッド。
  
|パラメータ名|型|意味|例|
|---|---|---|---|
|name|String|名称(何でもよい)|"my_signal"|
|handler|function|シグナルハンドラ関数|　|

#### getSecurity(sym) : [Security](#Security)

指定された銘柄のSecurityオブジェクトを取得します。
存在しない、QuantXで非対応の銘柄の場合は、例外が発生します。

|パラメータ名|型|意味|例|
|---|---|---|---|
|sym|String|銘柄|"jp.stock.7201"|

---

## TinyLogging{#TinyLogging}

  Pythonのlogging APIと同じ仕様で、以下のメソッドがあります。

```python
    def debug()
    def info()
    def warning()
    def error()
    def critical()
```

  それぞれのログレベルで、コンソールにログメッセージが出力されます。

---

## Portfolio{#Portfolio}

  ポートフォリオを管理するオブジェクト

#### portfolio.positions : dict
   保有している各銘柄に関する情報を格納しているdictです。
   keyはsymbolで、銘柄毎に次のような値を持ちます

```python
     {
        "amount": asset.amount,                          # 保有株数
        "avg_entry_price": xxx,                          # 平均エントリ価格
        "position_ratio": position_ratio,                # 保有銘柄の中での割合,
        "portfolio_ratio": portfolio_ratio,              # 資産全体での割合
        "pnl": xxx,                                      # 損益額
        "returns": returns                               # 損益率
        "max_returns": max_returns                       # max returnを表します
        "holding_period": xxx                            # 銘柄保有営業日数を表します。注文が約定した日を1とし、保有数が0になるまで1ずつ増えます。
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
|amount|number|注文数。株式の場合は株数となります。負の場合は売却となります。|sec.unit() * 1|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 maron-0.0.5以上で利用可能です。 | |
|limit_price|number|order_type が指値系(`OrderType.LIMIT`, `OrderType.STOP_LIMIT`)のときの指値を指定します。| limit_price=1000 |
|limit_price_on_close| number|order_type が指値系のときに、引け指値の価格を指定します | limit_price_on_close=1200 |
|stop_limit_price_on_close| number|order_type が指値系のときに、引け逆指値の価格を指定します | stop_limit_price_on_close=1200 |

#### order_value(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

金額を指定して注文を行ないます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|金額。指定された金額内で注文を行ないます。負の場合は売却となります。|100000|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 maron-0.0.5以上で利用可能です。 | |
|limit_price|number|order_type が指値系(`OrderType.LIMIT`, `OrderType.STOP_LIMIT`)のときの指値を指定します。| limit_price=1000 |
|limit_price_on_close| number|order_type が指値系のときに、引け指値の価格を指定します | limit_price_on_close=1200 |
|stop_limit_price_on_close| number|order_type が指値系のときに、引け逆指値の価格を指定します | stop_limit_price_on_close=1200 |

#### order_percent(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

現在のポートフォリオに比した割合で注文を行ないます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|割合(<1)を指定します。負の場合は売却となります。|0.3 (30%)|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 maron-0.0.5以上で利用可能です。 | |
|limit_price|number|order_type が指値系(`OrderType.LIMIT`, `OrderType.STOP_LIMIT`)のときの指値を指定します。| limit_price=1000 |
|limit_price_on_close| number|order_type が指値系のときに、引け指値の価格を指定します | limit_price_on_close=1200 |
|stop_limit_price_on_close| number|order_type が指値系のときに、引け逆指値の価格を指定します | stop_limit_price_on_close=1200 |

#### order_target(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

この銘柄の総保有数を指定して注文を行ないます。
例えば、現在100株保有している状況で `amount=200` を指定すれば、100株の注文が実行されます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|この銘柄の総保有数を指定します。負の場合は売却となります。|300|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 maron-0.0.5以上で利用可能です。 | |
|limit_price|number|order_type が指値系(`OrderType.LIMIT`, `OrderType.STOP_LIMIT`)のときの指値を指定します。| limit_price=1000 |
|limit_price_on_close| number|order_type が指値系のときに、引け指値の価格を指定します | limit_price_on_close=1200 |
|stop_limit_price_on_close| number|order_type が指値系のときに、引け逆指値の価格を指定します | stop_limit_price_on_close=1200 |

#### order_target_value(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

この銘柄の総額を指定して注文を行ないます。
例えば、現在この銘柄のポジションが 100,000円の状況で `amount=200,000` を指定すれば、100,000円以内で購入できる分の注文を行ないます。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|この銘柄の総額を指定します。負の場合は売却となります。|300000|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 maron-0.0.5以上で利用可能です。 | |
|limit_price|number|order_type が指値系(`OrderType.LIMIT`, `OrderType.STOP_LIMIT`)のときの指値を指定します。| limit_price=1000 |
|limit_price_on_close| number|order_type が指値系のときに、引け指値の価格を指定します | limit_price_on_close=1200 |
|stop_limit_price_on_close| number|order_type が指値系のときに、引け逆指値の価格を指定します | stop_limit_price_on_close=1200 |

#### order_target_percent(amount, comment, order_type=OrderType.OPEN_PRICE, limit_price=None): void

この銘柄の総保有額が総資産評価額(現金+保有ポジション評価額)に対して指定の割合となるように注文を行ないます。
amountには割合(例:5%なら0.05)を指定します。

|パラメータ名|型|意味|例|
|---|---|---|---|
|amount|number|この銘柄の総保有額の目標割合を指定します。負の場合は売却となります。|0.05|
|comment|String|コメント。バックテスト結果に表示されます。|　|
|order_type|maron.OrderType|約定タイミングを指定します。省略時は、 `OrderType.OPEN_PRICE` が指定されたものとされます。 maron-0.0.5以上で利用可能です。 | |
|limit_price|number|order_type が指値系(`OrderType.LIMIT`, `OrderType.STOP_LIMIT`)のときの指値を指定します。| limit_price=1000 |
|limit_price_on_close| number|order_type が指値系のときに、引け指値の価格を指定します | limit_price_on_close=1200 |
|stop_limit_price_on_close| number|order_type が指値系のときに、引け逆指値の価格を指定します | stop_limit_price_on_close=1200 |

---

## pandas情報{#pandas}

### pandas.DataFrame(2次元)

[pandas.DataFrame](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.html)

### pandas.Series(1次元)

[pandas.Series](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.html)

