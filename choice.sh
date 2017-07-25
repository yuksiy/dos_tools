#!/bin/sh

# ==============================================================================
#   機能
#     選択肢から選ぶためのプロンプトを表示する
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

# プロセス番号表示
if [ ${DEBUG} ];then echo "\$\$=$$";fi

######################################################################
# 関数定義
######################################################################
PRE_PROCESS() {
	:
}

POST_PROCESS() {
	# 端末設定の戻し
	STTY_RESTORE
	# タイマープロセスの停止
	TIMER_STOP
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

# タイマープロセスの起動
TIMER_START() {
	# TIMEOUT値が指定されている(=TIMEOUT変数が「空文字」でない)場合
	if [ ! "${TIMEOUT}" = "" ];then
		# タイマープロセスをバックグラウンドで起動
		#(sleep ${TIMEOUT};kill `ps -ef | grep "dd" | grep -v "grep" | awk '{print $2}'`) &
		(sleep ${TIMEOUT};kill `ps -ef | grep "dd" | awk -v PID="${PID}" '{if($3==PID) print $2}'`) &
	fi
	# タイマープロセスのプロセス番号表示
	if [ ${DEBUG} ];then echo "\$!=$!";fi
}

# タイマープロセスの停止
TIMER_STOP () {
	# タイマープロセスのプロセス番号表示
	if [ ${DEBUG} ];then echo "\$!=$!";fi
	# タイマープロセスが実行中の場合
	if kill -0 $! 2> /dev/null;then
		# タイマープロセスの停止
		kill $!
	fi
}

USAGE() {
	cat <<- EOF 1>&2
		Usage:
		    choice.sh [OPTIONS ...] [TEXT] 2>/dev/null
		
		    TEXT : (NOT IMPLEMENTED!) Prompt string to display
		
		    Return code is set to offset of key user presses in choices.
		
		OPTIONS:
		    -c CHOICES (choice)
		       Specify allowable keys. Default is "${CHOICES}".
		       Only number or alphabet (i.e. 0-9, a-z or A-Z) can be included in choice keys.
		       Choice keys are treated as case sensitive.
		    -n (not-display)
		       (NOT IMPLEMENTED!) Do not display choices and ? at end of prompt string.
		    -t DEFAULT,TIMEOUT (timeout)
		       Default choice to DEFAULT after TIMEOUT seconds.
		       Specify 0 or a positive integer as TIMEOUT.
		    --help
		       Display this help and exit.
	EOF
}

. is_numeric_function.sh

######################################################################
# 変数定義
######################################################################
#ユーザ変数
#EXIT_FAILURE=1
EXIT_FAILURE=255

# システム環境 依存変数
EXPR="expr"

# プログラム内部変数
CHOICES="yn"							#初期状態が「空文字以外」でなければならない変数
#FLAG_OPT_NOT_DISPLAY=FALSE
DEFAULT=""								#初期状態が「空文字」でなければならない変数
TIMEOUT=""								#初期状態が「空文字」でなければならない変数
#TEXT=""

OFFSET=0								#初期状態が「0」でなければならない変数

#DEBUG=TRUE

######################################################################
# メインルーチン
######################################################################

# オプションのチェック
CMD_ARG="`getopt -o c:t: -l help -- \"$@\" 2>&1`"
if [ $? -ne 0 ];then
	echo "-E ${CMD_ARG}" 1>&2
	USAGE;exit 1
fi
eval set -- "${CMD_ARG}"
while true ; do
	opt="$1"
	case "${opt}" in
	-c)
		CHOICES="$2" ; shift 2
		# 「CHOICES」に指定された文字列に数値またはアルファベットだけが含まれているか否かのチェック
		echo "${CHOICES}" | grep -q -e '^[0-9a-zA-Z]*$'
		if [ $? -ne 0 ];then
			echo "-E argument to \"${opt}\" includes not only number or alphabet -- \"${CHOICES}\"" 1>&2
			USAGE;exit ${EXIT_FAILURE}
		fi
		;;
	-t)
		DEFAULT="`echo \"$2\" | awk -F',' '{print $1}'`"
		TIMEOUT="`echo \"$2\" | awk -F',' '{print $2}'`"
		if [ ! "`echo \"$2\" | awk -F',' '{print $3}'`" = "" ];then
			echo "-E argument to \"${opt}\" is invalid -- \"$2\"" 1>&2
			USAGE;exit ${EXIT_FAILURE}
		fi
		shift 2
		# 「TIMEOUT」に指定された文字列が数値か否かのチェック
		IS_NUMERIC "${TIMEOUT}"
		if [ $? -ne 0 ];then
			echo "-E \"TIMEOUT\" (=${TIMEOUT}) not numeric" 1>&2
			USAGE;exit ${EXIT_FAILURE}
		fi
		# 「TIMEOUT」に指定された数値が0または正の整数か否かのチェック
		if [ ${TIMEOUT} -lt 0 ];then
			echo "-E \"TIMEOUT\" (=${TIMEOUT}) not 0 or positive integer" 1>&2
			USAGE;exit ${EXIT_FAILURE}
		fi
		;;
	--help)
		USAGE;exit 0
		;;
	--)
		shift 1;break
		;;
	esac
