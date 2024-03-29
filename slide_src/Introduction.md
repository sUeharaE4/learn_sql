---
marp: true
theme: base
paginate: true
footer: SQL勉強会
---

# SQL 勉強会

※こちらは社内の勉強会向け資料です。PostgreSQLとGrafanaで簡単なダッシュボードを作れるようになってもらうためにSQLの基礎を学んでもらうためのものです。なのでREAD以外は手を抜きます。
　また、新入社員研修でSQLの基本は学んでいて、概念は知ってるけど実務で使わないから急に書けって言われると慌てちゃうなって方向けなのでRDBの基本概念みたいなものは扱いません。

---
# はじめに

勉強会を開催しておきながら不誠実ですが、あまり真面目にSQLを学んだことがありません。初歩的なSQLしか書かないですが、その説明は厳密ではないし例が悪いかもしれませんのであくまで簡単なSQLなら書けるレベルになってもらうためのものだと思ってください。もしSQLに詳しくなってこの記述や内容は不適切だと思ったらどんどん指摘してください。

また、SQLはDBにクエリ(問い合わせなどの命令)を発行するための言語で`SELECT * FROM table WHERE col1 = 'aaa';`などSQLを使って書かれた命令をSQL文と呼ぶのが正しいと思いますがそのへんを厳密に区別したりしません。通常は現場でも区別して会話しないことが多いと思います。ただ、クエリはDBへの命令文でその命令文を作るものがSQL文って区別は知っておいてください。

---
# はじめに

特に断りがない限りはクライアントはpsqlを使用します。
PostgreSQLのサンプルデータセットを使っているのでデータ量が小さいからあまり件数を気にせずデータを取得するSQLを書いていますが本来はデータ量を予め確認して無理ない範囲でデータを取得するように心がけることが重要です。
億超えテーブルからデータを取ろうものならSQLクライアントのメモリがパンクして、中断出来なくなったクエリがDBで実行され続けるなんてこともあります。
(まぁPID指定で中断すれば良いのですが、そういう危ないことは避けれるようになってほしいですね。うわヤベェ!!!を経験しないと難しいかもですが、取り返しがつくヤベェになるかわかりませんからね。)

---

# 開催予定

あくまで予定なので業務状況に合わせて変わっていく可能性もありますし、資料作って思ったより長い短いで分割統合することもあります。予めご承知おきください。

|タイトル|概要|
|---|---|
|SELECT, FROM and LIMIT|一番基本となるDBからデータを取得する方法について記載します|
|WHERE(比較, IN, LIKE, etc)|特定の条件で取得データにフィルターをかける方法について記載します|
|WITH and ORDER BY|サブクエリやサブクエリを共通化して1つのSQL内で使い回す方法について記載します|
|JOIN|テーブルの結合について記載します|
|GROUP BY, HAVING and COUNT|何かしらのグループ毎に集計などの操作を行う方法について記載します|
|INSERT, UPDATE and DELETE|READ以外のCRUD操作についてザックリ記載します|

---

# 環境構築
PostgreSQLをインストールして起動しておいてください。Dockerで準備するなら下記コマンドで良いと思います。永続化するかどうかは任せます。
開発環境のPostgreSQLを使う場合は予めdumpを取って今の状態に戻せるようにしておきましょう。おまけに書いておきます。

```bash
sudo docker run --rm -d \
     -p 5432:5432 \
     -v postgres-tmp:$PWD/data \
     -e POSTGRES_HOST_AUTH_METHOD=trust \
     postgres:12-alpine
```

サンプルデータは公式サイトからダウンロードしてzipを展開しておいてください。
https://www.postgresqltutorial.com/postgresql-sample-database/

---

# 環境構築

サンプルデータを展開するとtarファイルが得られます。このtarファイルとpg_restoreを使って勉強会で利用するテーブルを作りましょう。ただ、最初のうちはこのデータセット使いますが、時系列のサンプルデータも追加するかもしれません。

まずはdvdrentalデータベースを作成します。psqlでpostgresに接続しましょう。
```bash
psql -h localhost -p 5432 -U postgres
```

接続できたらデータベースを新たに作成します。
```sql
CREATE DATABASE dvdrental;
\q
```

---
# 環境構築

次にレストアしてください。tarがカレントに存在する前提で書いているのでコマンド実行場所に合わせて適宜修正してください。これでデータの準備は完了です。

```bash
pg_restore -h localhost -p 5432 -U postgres -d dvdrental dvdrental.tar
```
これ以降は作成したdvdrentalデータベースを使用するので下記コマンドで接続してください。

```bash
psql -h localhost -p 5432 -U postgres -d dvdrental
```

---

# おまけ
今回の勉強会ではデータベースとは何か、RDBとは何かは扱わないのでこの辺のことを知りたい方は各自調べてみたり mixi さんのデータベース研修や AI SHIFT さんのSQL研修などを参照してください。
https://speakerdeck.com/mixi_engineers/21-database-training
https://www.ai-shift.co.jp/techblog/1980

また、PostgreSQLのアーキテクチャについてはこちらが詳しいです。https://www.fujitsu.com/jp/products/software/resources/feature-stories/postgres/article-index/architecture-overview/

---

# おまけ
psqlでDBのdumpを作成・復元する方法の一例です。いくつかオプションや選択肢(pg_dump, pg_dumpallでdumpしてpsql, pg_restoreで復元)がいくつかあるので自分の環境に合うものを調べて使ってください。特にplainで出力するとだいぶ容量とるので注意です。ちゃんと出来てるかわかりやすいですが。

```bash
pg_dump -h localhost -p 5432 -U postgres -F plain -v -f mydb_dump.sql mydb 2> mydb_dump.log
```

復元する際には空のデータベースが必要です。既に同じ名前でデータベースがある場合はDROPしてCREATEし直しましょう。
```bash
psql -h localhost -p 5432 -U postgres mydb -f mydb_dump.sql 2> mydb_dump_restore.log
```