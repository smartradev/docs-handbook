# シグナル生成関数サンプル1{#signal-emitter-sample1}

VisualCodingで提供されているコンポーネントから呼び出される関数。VisualCodingの画面を見ながら対応を見るとわかりやすい。
有効日数を実現するために、DataFrame.shift()を使っている。shift()は、過去の値を参照するのによく使う。

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
      df_d = op(df_c).astype(int)         # 値を1,0にする

      sum = pd.DataFrame(data=0,index=df_d.index, columns=df_d.columns)
      for i in range(vp+1):
        sum += df_d.shift(i)

      return {
        # for debug
        "df_d": df_d,                     # 当日の値
        "df_d_1": df_d.shift(1),          # 1日前の値
        "df_d_2": df_d.shift(2),          # 2日前野値
        "sum": sum,                       # (当日の値 + 1日前の値 + 2日前の値)

        # signal...
        "vc_sma:sig": (df_d > 0) & (sum > 0) & (sum <= vp)
      }
```