done

## 第1引数のチェック
#if [ ! "$1" = "" ];then
#	TEXT=$1
#fi

# オプションの整合性チェック
# DEFAULT値が指定されている(=DEFAULT変数が「空文字」でない)場合
if [ ! "${DEFAULT}" = "" ];then
	# 「DEFAULT」に指定された文字が「CHOICES」に含まれていない場合
	echo "${CHOICES}" | grep -q -e "${DEFAULT}"
	if [ $? -ne 0 ];then
		echo "-E \"DEFAULT\" (=${DEFAULT}) not included in \"CHOICES\" (=${CHOICES})" 1>&2
		USAGE;exit ${EXIT_FAILURE}
	fi
fi

# 作業開始前処理
PRE_PROCESS

#####################
# メインループ 開始 #
#####################

# タイマープロセスの起動
TIMER_START

# プロンプトの表示
# (CHOICES のフィールドセパレータを「(なし)」から「,(カンマ)」に変更して表示)
printf "[`echo \"${CHOICES}\" | sed -e 's/\([0-9a-zA-Z]\)/\1,/g' | sed 's/,$//'`]?"

while :
do
	# 端末設定の変更
	STTY_CHANGE
	# キーボード入力の1文字読み込み
	reply="`exec dd bs=1 count=1 2> /dev/null`"
	# 端末設定の戻し
	STTY_RESTORE
	# タイマープロセスの停止
	TIMER_STOP
	# 押されたキーが「Ctrl+C」の場合
	if [ "${reply}" = "$(printf '\003')" ];then
		# 押されたキーの表示
		echo "^C"
		# 作業終了後処理
		POST_PROCESS;exit 0
	fi
	# 押されたキーが「空文字」(=タイムアウト)の場合
	if [ "${reply}" = "" ];then
		# DEFAULT値の採用
		reply="${DEFAULT}"
	fi
	# 押されたキーのOFFSETの取得
	OFFSET=`${EXPR} index "${CHOICES}" "${reply}"`
	# 押されたキーのOFFSETの判定
	case "${OFFSET}" in
		# 押されたキーが選択肢に含まれていない(=OFFSET変数が「0」である)場合
		0)
			# ビープ音の出力
			printf "\007"
			# ループの先頭への復帰
			continue
			;;
		# 押されたキーが選択肢に含まれている(=OFFSET変数が「0」でない)場合
		*)
			# 押されたキーの表示
			echo "${reply}"
			# 作業終了後処理
			POST_PROCESS;exit ${OFFSET}
			;;
	esac
done

#####################
# メインループ 終了 #
#####################

