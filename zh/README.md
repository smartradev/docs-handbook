# 通过策略程序样本的整体说明

## 整体构造 {#overview}

以python coding上的程序样本为例，介绍具体制作策略组合的方法。


SmartTradeのpython coding におけるサンプルプログラムを例にしてアルゴリズム開発のやり方を説明します。
まず、サンプルプログラムを見ると図のように青の部分とオレンジ色の部分で構成されているのが分かります。

<img src="img/fig1.png" style="float: right; width: 500px;">

青の部分は最初に一度だけ呼び出される定義部分です。オレンジ色は取引の具体的なアクションについて記述された部分です。
そして、青の中に緑の部分があります。ここがsellかbuyのシグナルを評価する箇所になります。
ですので、一般にアルゴリズムを開発してバックテストを走らせる際は次のような動作をする事になります。

1. 青の部分が解釈され始めます。銘柄や使うデータ要素が指定されます。
1. 緑の部分が解釈されます。ここでは全指定銘柄の全て過去のデータが入った配列全体に対して演算を行い、一定条件に入ったものに対してSellやbuyの値を入れていきます。（シグナルはすべてここで決まります）
1. オレンジ色の部分が指定された日付の古い順に全ての日数分呼び出され解釈されます。指定日時のポジションを見ながら評価を行い、損切りや利益確定を行ったり、緑の所で指定されたシグナルに合わせて株の売り買いを行います。

<br style="clear: right">

## コード内容の解説{#code-top}

### 初期化部分{#initialize}

```python
def initialize(ctx):
```

初期化を行う関数。ctxのメソッドは、initialize()の中でのみ呼び出しが可能。

```python
    ctx.configure(
```

この段落でコンテストの初期値を設定します。

```python
        "cn.stock": {
```

日本株を対象にする指定です。"cn.stock"とすれば上海市場の中国株にも対応します。


```python
          "symbols": [
            "jp.stock.7201",
            "jp.stock.9201",
            "jp.stock.9202",
            "jp.stock.7203"
          ],
```

対象とする証券コードを指定します。
jp.stock.7201は日産自動車株式会社を意味します。


```python
          "columns": [
            "close_price_adj",    # 終値(株式分割調整後)
            "volume_adj",         # 出来高
            "txn_volume",         # 売買代金
          ]
```

シグナルを計算するために必要なデータ種を指定します。

現在使えるデータ種は下記の通りです。

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



### 売買シグナル生成部分{#signal-emitter}


```python
    def _mavg_signal(data):
```
売買シグナルを生成する関数です。

ここでは全銘柄、指定期間の全日付、全データの入った3次元の配列である「data」そのものを配列のまま演算しています。

dataは、pandas.Panelオブジェクトで、

*      axis-0(items): データ項目(close_price, volume, etc.)　　
*      axis-1(major): 日付(datetime.datetime型)　
*      axis-2(minor): 銘柄名(symbol object型)　　

と、定義されています。


この例で行くとdataには、

2017/5/9の

|| close_price_adj | volume_adj | txn_volume |
|:-----------:|:------------:|:------------:|:------------:|
|jp.stock.7201|値|値|値|
|jp.stock.9201|値|値|値|
|jp.stock.9202|値|値|値|
|jp.stock.7203|値|値|値|

2017/5/10の

|| close_price_adj | volume_adj | txn_volume |
|:-----------:|:------------:|:------------:|:------------:|
|jp.stock.7201|値|値|値|
|jp.stock.9201|値|値|値|
|jp.stock.9202|値|値|値|
|jp.stock.7203|値|値|値|


　　　　　　　　　　　　　　　　　　：
　　　　　　　　　　　　　　　　　　：

　　　　　　　　　　　以下適用範囲内の日付全て

という形で3次元に格納されています。


```python
        m25 = data["close_price_adj"].fillna(method='pad').rolling(window=25, center=False).mean()
```

ここではデータのうち「close_price_adj（終値）」を対象として指定しています。
ですので、全銘柄、指定期間の全日付の入った終値の2次元の配列そのものを配列のまま演算することになります。


|| 2017/5/1 | 2017/5/2 | 2017/5/3 |…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|終値|終値|終値|…|
|jp.stock.9201|終値|終値|終値|…|
|jp.stock.9202|終値|終値|終値|…|
|jp.stock.7203|終値|終値|終値|…|


```python
fillna(method='pad')
```

データにはたまに欠損があります。これは例えばストップ安で値がつかなかったりするなどの要因で終値がNaNになります。
そうするとデータを期待していたコードに不具合が出てしまいます。
そこで、このメソッドを使うとNaNがあった場合自動的に補完をしてくれるようになります。
また、β版ではデータの完璧さは保証されておりませんのでその点ご了承ください。


```python
rolling(window=25, center=False).mean()
```

ここでは25個の値を連続して取得し、さらにその平均を取るという指定をしています。

rollingについてはこちらを
[pandas.DataFrame.rolling ](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.rolling.html)

