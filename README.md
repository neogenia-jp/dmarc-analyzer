# dmarc-analyzer

DMARCレポートをgmailから取得して解析を行ってくれるシステムです。

## セットアップ

### Google Cloud Platformの設定

DMARCレポートを取得するGmailアカウントで以下の設定が必要です。

- GmailAPIの有効化
- OAuth同意画面の作成
- OAuth 2.0 クライアントIDの作成

設定方法は以下の資料を参考にしてください。
https://analytics-x.tech/archives/5613

作成したアプリの公開ステータスは「テスト中」でも問題ありません。
「テスト中」の場合はテストユーザにGmailアカウントを指定してください。

OAuth 2.0 クライアントIDを作成した際に出力されるjsonファイルは環境変数`CREDENTIALS_PATH`で指定している場所に置いてください。
指定しない場合は`/app/credentials.json`がデフォルトになります。

### コンテナの立ち上げ
以下のコマンドでコンテナを立ち上げます。
```
docker compose up --build
```


## アプリの認証（初回のみ）
初回のみ、Rubyスクリプトを起動すると、以下のようなメッセージが表示されます。
表示されたURLにブラウザでアクセスし、認証コードを取得して、貼り付けてください。

```
neo@ubuntu-work:~/repos/dmarc-analyzer$ docker exec -it ruby ruby /app/dmarc_reports_collector.rb
Open the following URL in the browser and enter the resulting code after authorization:
<ここにURLが表示される>
Enter code: <ここに貼り付ける>
```

認証に成功すると、環境変数`TOKEN_PATH`で指定したパスにファイルが作成されます。
指定しない場合は`/app/token.yaml`がデフォルトになります。

## 解析結果の確認方法
Grafanaというデータを可視化するソフトウェアを使用しています。  
Grafanaコンテナを立ち上げ、ブラウザで3000番ポートでアクセスしてください。  
```
# 例
http://192.168.56.2:3000/
```

## 参考
[dmarc-visualizer](https://github.com/debricked/dmarc-visualizer)