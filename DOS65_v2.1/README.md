## OSI DOS/65について
オリジナルのReadme.mdを引用しています。そして、必要事項を付け加えてあります。<br>
オリジナルは[こちら](https://github.com/osiweb/DOS65/tree/master)

# DOS/65
DOS/65はRich Leary によって開発された、6502 用の本格的な CP/M 互換機です。<br>
ソフトウェアとドキュメントは、個人 (愛好家) が使用できるように公開されています。<br>

OSIWeb フォーラムのスレッドはこちらをご覧ください: http://osiweb.org/osiforum/viewtopic.php?f=4&t=235

このソフトウェアは商用ソフトウェアであるため、販売目的でソフトウェアを再配布する場合は<br>
Richard Leary氏に連絡してください (ライセンス情報は下記を参照)。<br>

## Contents
このアーカイブの内容は、2015 年に Rich Leary氏によって OSIWeb フォーラムに投稿されました。<br>
このアーカイブには起動可能なイメージは含まれていません。<br>
MEZW65C_RAMで動作するバイナリイメージを作成するために必要なソースとドキュメントが含まれています。<br>

### [Documentation](Documentation)

このディレクトリには、すべてのマニュアルと、OS65-D ディスクからデータとディレクトリを読み取るための DOS/65 ユーティリティがいくつか含まれています。

### [DOS65.SYS](dos_src)
ソースファイルは、[WDCTOOL](https://wdc65xx.com/WDCTools)のアセンブラ用に修正しました。<br>
Windows用のバッチファイルでバイナリのDOS65.SYSを作成できます。<br>

### [Source](Source)
This is the 6502 assembly code for v2.1<br>
ソースファイルは、[WDCTOOL](https://wdc65xx.com/WDCTools)のアセンブラ用に修正しました。<br>
Windows用のバッチファイルでバイナリのアプリケーションを作成できます。<br>

## DEBUGプログラムは動作出来ない<br>（モニタの呼び出し機能を使ってデバッグ）
オリジナルのDEBUGプログラムは、IRQ/BRKのベクタを書き換えます。しかしファームウェアRev2.1は<br>
IRQ/BRKを使って周期的にコンソール入出力を管理しているため、DEBUGを動かすことが出来ません。<br>
Rev2.1では、DEBUGの代わりに、常駐モニタを呼び出す機能を用意しています。<br>
DOS/65が起動している状態で、コンソール入力待ち（もしくは、キー入力チェック）の時に、<br>
ＣＴＬ＋￥キーを入力することでモニタが立ち上がります。<br>
このモニタの呼び出し機能を使用して、いつでもプログラムをデバッグすることが出来ます。<br>

![](https://github.com/akih-san/MEZW65C_RAM-Rev2.1/blob/main/photo/invoke_monitor.png)

<br>
モニタは、BYEコマンドでモニタを終了すると、呼び出し元に戻ります。<br>
ファームウェアから、monitorコマンドで呼び出したときは、ファームウェアに戻り、<br>
DOS/65から、ＣＴＬ＋￥キーで呼び出した場合は、DOS/65に戻ります。<br>
<br>

## 著作権

著作権 (c) Richard A. Leary、180 Ridge Road、Cimarron、CO 81220<Br>

このドキュメントおよび関連ソフトウェアは、パブリック ドメイン、フリーウェア、またはシェアウェアではありません。<Br>
これらは商用ドキュメントおよびソフトウェアです。<Br>
<Br>
Richard A. Leary氏は、このドキュメントとソフトウェアを個人的かつ非営利的な使用目的で無料で配布することを許可しています。<Br>
販売に関しては、Richard A. Leary氏から許可を得ない限り、これを再配布することはできません。<Br>
<Br>
CP/M は Caldera の商標です。<Br>
