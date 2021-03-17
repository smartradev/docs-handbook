# 策略实例详解，助您快速上手

本说明以双均线样本策略为例，介绍在QuantX量化平台上制作、测试量化策略的方法。

## 整体构造  {#overview}

每一个策略都由两大主要模块构成，初始化定义（initialize）以及交易操作执行（handle_signals），分别为图中所示的蓝色与橙色部分。回测引擎会依次调用两大模块完成回测。

<img src="img/fig1.png" style="margin: 10px; float: right; width: 500px;">

蓝色模块：初始化定义，在回测初始阶段被调用。该模块中，用户应定义：
（1）该策略所适用的股票池（通过股票的代码）

（2）所使用的股票信息（价格，交易量等）

（3）买入卖出的交易条件（在图中的绿色部分标出）

橙色模块：交易操作执行。在该模块中，用户应指定具体的交易操作：当初始化定义中所指定的股票池满足交易信号指定的条件时，将执行的具体买入或卖出操作。往往包括买入卖出数量、止损止盈标准等。

回测时，引擎会根据定义的股票池以及买卖条件确定买卖发生的日期，进而在相应的时间执行策略指定的交易操作，从而计算出策略的收益情况。

<br style="clear: right">

## 代码详解{#code-top}

### 初始化部分{#initialize}

