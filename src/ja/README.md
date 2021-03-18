# サンプルコードを利用したチュートリアル for 0.1.0

## 全体の構成 {#overview}

QuantXのPython Coding におけるサンプルプログラムを例にしてアルゴリズム開発方法を説明します。
サンプルプログラムは、大きく分けると図のように青の部分とオレンジ色の2つの部分で関数されているのが分かります。

<img src="img/fig1.jpeg" style="margin: 5px; float: right; width: 500px;">

双方の関数とも、バックテストエンジンから必要なときに呼び出されます。

青の部分は最初に1度だけ呼び出される初期化部分です。

オレンジ色は取引の具体的なアクションについて記述された部分です。

そして、青の中に緑の部分があります。ここがsellかbuyのシグナルを生成する箇所になります。

ですので、一般にアルゴリズムを開発してバックテストを走らせる際は次のような動作をする事になります。

1. 青の部分が解釈され始めます。銘柄や使うデータ要素が指定されます。

1. 緑の部分が解釈されます。ここでは全指定銘柄の全て過去のデータが入った配列全体に対して演算を行い、一定条件に入ったものに対してSellやbuyの値を入れていきます。（シグナルはすべてここで決まります）

1. オレンジ色の部分が指定された日付の古い順に全ての日数分呼び出され解釈されます。
指定日時のポジションを見ながら評価を行い、損切りや利益確定を行ったり、緑の所で指定されたシグナルに合わせて株の売り買いを行います。

<br style="clear: right">

## コード内容の解説{#code-top}

