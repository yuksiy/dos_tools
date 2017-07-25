#!/bin/sh

# ==============================================================================
#   機能
#     プログラムの処理を一時停止し、キー入力を待つ
#   構文
#     USAGE 参照
#
#   Copyright (c) 2006-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
trap "" 28				# TRAP SET
trap "POST_PROCESS;exit 0" 1 2 15	# TRAP SET

SCRIPT_ROOT=`dirname $0`
SCRIPT_NAME=`basename $0`
PID=$$

######################################################################
# 関数定義
######################################################################
PRE_PROCESS() {
	:
}

POST_PROCESS() {
	# 端末設定の戻し
	STTY_RESTORE
	# 画面に改行を追加出力
	echo
}

# 端末設定の変更
STTY_CHANGE() {
	STTY_STATE_SAVE="$(stty -g)"
	stty raw -echo
}

# 端末設定の戻し
STTY_RESTORE() {
	stty "${STTY_STATE_SAVE}"
}

USAGE() {
	cat <<- EOF 1>&2
		Usage:
		    pause.sh [OPTIONS ...]
		
		OPTIONS:
		    --help
		       Display this help and exit.
	EOF
}

######################################################################
# 変数定義
######################################################################
#ユーザ変数

# システム環境 依存変数

# プログラム内部変数

#DEBUG=TRUE

######################################################################
# メインルーチン
######################################################################

# オプションのチェック
CMD_ARG="`getopt -o \"\" -l help -- \"$@\" 2>&1`"
if [ $? -ne 0 ];then
	echo "-E ${CMD_ARG}" 1>&2
	USAGE;exit 1
fi
eval set -- "${CMD_ARG}"
while true ; do
	opt="$1"
	case "${opt}" in
	--help)
		USAGE;exit 0
		;;
	--)
		shift 1;break
		;;
	esac
done

# 作業開始前処理
PRE_PROCESS

#####################
# メインループ 開始 #
#####################

# プロンプトの表示
printf "Press any key to continue ... "

# 端末設定の変更
STTY_CHANGE

# キーボード入力の1文字読み込み
reply="`exec dd bs=1 count=1 2> /dev/null`"

# 端末設定の戻し
STTY_RESTORE

# 改行の表示
echo

# 作業終了後処理
POST_PROCESS;exit 0

#####################
# メインループ 終了 #
#####################

