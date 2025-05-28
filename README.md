# dmarc-analyzer

DMARCレポートをgmailから取得して解析を行ってくれるシステムです。

## セットアップ
```
docker compose up --build
```

## DMARCレポート取得のための設定方法
TODO

## 解析結果の確認方法
Grafanaというデータを可視化するソフトウェアを使用しています。  
Grafanaコンテナを立ち上げ、ブラウザで3000番ポートでアクセスしてください。  
```
# 例
http://192.168.56.2:3000/
```


## 参考
[dmarc-visualizer](https://github.com/debricked/dmarc-visualizer)