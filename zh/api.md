# TinyLogging{#TinyLogging}

  和Python的logging API一样的构造，拥有以下method。

```python
    def debug()
    def info()
    def warn()
    def error()
    def critical()
```

  そ在console上显示各个log level的log message。

---

# Portfolio{#Portfolio}

  管理资产配置的object

## portfolio.positions : dict
   包含所持有的各股份信息的dict
   key是symbol，拥有以下值

```python
     {
                "amount": asset.amount,                          # 持股数量
                "total_buy_price": asset.total_buy_price,        # 迄今为止的总购买额
                "total_sell_price": asset.total_sell_price,      # 迄今为止的总卖出额
                "buy_price": bp,                                 # 当前position的总购入额(amount变成0的话自动reset到0)
                "sell_price": sp,                                # 当前position的总卖出额(amount变成0的话自动reset到0)
                "value": value,                                  # 当前评估市值
                "position_ratio": position_ratio,                # 当前所持有股票中的比率
                "portfolio_ratio": portfolio_ratio,              # 全资产中占的比率
                "pnl": value - (bp - sp),                        # 收益额
                "returns": returns                               # 收益率

     }
```

---

# pandas信息{#pandas}

## pandas.Panel(3次元)

[pandas.Panel](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Panel.html)

## pandas.DataFrame(2次元)

[pandas.DataFrame](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.html)

## pandas.Series(1次元)

[pandas.Series](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.html)

---

# Order

与下单相关的函数

*      order()
*      order_value()
*      order_target_value()
*      order_target()
*      order_target_percent()
*      order_percent()

不对应style引数。
