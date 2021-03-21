# attackwithme - by yyoshisaur

### :tada: v0.0.7 - modded by icy 

#### New Settings

	{...} are optional

	//awm set master {name} ~ sets current player or name to auto load as master

	//awm set slave {name} ~ sets current player or name to auto load as slave

	//awm closein ~ toggles slaves closing in on the target

	//awm closein [distance] ~ sets the slaves fighting distance

### original readme

/attackを複数のキャラクター同期させるアドオン

(/attackだけでなく、メニューからの攻撃にも対応)

- 使い方

3キャラクター A, B, Cがある場合　(A, B, Cすべてに本アドオンをロードしておく)

Aの戦闘開始に同期してBも戦闘開始する設定(Cは同期させない)

キャラクターAのクライアントで/attackするマスターを設定

        //atkwm master

キャラクターBのクライアントで "同期する" 設定

        //atkwm slave on

キャラクターCのクライアントで "同期しない" 設定

        //atkwm slave off

/attackoff(戦闘解除)も同期する