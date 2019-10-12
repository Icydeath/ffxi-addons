# ChatWindow
- //cw visible
  - 表示/非表示を切り替え
- //cw row `行数`
  - 表示する行数を設定
- //cw pos `x` `y`
  - 表示場所を変更。画面左上が0,0

### settings.xml(自動生成)
- alert
  - regex `string` : キーワードを[正規表現](http://www.mnet.ne.jp/~nakama/)で指定
  - wav `string` : キーワードにマッチしたら再生
- chatfilter `true/false` : 指定チャットチャンネルを非表示/表示
- reverse `true/false` : ログ表示を降順/昇順に変更
- time `true/false` : 時刻表示/非表示
- timeformat `string` : 時刻の表示フォーマットを変更
  - 参考: [Luaで日付時間操作。](http://noriko3.blog42.fc2.com/blog-entry-128.html)
- ARGB `number` : [RGB](https://www.rapidtables.com/web/color/RGB_Color.html)で色指定。Aは透過度(0~255)
