# 通过策略程序样本的整体说明

## 整体构造 {#overview}

以python coding的程序样本为例，介绍具体制作策略组合的方法。
如图所示程序样本由蓝色和橙色部分构成。

<img src="img/fig1.png" style="float: right; width: 500px;">

蓝色部分是只在最开始阶段被调用一次的定义部分。橙色部分是叙述交易的具体操作的部分。
蓝色范围内的绿色部分是定义并评价买卖信号的部分。
所以一般开发策略组合并回测时会有以下运行过程。

1. 读解并运行蓝色部分。个股和气使用数据部分被指定。
1. 读解并运行绿色部分。针对被指定股票的历史数据配列进行运算，满足设定条件时输入买卖信号。（信号全在这里被定义）
1. 从历史数据开始调出并运行橙色部分。根据指定日期的仓位进行止损或确定盈利，或根据俄绿色部分所制定的信号买卖股票。

<br style="clear: right">

## 代码的解释说明{#code-top}

### 初始化部分{#initialize}

```python
def initialize(ctx):
```

初始化函数。ctx的method只能在initialize()里头才可以被调出。

```python
    ctx.configure(
```

在这里设定contest的初始值。

```python
        "cn.stock": {
```

指定日本股票为对象。而输入"cn.stock"就可以对应中国上证股票。


```python
          "symbols": [
            "jp.stock.7201",
            "jp.stock.9201",
            "jp.stock.9202",
            "jp.stock.7203"
          ],
```

指定目标证券的代码。
jp.stock.7201意味着日产汽车株式会社。


```python
          "columns": [
            "close_price_adj",    # 收盘价(调整股票拆细后)
            "volume_adj",         # 成交量
            "txn_volume",         # 成交金额
          ]
```

指定计算信号所需的数据种类。

以下是现在能使用的数据种类。

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



### 生成买卖信号的部分{#signal-emitter}


```python
    def _mavg_signal(data):
```
生成买卖信号的函数。

「data」是由所有目标股票，所有指定日期，所有数据组成的3次元配列。在这里是将「data」以配列的形式直接进行运算。

data在pandas.Panel的object里定义如下。

*      axis-0(items): 数据部分(close_price, volume, etc.)　　
*      axis-1(major): 日期(datetime.datetime型)　
*      axis-2(minor): 股票名(symbol object型)　　



以上述代码为例的话，data里头包含以下三次元形式的数据。

2017/5/9的

|| close_price_adj | volume_adj | txn_volume |
|:-----------:|:------------:|:------------:|:------------:|
|jp.stock.7201|值|值|值|
|jp.stock.9201|值|值|值|
|jp.stock.9202|值|值|值|
|jp.stock.7203|值|值|值|

2017/5/10的

|| close_price_adj | volume_adj | txn_volume |
|:-----------:|:------------:|:------------:|:------------:|
|jp.stock.7201|值|值|值|
|jp.stock.9201|值|值|值|
|jp.stock.9202|值|值|值|
|jp.stock.7203|值|值|值|


　　　　　　　　　　　　　　　　　　：
　　　　　　　　　　　　　　　　　　：

　　　　　　　　　　　适用范围内的所有日期份



```python
        m25 = data["close_price_adj"].fillna(method='pad').rolling(window=25, center=False).mean()
```

这里指定「close_price_adj（收盘价）」为数据对象。
所以，将包含所有目标股票和所有指定日期收盘价的2次元配列直接以配列的形式进行运算。

|| 2017/5/1 | 2017/5/2 | 2017/5/3 |…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|收盘价|收盘价|收盘价|…|
|jp.stock.9201|收盘价|收盘价|收盘价|…|
|jp.stock.9202|收盘价|收盘价|收盘价|…|
|jp.stock.7203|收盘价|收盘价|收盘价|…|


```python
fillna(method='pad')
```

数据偶尔会有一些缺损。比如因为跌停等原因确定不了收盘价时，收盘价数据是NaN。
这种情况下代码也会出现运行错误。所以通过这个method自动补全NaN数据。
但β版不能完全保障数据的完整度，请谅解。


```python
rolling(window=25, center=False).mean()
```

连续读取25个数据，并算出其平均。

关于rolling请参照
[pandas.DataFrame.rolling ](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.rolling.html)