```python
def initialize(ctx):
```
为初始化函数。其中，请参照[ctx](https://pypi.python.org/pypi/ctx)了解更多信息。

```python
    ctx.configure()
```
在configure函数内，用户可定义策略所适用的股票池信息。

```python
        target="jp.stock.daily",
```
target用来指定策略所适用的股票市场（中国-cn或者日本-jp）以及交易频率（daily指代日数据）。如果.daily缺省，则默认为日交易数据。

后面的交易操作执行模块，handle_signals()，将按照此处指定的市场与频率执行相应的交易操作。

```python
      channels={
        "jp.stock": {
```
在channels中定义策略适用的股票市场。如果与target中定义的股票市场不一致，回测程序将以此处的定义为准。

```python
          "symbols": [
            "jp.stock.7201",
            "jp.stock.9201",
            "jp.stock.9202",
            "jp.stock.7203"
          ],
```
在symbols中指定具体的股票代码，作为回测的股票池。

```python
          "columns": [
            "close_price_adj",    # 收盘价(调整股票拆细后)
            "volume_adj",         # 成交量
            "txn_volume",         # 成交金额
          ]
```

在columns中指定所使用的股票参数。
现阶段能使用的数据种类情参照[数据包](dataset.jp.stock.md)。


### 定义交易信号{#signal-emitter}

```python
    def _mavg_signal(data):
```

在此_mavg_signal()函数中定义买入、卖出信号。

输入变量data的数据类型为三维数组，由[pandas.Panel](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Panel.html)定义，根据前面channels定义的股票池信息所自动生成，其各维数据信息如下：

  * axis-0(items): 数据部分(close_price, volume, etc.)　　　
  * axis-1(major): 日期(datetime.datetime型)　
  * axis-2(minor): 股票名(symbol object型)　　

在该例中，data数据储存情况如下：


2017/05/09

|| close_price_adj | volume_adj | txn_volume |
|:-----------:|:------------:|:------------:|:------------:|
|jp.stock.7201|值|值|值|
|jp.stock.9201|值|值|值|
|jp.stock.9202|值|值|值|
|jp.stock.7203|值|值|值|

2017/05/10

|| close_price_adj | volume_adj | txn_volume |
|:-----------:|:------------:|:------------:|:------------:|
|jp.stock.7201|值|值|值|
|jp.stock.9201|值|值|值|
|jp.stock.9202|值|值|值|
|jp.stock.7203|值|值|值|



　　　　　　　　　　　　　　　　　　：
　　　　　　　　　　　　　　　　　　：
　　　　　　　　　　　　　　　　　　：



```python
        m25 = data["close_price_adj"].fillna(method='ffill').rolling(window=25, center=False).mean()
```
该式计算股票池中所有股票“close_price_adj”的25日移动平均值并保存在变量m25中。

首先

```python
data["close_price_adj"]
```

读取三维数组data中的“close_price_adj”，生成了一个二维数组[pandas.DataFrame](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.html)。
储存形式如下：

|| jp.stock.7201 | jp.stock.9201 | jp.stock.9202 | jp.stock.7203|…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|2017/5/1|收盘价|收盘价|收盘价|收盘价|…|
|2017/5/2|收盘价|收盘价|收盘价|收盘价|…|
|2017/5/3|收盘价|收盘价|收盘价|收盘价|…|


```python
fillna(method='ffill')
```
因为各种原因，历史数据会存在缺失，这些缺失的数据点数组中以NaN的形式储存。使用fillna函数，可以将所有NaN数据以method定义的方式进行补全。

```python
rolling(window=25, center=False).mean()
```
该代码使用了pandas.DataFrame的函数计算数据的25日移动平均线。

关于rolling请参照
[pandas.DataFrame.rolling ](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.rolling.html)

关于mean请参照
[pandas.DataFrame.mean](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.mean.html#pandas.DataFrame.mean)


最终生成的变量m25是一个二维pandas.DataFrame数组，其部分示例如下：

|| jp.stock.7201 | jp.stock.9201 | jp.stock.9202 | jp.stock.7203|…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|2017/5/1|25天移动平均值|25天移动平均值|25天移动平均值|25天移动平均值|…|
|2017/5/2|25天移动平均值|25天移动平均值|25天移动平均值|25天移动平均值|…|
|2017/5/3|25天移动平均值|25天移动平均值|25天移动平均值|25天移动平均值|…|

```python
        m75 = data["close_price_adj"].fillna(method='ffill').rolling(window=75, center=False).mean()
```

与m25的计算方式相同，该式计算75日移动平均值。

```python
        ratio = m25 / m75
```
计算m25与m75的元素商，既在相同时间点上的数据进行做商，生成二维pandas.DataFrame数组ratio。

```python
        buy_sig = ratio[ratio > 1.05]
```
将ratio中满足条件“>1.05”的元素保存，并将不满足条件的元素值设为NaN，结果存在二维数组buy_sig中，部分示例如下：

|| jp.stock.7201 | jp.stock.9201 | jp.stock.9202 | jp.stock.7203|…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|2017/5/1|值|NaN|值|值|…|
|2017/5/2|NaN|NaN|NNaN|NaN|…|
|2017/5/3|值|值|值|值|…|


```python
        sell_sig = ratio[ratio < 0.95]
```

将ratio中满足条件小于0.95的元素保存，并将不满足条件的元素值设为NaN，结果存在二维数组sell_sig中，


```python
        return {
            "mavg_25:price": m25,
            "mavg_75:price": m75,
            "buy:sig": buy_sig,
            "sell:sig": sell_sig,
        }
```

函数所返回的变量：m25，m75,buy_sig,sell_sig，将在后面的交易操作执行模块中使用。

同时定义了各变量在回测结果显示中的名称，分别为：mavg_25:price，mavg_75:price，buy:sig，sell:sig。

注：在回测结果显示图表中，buy:sig命名的数据区域将自动显示为粉红色，sell：sig命名的数据区域将自动显示为浅蓝色。

```python
    ctx.regist_signal("mavg_signal", _mavg_signal)
```

最后，将新定义的「_mavg_signal」函数在回测引擎中注册供后续使用。

阅读更多关于[pandas](http://pandas.pydata.org/pandas-docs/stable/index.html)。

## 交易操作执行{#handle-signals}

用户在该模块中应定义具体的买卖操作，比如买卖数量，止损止盈条件等。

handle_signals函数将按照初始化定义中指定的交易频率被调用。比如，如果target中定义为daily，则handle_signals将逐日被调用并按照用户定义的操作进行买卖交易。

```python
def handle_signals(ctx, date, current):
```

date是handle_signals当前处理的时间点，类型为datetime.datetime。

current储存了时间点date时的股票池数据以及交易信号函数中计算的结果，类型为二维pandas.DataFrame数组。比如，current["close_price"] 返回的是在configure()中指定股票池中各股票的close_price，类型为一维pandas.sSeries数组。

current的部分示例如下：

|| close_price | open_price | sig1 |sig2|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|值|值|值|值|
|jp.stock.9201|值|值|值|值|
|jp.stock.9202|值|值|值|值|
|jp.stock.7203|值|值|值|值|

注：sig1，sig2是在前面regist_signal中注册过的买卖信号。

ctx与initialize()中的ctx是不同的object，其具备以下函数：

<dl>
  <dt>ctx.getSecurity(sym)</dt>
  <dd>返回对应于股票代码sym的Security object</dd>

  <dt>ctx.portfolio</dt>
  <dd>储存资产配置信息的Portfolio object</dd>

  <dt>ctx.localStorage</dt>
  <dd>用户可以用该函数储存希望回测系统保存的变量。凡是通过此函数储存的变量，在接下来的所有handle_signals的运算中，都可被反复调用。</dd>
</dl>


```python
    done_syms = set([])
```
定义一个集合变量，用于保存当天有买卖交易的股票信息。

```python
    for (sym,val) in ctx.portfolio.positions.items():
```
遍历当前时间点portfolio中的所有股票sym及其相应的数据信息val。

```python
        returns = val["returns"]
```
获得股票的当前收益率。

```python
        if returns < -0.03:
```
对于亏算高于3%的股票，执行以下操作：

```python
          sec = ctx.getSecurity(sym)
```
返回该股票的信息，储存在一个security object中。

Security object储存以下两个信息：

*    code()    : 股票代码(ex. 9984)
*    unit()    : 基本买卖单位(ex. 100)

```python
          sec.order(-val["amount"], comment="止损卖出(%f)" % returns)
          done_syms.add(sym)
```

卖出所有该股票。止损操作。并把该股票代码存入done_syms集合中。


```python
        elif returns > 0.05:
          sec = ctx.getSecurity(sym)
          sec.order(-val["amount"], comment="为确定盈利卖出(%f)" % returns)
          done_syms.add(sym)
```
对于收益率高于5%的股票，全部卖出，锁定收益，并把该股票代码存入done_syms中。

```python
    buy = current["buy:sig"].dropna()
```
获取当前时间点的有效买入信号。

```python
    for (sym,val) in buy.items():
        if sym in done_syms:
          continue
```
跳过在止损或者锁定收益操作中已经处理过的股票。

```python
        sec = ctx.getSecurity(sym)
        sec.order(sec.unit() * 1, comment="SIGNAL BUY")
        pass
```
购买一个单位的该股票。

```python
    sell = current["sell:sig"].dropna()
    for (sym,val) in sell.items():
        if sym in done_syms:
          continue

        sec = ctx.getSecurity(sym)
        sec.order(sec.unit() * -1, comment="SIGNAL SELL")
        #ctx.logger.debug("SELL: %s,  %f" % (sec.code(), val))
        passs
```
与买入下单相似，进行卖出操作。

对于样本策略的说明到此为止，点此学习更多[样本策略]，或者[开始制作]自己的策略吧。
