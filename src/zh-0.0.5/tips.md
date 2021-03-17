# DataFrame的缺损值的补全

```python
cpa = data["close_price_adj"].fillna(method='ffill').rolling(window=25, center=False).mean()
```

缺损部分的数值设定为NaN(Not a Number)。
计算式里头如果包含NaN，计算结果也将自动变成NaN。
比如计算移动平均时，如果中间有一天的数值缺损，就意味着之后的所有计算将失败。
所以通过fill缺损值，可以顺利计算出缺损当天以后的移动平均。

http://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.fillna.html#pandas.DataFrame.fillna
