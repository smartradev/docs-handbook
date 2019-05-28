# DataFrameの欠損値の補完

```python
cpa = data["close_price_adj"].fillna(method='ffill').rolling(window=25, center=False).mean()
```

欠損値は、NaN(Not a Number)として設定されています。
計算式の一部にNaNが含まれると、計算結果も自動的にNaNになってしまいます。
これは、たとえば移動平均を算出しようとした時に、途中の1日だけ欠損していた場合は、以降すべての計算に失敗してしまうことになります。
欠損値をfillすることで、欠損していた該当日以降の移動平均も算出することが可能になります。

http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.fillna.html#pandas.DataFrame.fillna