[移動平均を利用したサンプル for 0.1.0](https://factory.quantx.io/developer/de44abb41b094486af8a8408e3853388/coding)を元に解説します。

### 初期化部分{#initialize}

initialize(ctx)は、エンジンの初期化時に必要な回数呼ばれます。
initializeの中では、各種設定を行う必要があります。

#### 処理の流れ

```python
def initialize(ctx):
    ctx.configure(
      # 処理対象として、日本株の日足を指定します(現在はjp.stock.daily固定です)
      target="jp.stock.daily",

      # 利用するデータを指定します
      channels={

        # 日本株の日足データの利用を指定します
        "jp.stock.daily": {

          # 組入銘柄定義
          "symbols": [
            "jp.stock.7201",
            "jp.stock.9201",
            "jp.stock.9201",
            "jp.stock.7203"
          ],

          # 各銘柄において、利用する価格データを指定します
          "columns": [
            "close_price",        # 終値
            "close_price_adj",    # 終値(株式分割調整後) 
            #"open_price_adj",    # 始値(株式分割調整後)
            #"high_price_adj",    # 高値(株式分割調整後)
            #"low_price_adj",     # 安値(株式分割調整後)
            #"volume_adj",         # 出来高
            #"txn_volume",         # 売買代金
          ]
        }
      }
    )

    def _my_signal(datas):
      # 後述します
      ...

    # 定義したシグナル生成関数をエンジンに登録します
    ctx.regist_signal("my_signal", _my_signal)
```

現在使えるデータの種類は [データセット](dataset.jp.stock.md)を参照ください。

### 売買シグナル生成部分{#signal-emitter}

initialize()内でregist_signal()したシグナル生成関数について説明します。

シグナル生成関数は、売買シグナルを生成する関数の定義です。
ここで定義した関数を `ctx.regist_signal` で `ctx` に登録することでエンジンから呼び出されます。

#### シグナル生成関数のパラメータ

1つのdict型の変数が渡されてきます。内容は、initialize()のchannelsで指定された次のようなデータが含まれます。

| key | value |
|:-----------:|:------------:|
| jp.stock.daily | (date, symbol) を indexとしたDataFrame |

#### シグナル生成関数の戻り値

シグナル生成関数は、次のようなdictを返す必要があります。
```
  key: シグナル名
  value: DataFrame(index=date, columns=symbol)
```
返されるdictは、値のDataFrameの構造が仕様に沿っていれば、どのような値でも返すことができますが、
必ず `market:sig` という市況シグナルが含まれている必要があります。
`market:sig` は、-1.0〜1.0の値である必要があります。負は売り、正は買いを表し、その大きさは確信度とします。

#### 処理の流れ

まずは、datasから、jp.stock.dailyのDataFrameを取得します。

```python
    daily = datas["jp.stock.daily"]
```

dailyは次のような構造になっています。

  <table>
    <tr>
      <th colspan="2">index</th>
      <th colspan="3">columns</th>
    </tr>
    <tr>
      <th>date</th>
      <th>symbol</th>
      <th>close_price</th>
      <th>close_price_adj</th>
      <th>volume</th>
    </tr>
    <tr>
      <td>2021-01-04</td>
      <td>jp.stock.7201</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-04</td>
      <td>jp.stock.9201</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-04</td>
      <td>jp.stock.9202</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-04</td>
      <td>jp.stock.7203</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-05</td>
      <td>jp.stock.7201</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-05</td>
      <td>jp.stock.9201</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-05</td>
      <td>jp.stock.9202</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-05</td>
      <td>jp.stock.7203</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>2021-01-06</td>
      <td>jp.stock.7201</td>
      <td>終値</td>
      <td>終値(株価調整済)</td>
      <td>取引高</td>
    </tr>
    <tr>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
</table>


サンプルでは、「close_price_adj（株式分割調整後終値）」の25日移動平均を計算しています。
まず、DataFrameから、close_price_adjのデータのみを取り出し、シンプルなsignle-indexのDataFrameを作ります。<br>

```python

  cp = daily["close_price_adj"].unstack(level="symbol")
```

cpには、次のようなDataFrameが格納されます。

  <table>
    <tr>
      <th>index</th>
      <th colspan="4">columns</th>
    </tr>
    <tr>
      <th>date</th>
      <th>jp.stock.7201</th>
      <th>jp.stock.9201</th>
      <th>jp.stock.9202</th>
      <th>jp.stock.7203</th>
    </tr>
    <tr>
      <td>2021-01-04</td>
      <td>終値(株価調整済)</td>
      <td>終値(株価調整済)</td>
      <td>終値(株価調整済)</td>
      <td>終値(株価調整済)</td>
    </tr>
    <tr>
      <td>2021-01-05</td>
      <td>終値(株価調整済)</td>
      <td>終値(株価調整済)</td>
      <td>終値(株価調整済)</td>
      <td>終値(株価調整済)</td>
    </tr>
    <tr>
      <td>2021-01-06</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
</table>


```python
  cp = cp.fillna(method='ffill')
```

次に、欠損データの補完を行います。
データにはたまに欠損があります。これは例えばストップ安で値がつかなかったりするなど、様々な要因で終値がNaNとなることがあります。
NaNが計算式に含まれると、式の結果は自動的にNaNとなってしまうため、移動平均の計算に支障が発生する可能性があります。

そこで、`fillna()` を使い、NaNの箇所を補完します。さまざまな方法で補完が可能ですが、今回は `ffill`を使います。

```python
  m25 = cp.rolling(window=25, center=False).mean()
```

最後に移動平均を計算します。ここでは25個の値を連続して取得し、さらにその平均を取るというpandas.DataFrameのメソッドを呼び出しています。

rolling()についてはこちらを
[pandas.DataFrame.rolling ](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.rolling.html)

mean()についてはこちらを参照ください。
[pandas.DataFrame.mean](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.mean.html#pandas.DataFrame.mean)

最終的にm25という2次元配列に次のように終値の25日移動平均値が各銘柄、各日付において格納される結果となります。

|| jp.stock.7201 | jp.stock.9201 | jp.stock.9202 | jp.stock.7203|…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|:------------:|
|2021/1/4|25日移動平均値|25日移動平均値|25日移動平均値|25日移動平均値|…|
|2021/1/5|25日移動平均値|25日移動平均値|25日移動平均値|25日移動平均値|…|
|2021/1/6|25日移動平均値|25日移動平均値|25日移動平均値|25日移動平均値|…|

```python
　   m75 = cp.rolling(window=75, center=False).mean()
```

同様に終値の75日移動平均値の配列をm75に格納します。

```python
　   ratio = m25 / m75
```

2次元配列であるm25を、同様のサイズの2次元配列であるm75で割ります。
結果は25日移動平均値を75日移動平均値で割った値の2次元配列がratioに格納されます。

```python
　   buy_sig = ratio > 1.05
```

ここではまず、ratio > 1.05　が評価されます。つまり25日移動平均値を75日移動平均値で割った値が1.05を超えていた場合True、そうでない場合Falseとなる真偽値の2次元配列が出来上がります。

|            | jp.stock.7201 | jp.stock.9201 | jp.stock.9202 | jp.stock.7203 |
|------------|---------------|---------------|---------------|---------------|
| 2021-01-04 | False         | False         | True          | True          |
| 2021-01-05 | False         | False         | True          | True          |
| 2021-01-06 | False         | False         | True          | True          |

```python
　   sell_sig = ratio < 0.95
```

同様に25日移動平均値を75日移動平均値で割った値が0.95より小さい場合True、そうでない場合Falseの
真偽値をsell_sig配列に格納します。

```python
　   market_sig = pd.DataFrame(data=0.0, columns=cp.columns, index=cp.index)
```

cpのDataFrameと同じindexおよびcolumnsのDataFrameを作成します。最初は全て0.0(中立)の値を格納しています。

|            | jp.stock.7201 | jp.stock.9201 | jp.stock.9202 | jp.stock.7203 |
|------------|---------------|---------------|---------------|---------------|
| 2021-01-04 | 0.0             | 0.0             | 0.0             | 0.0             |
| 2021-01-05 | 0.0             | 0.0             | 0.0             | 0.0             |
| 2021-01-06 | 0.0             | 0.0             | 0.0             | 0.0             |

```python
　   market_sig[buy_sig == True] += 1.0
```

先程、定義したbuy_sigがTrueの時、market_sigの0.0の値に1.0を加えます。

|            | jp.stock.7201 | jp.stock.9201 | jp.stock.9202 | jp.stock.7203 |
|------------|---------------|---------------|---------------|---------------|
| 2021-01-04 | 0.0           | 0.0           | 1.0           | 1.0           |
| 2021-01-05 | 0.0           | 0.0           | 1.0           | 1.0           |
| 2021-01-06 | 0.0           | 0.0           | 1.0           | 1.0           |

```python
　   market_sig[sell_sig == True] += -1.0
```

同様に、定義したsell_sigがTrueの時、market_sigの値に-1.0を加えます。

お気づきかもしれませんが、もし `buy_sig == sell_sig == True` である場合は、`0 + 1.0 - 1.0` となり、0となります。このコードは、`買いでも売りでもある == よくわからない == 中立とする` という意味になります。

```python
　   return {
　     "mavg_25:price": m25,
　     "mavg_75:price": m75,
　     "ratio:g2":ratio,
　     "market:sig": market_sig,
　   }
```

計算した値をdictにして返します。



#### 呼び出されるタイミング

開発中のバックテスト時には、設定されているバックテスト期間に関わらず、すべての期間のデータを引数として1度だけ呼び出されます。

Live時には、当日までのデータを引数として呼び出されます。
`market:sig` は、最新の値のみがhandle_signals()に渡されます。


### 日ごとの処理部分の記述{#handle-signals}

続いて、日ごとに呼び出される関数の説明です。これは例えば100日分のデータのバックテストをやる場合、100回呼び出される事になります。
ここで株をどの位売買するかの決定や損切り、利益確定売りを指定します。
この関数はエンジンから直接呼び出されます。

```python
def handle_signals(ctx, date, current):
```

dateはdatetime.datetime型 currentは、dateの当日のデータとシグナルを含んだ pandas.DataFrame オブジェクトで、以下のような構造になります。

|| close_price_adj | close_price | market:sig | sig1 |sig2(regist_signalで登録したシグナル)|
|:-----------:|:------------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|値|値|値|値|値|
|jp.stock.9201|値|値|値|値|値|
|jp.stock.9202|値|値|値|値|値|
|jp.stock.7203|値|値|値|値|値|

たとえば、current["close_price"] とすると、configure()で指定した銘柄のclose_priceのpandas.Seriesオブジェクトを返します。

ctxは以下のメソッドやプロパティを持つオブジェクトで,initialize()で渡されるctxとは別のオブジェクトとなります。

<dl>
  <dt>ctx.getSecurity(sym)</dt>
  <dd>symに相当する<a href="api.html#Security">Security</a>オブジェクト（銘柄情報)を返す</dd>

  <dt>ctx.portfolio</dt>
  <dd>ポートフォリオを管理する<a href="api.html#Portfolio">Portfolio</a>オブジェクト</dd>

  <dt>ctx.localStorage</dt>
  <dd>次回handle_signals()が呼び出された時に保存しておきたいデータを保存しておく領域。
ここに設定した値は、次回以降も設定されたままでhandle_signals()が呼び出されることが保証されます。格納するオブジェクトは、Serializableである必要があります。</dd>
</dl>

以下、順番に説明していきます。

```python

def handle_signals(ctx, date, current):

  # 処理済み銘柄のシンボル値を格納する変数です
  done_syms = set([])

  # まずは、組入銘柄のポジションについて確認していきます
  for sym, v in ctx.portfolio.positions.items():

    # 当該銘柄の保有日数を取得します。保有していない場合には0となります。
    holding_period = v["holding_period"]

    # 当該銘柄の現在の損益率を取得します。保有していない場合には0となります。
    returns = v["returns"]

    # 保有期間が30営業日を超えた銘柄はポジションを解消する
    if holding_period >= 30:
      sec = ctx.getSecurity(sym)

      # 翌営業日の始値で、すべてのポジションの解消を指示します
      sec.order(-v["amount"],  order_type=maron.OrderType.MARKET_OPEN, comment="holding period(%d)" % holding_period)
      done_syms.add(sym)

    # 損切り(-2%より小さい場合)
    elif returns < -0.02:
      sec = ctx.getSecurity(sym)
      sec.order(-v["amount"],  order_type=maron.OrderType.MARKET_OPEN, comment="losscut(%f)" % v["returns"])
      done_syms.add(sym)
      continue

    # 利確(4%より大きい場合)
    elif returns > 0.04:
      sec = ctx.getSecurity(sym)
      sec.order(-v["amount"],  order_type=maron.OrderType.MARKET_OPEN, comment="profit taking(%f)" % v["returns"])
      done_syms.add(sym)

  # 次に、各銘柄の market:sig の値を確認していきます
  for sym, market_sig in current["market:sig"].iteritems():

    # すでにポジション関連の注文を行っている場合には無視します。
    if sym in done_syms:
      continue

    market:sigに基づいた注文を行います
    if market_sig > 0:
      # market:sigが正の値のときは、購入指示を行います
      # キャッシュポジションの1/8で購入できる数量だけ購入する
      sec = ctx.getSecurity(sym)
      sec.order_value(ctx.portfolio.cash / 2, order_type=maron.OrderType.MARKET_OPEN, comment="BUY(%f)" % market_sig)
    elif market_sig < 0:
      # market:sigが負の値のときは、売却指示を行います
      sec = ctx.getSecurity(sym)
      sec.order_value(-ctx.portfolio.cash / 2, order_type=maron.OrderType.MARKET_OPEN, comment="SELL(%f)" % market_sig)
```
      


以上、サンプルプログラムの解説でした。
