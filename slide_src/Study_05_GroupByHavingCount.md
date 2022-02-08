---
marp: true
theme: base
paginate: true
footer: SQL 勉強会 GROUP BY, Having and COUNT
---

# SQL 勉強会 GROUP BY, Having and COUNT
今回は特定の単位で集計(だけじゃないけど主に集計)を行うGROUP BYについて扱います。文字通り指定した要素でデータセットをグループ化することが出来ます。
例えば映画のカテゴリ毎にどれだけフィルムがあるか数えたりカテゴリ毎の上映時間の平均を求めるみたいな時に使われることが多いです。なのでGROUP BYは集計関数やCOUNTと一緒に使われることが多いです。
HAVINGはGROUP BYした後に条件で絞り込む時に使われます。WHERE句はGROUP BYの前に評価されるので、GROUP BYした後のデータセットで使うWHERE句みたいなイメージでHAVINGを使います。

---

# GROUP BY, Having and COUNT GROUP BY
GROUP BY する際はグループ化したい単位でカラムを選んでGROUP BY句に指定します。例えばcustomerテーブルのデータをstore_idでグループ化してCOUNTすることでストア毎の顧客数を確認してみましょう。

```sql
SELECT
  store_id
  , count(*) AS customers -- 別名をつけることも出来るがHAVINGで別名は使えないので注意
FROM
  customer
GROUP BY
  store_id;
```

```sql
 store_id | customers
----------+-----------
        1 |       326
        2 |       273
(2 rows)
```

---

# GROUP BY, Having and COUNT GROUP BY
GROUP BY は単一のカラムで行う必要はありません。複数のカラムの組み合わせでグループ化することも可能です。複数カラム使うときはカンマ区切りで連結します。

```sql
SELECT
  customer_id
  , staff_id
  , SUM(amount) AS total_amount
FROM
  payment
GROUP BY
  customer_id
  , staff_id
ORDER BY
  total_amount DESC; -- HAVINGで別名は使えないけどORDER BYでは使える
```

---

# GROUP BY, Having and COUNT GROUP BY
JOINしていくつかのテーブルを結合してグループ化することも可能です。例えばカテゴリ毎の上映時間の平均を求める場合は情報がfilm, film_category, categoryテーブルに別れているのでJOINしてcategory_idでグループ化します。

```sql
SELECT
  c.name
  ,AVG(f.LENGTH)
FROM
  film f -- テーブル名にも別名をつけることが出来ます。_区切りの先頭文字だけ取ることが多いですかね。
  INNER JOIN
    film_category fc -- テーブルの別名をつけるときは AS は省略されることが多い気がします。
  ON  f.film_id = fc.film_id
  INNER JOIN
    category c
  ON  fc.category_id = c.category_id
GROUP BY
  c.category_id
ORDER BY
  c.category_id;
```

---

# 自分でやってみよう
好きなテーブルを選んで好きな単位でグループ化してみましょう。DATE関数を使うことで日時データを日付データにして日毎の売上とか計算することも出来ます。
JOINしてGROUP BYもするようなクエリは始めのうちは一発で書ける必要はないのでまずちゃんとJOINを書いてGROUP BYするとか少しずつ進めましょう。ただ、GROUP BYしない場合は集計関数が使いにくいのでJOINの確認はSELECT * にしたりいくつかのカラムだけ選ぶ方が良いです。全カラム取ると折り返しが出るのでいくつかのカラムを選んだほうが良いですね。

---

# GROUP BY, Having and COUNT HAVING

GROUP BY した後のデータで特定の条件で絞り込みをする場合はHAVINGを使います。WHEREを使うとグループ化する前のデータを絞り込みしてしまうので注意してください。
すでにコメントでは記載していますがHAVING句では残念ながらSELECT句で作った別名を使えないので気をつけましょう。

---

# GROUP BY, Having and COUNT HAVING

```sql
SELECT
  customer_id
  , staff_id
  , SUM(amount) AS total_amount
FROM
  payment
GROUP BY
  customer_id
  , staff_id
HAVING
  SUM(amount) > 100 -- HAVING では別名が使えない
ORDER BY
  total_amount DESC; -- HAVINGで別名は使えないけどORDER BYでは使える
```

---

# GROUP BY, Having and COUNT HAVING

先程のクエリにWHERE句を付けてみましょう。GROUP BY の前に書かないとエラーになることからもなんとなく想像つくと思いますがWHEREが先に評価されます。ただ、なんとなくそうなりそうって思うのではなくドキュメントを確認する習慣は付けましょう。

---

# GROUP BY, Having and COUNT HAVING

```sql
SELECT
  customer_id
  , staff_id
  , SUM(amount) AS total_amount
FROM
  payment
WHERE
  customer_id < 100
GROUP BY
  customer_id
  , staff_id
HAVING
  SUM(amount) > 100
ORDER BY
  total_amount DESC;
```

---

# 自分でやってみよう
HAVINGやWHEREを使ったSQLを書いてみましょう。今回のデータセットは小さいので色々試しながらかけますが、ある程度のデータ量があればGROUP BYを気軽に実行しながら書くという行為は危険です。自分がほしいデータを引くSQLが書けているか動かしながら試したいときはWHEREで最小限のデータに絞ることが必要なのでWHEREで絞りつつGROUP BYする練習をしましょう。

---

# 簡単なSELECTを終えて
まだWINDOWやUNIONあたりを扱っていませんが、ここまで扱ってきた内容で簡単なSELECTは書けると言って良いのではないかと思っています。ここまで感覚や使われ方ベースでSELECTについて記載してきたので、一度使い方ベースでSELECTについて読んでみてください。(versionは適宜合わせて)
https://www.postgresql.jp/document/10/html/sql-select.html

使われ方だけ知っている状態ではその使われ方くらいしか出来ません。使い方を知っていれば今までやったことなくても出来るか出来ないか判断することが可能になります。要件に対してやってみなくても実現可否が判断出来ると大きなアドバンテージになります。少しずつで良いので使い方(要は関数の定義だったりリファレンス、公式ドキュメント)を読む習慣をつけてください。

---

# おまけ

日次で集計するサンプル。
```sql
SELECT
  DATE(payment_date) AS paid_date,
  SUM(amount) sum
FROM
  payment
WHERE
  payment_date > '2007-01-31'
AND
  payment_date < '2007-03-01'
GROUP BY
  DATE(payment_date)
ORDER BY
  paid_date;
```

SQLの評価順(FROM WHERE とか書かれた画像参照)
https://www.postgresqltutorial.com/postgresql-group-by/