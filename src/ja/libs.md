# 利用可能ライブラリ、制限事項等

## 利用可能ライブラリ

QuantX Factoryで利用できるライブラリのバージョンは次のようになっています。

### maron-0.0.1系

| packages | version |
|-----------|------------|
| Python | 3.5.2 |
| numpy | 1.13.3 |
| pandas | 0.19.2 |
| statsmodels | 0.8.0 |
| scikit-learn | 0.19.1 |
| scipy | 1.0.0 |
| TA-lib| 0.4.10 |

### maron-0.1.0系

| packages | version |
|-----------|------------|
| Python | 3.5.2 |
| numpy | 1.14.0 | 
| pandas | 0.19.2 | 
| statsmodels | 0.8.0 | 
| scikit-learn | 0.19.1 |
| scipy | 1.0.0 |
| TA-lib| 0.4.16 |
| cvxopt | 1.1.9 |
| xgboost | 0.7.post3 |
| Keras | 2.1.3 |
| chainer | 3.3.0 |
| tensorflow | 1.5.0 |


## ソースコード制限事項

QuantX Factoryで開発可能なアルゴリズムのソースコードには現在のところ以下の制限事項があります。

- `バックスラッシュ` による改行ができない