关于mean请参照
[pandas.DataFrame.mean](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.mean.html#pandas.DataFrame.mean)

最终在2次元配列m25里会包含各个目标股票在各个日期的25天移动平均值（如下）。

|| 2017/5/1 | 2017/5/2 | 2017/5/3 |…|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|25天移动平均值|25天移动平均值|25天移动平均值|…|
|jp.stock.9201|25天移动平均值|25天移动平均值|25天移动平均值|…|
|jp.stock.9202|25天移动平均值|25天移动平均值|25天移动平均值|…|
|jp.stock.7203|25天移动平均值|25天移动平均值|25天移动平均值|…|


```python
        m75 = data["close_price_adj"].fillna(method='pad').rolling(window=75, center=False).mean()
```

同样将收盘价的75天移动平均值的配列纳入m75。

```python
        ratio = m25 / m75
```
将2次元配列m25除以2次元配列m75。
25天移动平均值除以75天移动平均值的计算结果以2次元配列的形式纳入ratio。


```python
        buy_sig = ratio[ratio > 1.05]
```
在这里首先判断 ratio > 1.05 。生成25天移动平均值除以75天移动平均值超过1.05时为TRUE，其余为FALSE的理论值2次元配列。
ratio[理论值2次元配列]将被纳入2次元配列buy_sig里头，所以只有25天移动平均值除以75天移动平均值超过1.05时才有元素纳入buy_sig，其余为NaN。

```python
        sell_sig = ratio[ratio < 0.95]
```
同样25天移动平均值除以75天移动平均值低于0.95时，纳入sell_sig配列里。


```python
        return {
            "mavg_25:price": m25,
            "mavg_75:price": m75,
            "buy:sig": buy_sig,
            "sell:sig": sell_sig,
        }
```

定义之后使用的配列。同时定义chart上所显示的名称。
比如在chart下面以"buy:sig"的名称显示「buy_sig」配列。

同时作为suffix，如sig被使用，将被特定，在chart上可以形成矩阵确认范围。
这个时候，

* key里包含buy,pos时为粉红色
* key里包含sell,neg时为浅蓝色

的颜色将被固定利用。



```python
    ctx.regist_signal("mavg_signal", _mavg_signal)
```
将上述说明过的函数「_mavg_signal」进行登陆并使用。


## 逐日处理部分的记述{#handle-signals}

接下来，说明逐日被调出的函数部分。比如做100天份的数据回测时，将会被调出100次。
在这里指定买卖多少股票，或止损以及确定盈利等。


```python
def handle_signals(ctx, date, current):
```


date是datetime.datetime型。current是包含date的当天数据以及信号的pandas.DataFrame object。
比如有以下构造。

|| close_price | open_price | sig1 |sig2(在regist_signal登陆的信号)|
|:-----------:|:------------:|:------------:|:------------:|:------------:|
|jp.stock.7201|值|值|值|值|
|jp.stock.9201|值|值|值|值|
|jp.stock.9202|值|值|值|值|
|jp.stock.7203|值|值|值|值|


比如，current["close_price"] 的话，将返回configure()所指定股票的close_price的pandas.Series object。

ctx拥有以下method(是与initialize()传递的ctx不同的object，请注意)

<dl>
  <dt>ctx.getSecurity(sym)</dt>
  <dd>返回相当于sym的Security object</dd>

  <dt>ctx.portfolio</dt>
  <dd>管理资产配置的Portfolio object</dd>

  <dt>ctx.localStorage</dt>
  <dd>下次handle_signals()被调用时，保存数据用的领域。
在这里设定的值，在今后handle_signals()被调用时也会收到保障</dd>
</dl>


```python
    done_syms = set([])
```
为防止根据当天信号进行的买卖交易和「止损交易，确定盈利交易」不重复，而准备区别用标签。

```python
    for (sym,val) in ctx.portfolio.positions.items():
```
如果当天有持有的股票，进行那个部分的处理。

```python
        returns = val["returns"]
```
获取与持仓的市场价格之间的差异

```python
        if returns < -0.03:
```
判断市场价格是否低于获取价格3%以下。

```python
          sec = ctx.getSecurity(sym)
```
获取改股票的Security object。

同时，Security object拥有以下的method。

*    code()    : 返回code值(ex. 9984)
*    unit()    : 返回买卖单位(ex. 100)

下单相关的函数

*      order()
*      order_value()
*      order_target_value()
*      order_target()
*      order_target_percent()
*      order_percent()

不对应style引数。


```python
          sec.order(-val["amount"], comment="止损卖出(%f)" % returns)
          done_syms.add(sym)
```
进行卖出处理，并标注不根据当天的信号进行买卖。



```python
        elif returns > 0.05:
          sec = ctx.getSecurity(sym)
          sec.order(-val["amount"], comment="为确定盈利卖出(%f)" % returns)
          done_syms.add(sym)
```
同样，升值5%以上，卖出确定盈利并标注。

```python
    buy = current["buy:sig"].dropna()
```
获取buy信号的pandas.Series object。

```python
    for (sym,val) in buy.items():
        if sym in done_syms:
          continue
```
执行buy信号所设定的部分。但无视标注着止损或确定盈利标签的部分。

```python
        sec = ctx.getSecurity(sym)
        sec.order(sec.unit() * 1, comment="SIGNAL BUY")
        pass
```
针对改股票进行下单。

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
同样执行卖出订单。

以上是样本程序的说明。