meanについてはこちらを
[pandas.DataFrame.mean](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.mean.html#pandas.DataFrame.mean)

参照してください。

最終的にm25という2次元配列に次のように終値の25日移動平均値が各銘柄、各日付において格納される結果となります。

|| 2017/5/1 | 2017/5/2 | 2017/5/3 |…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|25日移動平均値|25日移動平均値|25日移動平均値|…|
|jp.stock.9201|25日移動平均値|25日移動平均値|25日移動平均値|…|
|jp.stock.9202|25日移動平均値|25日移動平均値|25日移動平均値|…|
|jp.stock.7203|25日移動平均値|25日移動平均値|25日移動平均値|…|


```python
        m75 = data["close_price_adj"].fillna(method='pad').rolling(window=75, center=False).mean()
```

同様に終値の75日移動平均値の配列をm75に格納します。

```python
        ratio = m25 / m75
```
2次元配列であるm25を2次元配列であるm75で割ります。
結果は25日移動平均値を75日移動平均値で割った値の2次元配列がratioに格納されます。


```python
        buy_sig = ratio[ratio > 1.05]
```
ここではまず、ratio > 1.05　が評価されます。つまり25日移動平均値を75日移動平均値で割った値が1.05を超えていた場合、TRUE、そうでない場合FALSEの
論理値の2次元配列が出来上がります。
次にratio[論理値2次元配列]がbuy_sigという2次元配列に格納されるので、結果的に25日移動平均値を75日移動平均値で割った値が1.05を超えていた
要素だけがbuy_sigに入り、それ以外はNaNになります。

```python
        sell_sig = ratio[ratio < 0.95]
```
同様に25日移動平均値を75日移動平均値で割った値が0.95より小さい場合、sell_sig配列に値を格納します。



```python
        return {
            "mavg_25:price": m25,
            "mavg_75:price": m75,
            "buy:sig": buy_sig,
            "sell:sig": sell_sig,
        }
```

後ほど利用する配列を定義して残します。
また、チャートで表示する際の項目名も定義します。
例えば「buy_sig」という配列を"buy:sig"という名前でチャートの下に表示させます。

なお、suffixとして、sigが使用された場合には、特別扱いされ、
チャート上で矩形がfillされて範囲の確認が可能になります。 このとき、

* keyにbuy,pos が含まれる場合には、ピンク
* keyにsell,neg が含まれる場合には、水色

の色が固定的に利用されます。



```python
    ctx.regist_signal("mavg_signal", _mavg_signal)
```
今まで解説してきた関数「_mavg_signal」を登録して使うことを明示します。


## 日ごとの処理部分の記述{#handle-signals}

続いて、日ごとに呼び出される関数の説明です。これは例えば100日分のデータのバックテストをやる場合、100回呼び出される事になります。
ここで株をどの位売買するかの決定や損きり、利益確定売りを指定します。


```python
def handle_signals(ctx, date, current):
```


dateはdatetime.datetime型 currentは、dateの当日のデータ、シグナルを含んだ pandas.DataFrameオブジェクト。
例えば以下のような構造を持つ。

|| close_price | open_price | sig1 |sig2(regist_signalで登録したシグナル)|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|値|値|値|値|
|jp.stock.9201|値|値|値|値|
|jp.stock.9202|値|値|値|値|
|jp.stock.7203|値|値|値|値|


たとえば、current["close_price"] とすると、configure()で指定した銘柄のclose_priceのpandas.Seriesオブジェクトを返す。

ctxは以下のメソッドを持つ(initialize()で渡されるctxとは別のオブジェクトであることに注意)

<dl>
  <dt>ctx.getSecurity(sym)</dt>
  <dd>symに相当するSecurityオブジェクトを返す</dd>

  <dt>ctx.portfolio</dt>
  <dd>ポートフォリオを管理するPortfolioオブジェクト</dd>

  <dt>ctx.localStorage</dt>
  <dd>次回handle_signals()が呼び出された時に保存しておきたいデータを保存しておく領域。
ここに設定した値は、次回移行も設定されたままでhandle_signals()が呼び出されることが保証される。</dd>
</dl>


```python
    done_syms = set([])
```
当該の日にシグナルによる売買と「損切り、利益確定売り」が被らないようにフラグを用意します。

```python
    for (sym,val) in ctx.portfolio.positions.items():
```
当該の日にポジションを持っている銘柄があった場合、そこの部分の処理をします。

```python
        returns = val["returns"]
```
ポジションの時価との差異を取ります。

```python
        if returns < -0.03:
```
時価が取得時より3%下落下かどうかを評価します。

```python
          sec = ctx.getSecurity(sym)
```
当該銘柄のSecurityオブジェクトを取得。

なお、Securityオブジェクトには次のメソッドが有ります。

*    code()    : code値を返す(ex. 9984)
*    unit()    : 売買単位を返す(ex. 100)

注文系関数

*      order()
*      order_value()
*      order_target_value()
*      order_target()
*      order_target_percent()
*      order_percent()

style引数には対応していません。


```python
          sec.order(-val["amount"], comment="損切り(%f)" % returns)
          done_syms.add(sym)
```
売却処理を行い、当該の日ではシグナルでの売買をしないようフラグを立てます。



```python
        elif returns > 0.05:
          sec = ctx.getSecurity(sym)
          sec.order(-val["amount"], comment="利益確定売(%f)" % returns)
          done_syms.add(sym)
```
同様に5%以上値上がりしていたら利益確定売りをしてフラグを立てます。

```python
    buy = current["buy:sig"].dropna()
```
buyシグナルの項目のpandas.Seriesオブジェクトを取得します。

```python
    for (sym,val) in buy.items():
        if sym in done_syms:
          continue
```
buyシグナルが設定された所を実行します。ただし、損切りか利益確定売りをしたフラグが立っていたら無視します。

```python
        sec = ctx.getSecurity(sym)
        sec.order(sec.unit() * 1, comment="SIGNAL BUY")
        pass
```
当該の銘柄の発注を行います。

```python
    sell = current["sell:sig"].dropna()
    for (sym,val) in sell.items():
        if sym in done_syms:
          continue

        sec = ctx.getSecurity(sym)
        sec.order(sec.unit() * -1, comment="SIGNAL SELL")
        #ctx.logger.debug("SELL: %s,  %f" % (sec.code(), val))
        pass
```
同様に売り注文も実行します。

以上、サンプルプログラムの解説でした。
