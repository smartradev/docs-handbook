# 信号生成函数的样本1{#signal-emitter-sample1}

VisualCoding提供的功能条件里被调出的函数。同时参照VisualCoding界面会比较容易理解。
为了实现有效日期数，使用了DataFrame.shift()。shift()，常用于参照过去的值。

```python

    def _sma(data):
      # constant params...
      a = 25
      b = 75
      d = 1.10
      op = lambda x: x > d
      vp = 2

      # calc mavg...
      df_a = data["close_price_adj"].rolling(window=a, center=False).mean()
      df_b = data["close_price_adj"].rolling(window=b, center=False).mean()

      df_c = df_a / df_b
      df_d = op(df_c).astype(int)         # 将值设定为1,0

      sum = pd.DataFrame(data=0,index=df_d.index, columns=df_d.columns)
      for i in range(vp+1):
        sum += df_d.shift(i)

      return {
        # for debug
        "df_d": df_d,                     # 当天值
        "df_d_1": df_d.shift(1),          # 1天前的值
        "df_d_2": df_d.shift(2),          # 2天前的值
        "sum": sum,                       # (当天值 + 1天前的值 + 2天前的值)

        # signal...
        "vc_sma:sig": (df_d > 0) & (sum > 0) & (sum <= vp)
      }
```
