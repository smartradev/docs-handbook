# jp.thomsonreuters.index

トムソン・ロイター・ジャパン株式会社から提供されたインデックスのデータです。

| キー | 說明 |
|---|---|---|
| symbols| データを取得する項目を配列で指定します。 |
| columns| symbolsで指定した項目において、取得するデータの種類を配列で指定します。 |

## symbols

各項目において取得するデータの種類を指定します。指定可能な値は次の通りです。

| 識別名 | 内容 | 説明 |
|:-----------|:------------|:------------|
|**n225**|日経225|東京証券取引所市場第一部に上場する銘柄の内、市場を代表する225銘柄を対象とした株価指数|
|**topix**|TOPIX|東証一部に上場している全銘柄の合計時価総額を対象とした株価指数|
|**mothers**|マザーズ指数|東証マザーズに上場している全銘柄の合計時価総額を対象とした株価指数|
|**jasdaq**|JASDAQ Index|ジャスダックに上場している全銘柄の合計時価総額を対象とした株価指数|
|**jasdaq_std**|JASDAQ STANDARD|ジャスダックスタンダードに上場している全銘柄の合計時価総額を対象とした株価指数|
|**jasdaq_top20**|JASDAQ TOP 20|JASDAQ市場に上場する銘柄のうち、流動性や上場時価総額等多面的な尺度で選定する20銘柄を. 対象とした株価指数|
|**jasdaq_growth**|JASDAQ GROWTH|ジャスダックグロースに上場している全銘柄の合計時価総額を対象とした株価指数|
|**tsreit**|東証REIT指数|東京証券取引所に上場している不動産投資信託（J-REIT）全銘柄を対象とした時価総額加重平均の指数|

## 指定例

日経225とTOPIXのデータを取得する場合

```python
  ...
  symbols: ["n225", "topix"]
  ...
```

## columns

各項目において取得するデータの種類を指定します。指定可能な値は次の通りです。

| 識別名 | 内容 | 説明 |
|:-----------|:------------|:------------|
|**price_index**|指数|指数|
|**market_value**|Market Value|時価総額|
|**total_return_index**|Total Return Index|株価指数の構成銘柄の値動きだけでなく、構成銘柄の配当も加味したパフォーマンスを示す株価指数|
|**turnover_by_volume**|Turnover by volume|売買高（出来高）|
|**turnover_by_value**|Turnover by Value|時価総額|
|**per**|Price / Earning Ratio|1株当たり当期純利益|

## 指定例

指数と時価総額のデータを取得する場合

```python
  ...
  columns: ["price_index", "market_value"]
  ...
```

## 例

日経225とTOPIX、東証REIT指数の、指数と時価総額を取得したい場合は、
initialize()関数の中で次のような形式で、ctx.configure()を呼び出します。

```python
  ctx.configure(channels={
      "jp.thomsonreuters.index": {
          "symbols": [
              "n225",
              "topix",
              "tsreit",
        ],
        "columns": ["price_index", "market_value"]
      }
  }

```
