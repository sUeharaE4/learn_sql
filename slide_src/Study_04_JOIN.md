---
marp: true
theme: base
paginate: true
footer: SQL 勉強会 JOIN
---

# SQL 勉強会 JOIN
今回は複数のテーブルを結合するJOINについて学びます。複数のテーブルを結合することでRDBの強みを活かすことが出来ます。
前回までの内容は全部ではないにしろなんとなく初めて勉強したときに覚えたのではないかと思います。JOINやGROUP BY辺りから概念はわかるけど今書けって言われたらちょっと・・・となるのではないでしょうか(私だけ？)
お勉強の時にはあまりJOINを使うイメージがわかないかもしれませんが、業務でSQLを使う際にJOINを使わないことはおそらく無いと思います(JOINのコストを削ってとにかく早くデータを見るために予めJOINした結果を参照用に作っているマートからデータを取るとかは例外)。
幸いPostgreSQLのサンプルデータはリレーションが多いので練習題材が多いです。しっかり練習してJOINは書けるって言えるようにしましょう。まずは2〜3テーブルで良いです。

---

# SQL 勉強会 JOIN 結合の種類

それぞれのJOINを説明する図を作って入れるのが大変なので、PostgreSQLのTutorialにあるまとめ画像を貼っておきます。これだけで終わりな気がしなくもない。

> ![width:650px](https://www.postgresqltutorial.com/wp-content/uploads/2018/12/PostgreSQL-Joins.png "PostgreSQL-Joins.png")
> [PostgreSQLのtutorial](https://www.postgresqltutorial.com/postgresql-joins/)より引用



---

# SQL 勉強会 JOIN INNER JOIN

おそらく最もよく使うINNER JOIN(内部結合)をまず覚えましょう。2つのテーブルを指定したカラムで結合する際に2つのテーブルに共に存在する値のみ保持します。

```sql
SELECT
  *
FROM
  category -- 1つ目のテーブル
INNER JOIN -- どのようにJOINするか
  film_category -- 2つ目のテーブル
ON -- どのカラムで結合するか
  category.category_id = film_category.category_id
AND -- 複数カラムで結合することもできるしWHEREみたいな条件を指定することもできます
  category.category_id < 5;
```

---

# SQL 勉強会 JOIN INNER JOIN

先程の例ではONでcategory_idの絞り込みを指定しました。下記のように後でWHEREを指定することも出来ますが、ONの中で絞り込みしておくことでJOINする対象が制限できるので負荷が減ります。LIMITのときと似たようなことで先に絞り込みしてあげないと無駄な結合をして結合完了してから絞り込まれてしまうので注意が必要です。

```sql
SELECT
  *
FROM
  category
INNER JOIN
  film_category
ON
  category.category_id = film_category.category_id
WHERE
  category.category_id < 5;
```

---

# SQL 勉強会 JOIN 自分でやってみよう

好きなテーブルを選んでINNER JOINで結合してみましょう。結合の際にカラムだけではなく何かしらの絞り込み条件を使ってみましょう。
リレーションはPostgreSQLのサンプルデータセットのサイトで確認してください。または`\d`でテーブル名からなんとなく結合できそうなテーブルたちを探して同じ名前のカラムがあればそこで結合してみるのでもOKです。
(ER図が存在しないシステムは流石に珍しいと思います。保守したことあるからなんとも言えませんが...。ただ、信用できるER図があることは稀なので実態から探してみるっていうのもできると良いかな。)

---

# SQL 勉強会 JOIN LEFT JOIN

JOINする際に共通部分だけを取得するのではなく、結合できなかったとしてもメインとするテーブルは全て残して結合出来ない部分はNULLとして取得したいことがあると思います。
その場合はLEFT JOINやRIGHT JOINを使います。

```sql
WITH few_category AS (
  SELECT * FROM category WHERE category_id < 3
)
SELECT
  *
FROM
  few_category
LEFT JOIN
  film_category
ON
  few_category.category_id = film_category.category_id;
```

---

# SQL 勉強会 JOIN LEFT JOIN

残念ながらLEFT JOIN は機能追加をする際に暫定的に既存機能に影響を与えないために使われることがあります。こういう暫定対処でシステムはどんどんカオスになっていくので可能であれば暫定対処しないようにしましょう。

---

# SQL 勉強会 JOIN RIGHT JOIN

先程の例ではWITH句で取得した少ないほうのデータセットに合わせて取得されていたのがわかると思います。では今度は多い方に合わせてみましょう。FROMとJOINで指定するテーブルを入れ替えることで実現する音も出来ますがLEFT JOINをRIGHT JOINにすることで実現出来ます。

```sql
WITH few_category AS (
  SELECT * FROM category WHERE category_id < 3
)
SELECT
  *
FROM
  few_category
RIGHT JOIN
  film_category
ON
  few_category.category_id = film_category.category_id;
```

---

# SQL 勉強会 JOIN OUTER JOIN

OUTER JOIN については実は既に扱っています。LEFT OUTER JOIN は LEFT JOIN と同じ結果を返しますし、RIGTHについても同様です。LEFT/RIGHT JOIN は主体としたテーブルのデータは全て取得して結合先のテーブルにデータがあったら結合するという考え方なので外部結合そのものとなっています。
一応どっちのテーブルも全て取得するFULL OUTER JOIN という方法も存在するので紹介します。結合できないデータを捨ててよいか判断できない場合に使われるので、テーブル構成をある程度固めたシステムでは見かけないですがBIツールでこれからデータを眺めてみる時には使うんじゃないかなと思います。

---

# SQL 勉強会 JOIN OUTER JOIN

```sql
WITH few_category AS (
  SELECT * FROM category WHERE category_id < 3
)
SELECT
  *
FROM
  few_category
FULL JOIN -- 例によってOUTERは省略OK
  film_category
ON
  few_category.category_id = film_category.category_id;
```

---

# SQL 勉強会 JOIN 自分でやってみよう

好きなテーブルを選んで任意の JOINで結合してみましょう。OUTER JOINを使った際にNULLとなっているレコードを除外することで片方のテーブルにのみ含まれるデータを抽出することも出来ます。そんな事するならなんのためにJOINしてるのって思うかもしれませんが、バグや操作ミスで意図しないデータが片方のテーブルにのみ入ってしまった場合にそのデータを特定するなど意外と用途がある方法です。
JOINの図を参考に書いてみましょう。
