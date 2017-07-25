# dos_tools

## 概要

DOSツールの模造品

## 使用方法

### choice.sh

選択肢から選ぶためのプロンプトを表示します。  
その後、選択肢の中からユーザーが押したキーのオフセットが終了コードにセットされます。

以下の例では、「[a,b,c]?」というプロンプトが表示されます。  
「a」から「c」のキー入力に応じて、終了コードに「1」から「3」がセットされます。  
キー入力せずに10秒が経過すると、「a」が選択され、終了コードに「1」がセットされます。

    $ choice.sh -c abc -t a,10 2>/dev/null

### pause.sh

プログラムの処理を一時停止し、キー入力を待ちます。

    $ pause.sh

### その他

* 上記で紹介したツールの詳細については、「ツール名 --help」を参照してください。

## 動作環境

OS:

* Linux
* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* [common_sh](https://github.com/yuksiy/common_sh)

## インストール

ソースからインストールする場合:

    (Linux, Cygwin の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/dos_tools>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/dos_tools/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2006-2017 Yukio Shiiya
