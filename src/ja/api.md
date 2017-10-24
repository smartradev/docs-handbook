# TinyLogging{#TinyLogging}

  Pythonのlogging APIと同じ仕様で、以下のメソッドがある。

```python
    def debug()
    def info()
    def warn()
    def error()
    def critical()
```

  それぞれのログレベルで、コンソールにログメッセージが出力される。

---

# Portfolio{#Portfolio}

  ポートフォリオを管理するオブジェクト

## portfolio.positions : dict
   保有している各銘柄にす関する情報を格納しているdict
   keyはsymbolで、次のような値をもつ

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

# pandas情報{#pandas}

## pandas.Panel(3次元)

[pandas.Panel](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Panel.html)

## pandas.DataFrame(2次元)

[pandas.DataFrame](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.html)

## pandas.Series(1次元)

[pandas.Series](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.html)

---

# Order

注文系関数

*      order()
*      order_value()
*      order_target_value()
*      order_target()
*      order_target_percent()
*      order_percent()

style引数には対応していません。
