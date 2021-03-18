# TA-libの呼び出し方サンプル{#signal-emitter-sample2}

TA-libの呼び方。

```python

    def _CDLBELTHOLD(p):
      op = p["open_price_adj"]
      cp = p["close_price_adj"]
      hp = p["high_price_adj"]
      lp = p["low_price_adj"]

      result = {}
      for (sym,val) in op.items():
        result[sym] = ta.CDLBELTHOLD(op[sym],
                                     hp[sym],
                                     lp[sym],
                                     cp[sym])

      #ctx.logger.debug(val)

      # numpy.ndarrayのdictから、pandas.DataFrameを再構築する。
      df = pd.DataFrame(data=result, index=op.index, columns=op.columns)

      return {
        "CDLBELTHOLD_LONG:sig": (df > 0),   # df>0のマスがTrueのDataFrame
        "CDLBELTHOLD_SHORT:sig": (df < 0),  # df<0のマスがTrueのDataFrame
        "CDLBELTHOLD": df                   # 生の値のDataFrame
      }
```
