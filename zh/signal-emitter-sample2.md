# 调出TA-lib的样本{#signal-emitter-sample2}

TA-lib的调出方法。

通过op = p["open_price_adj"] 转换为 pandas.DataFrame，
再通过op[sym] 转换成 pandas.Series。
之后通过op[sym].values转换成numpy.ndarray。
因为TA-lib作为引述只接受ndarray，所以需要上述转换过程。

```python

    def _CDLBELTHOLD(p):
      op = p["open_price_adj"]
      cp = p["close_price_adj"]
      hp = p["high_price_adj"]
      lp = p["low_price_adj"]

      result = {}
      for (sym,val) in op.items():
        result[sym] = ta.CDLBELTHOLD(op[sym].values.astype(np.double),
                                     hp[sym].values.astype(np.double),
                                     lp[sym].values.astype(np.double),
                                     cp[sym].values.astype(np.double))

      #ctx.logger.debug(val)

      # 从numpy.ndarray的dict，重新构筑pandas.DataFrame。
      df = pd.DataFrame(data=result, index=op.index, columns=op.columns)

      return {
        "CDLBELTHOLD_LONG:sig": (df > 0),   # df>0的部分为True的DataFrame
        "CDLBELTHOLD_SHORT:sig": (df < 0),  # df<0的部分为True的DataFrame
        "CDLBELTHOLD": df                   # 元数据的DataFrame
      }
```
