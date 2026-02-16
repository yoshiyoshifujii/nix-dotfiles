{ config, pkgs, ... }:
let
  # macSKK辞書の保存先ディレクトリ
  dictDir = "${config.home.homeDirectory}/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries";

  # SKK辞書ファイルの定義
  skkDictionaries = {
    "SKK-JISYO.L" = {
      url = "https://github.com/skk-dev/dict/raw/master/SKK-JISYO.L";
      sha256 = ""; # 空の場合は検証をスキップ
    };
    "SKK-JISYO.jinmei" = {
      url = "https://github.com/skk-dev/dict/raw/master/SKK-JISYO.jinmei";
      sha256 = "";
    };
    "SKK-JISYO.geo" = {
      url = "https://github.com/skk-dev/dict/raw/master/SKK-JISYO.geo";
      sha256 = "";
    };
    "SKK-JISYO.propernoun" = {
      url = "https://github.com/skk-dev/dict/raw/master/SKK-JISYO.propernoun";
      sha256 = "";
    };
    "SKK-JISYO.station" = {
      url = "https://github.com/skk-dev/dict/raw/master/SKK-JISYO.station";
      sha256 = "";
    };
  };
in
{
  # アクティベーションスクリプトでSKK辞書をダウンロード
  home.activation.installSkkDictionaries = config.lib.dag.entryAfter ["writeBoundary"] ''
    DICT_DIR="${dictDir}"

    # 辞書ディレクトリが存在しない場合は作成
    if [ ! -d "$DICT_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$DICT_DIR"
    fi

    # 各辞書ファイルをダウンロード(存在しない場合のみ)
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: dict: ''
      if [ ! -f "$DICT_DIR/${name}" ]; then
        echo "Downloading ${name}..."
        $DRY_RUN_CMD ${pkgs.curl}/bin/curl -L -o "$DICT_DIR/${name}" "${dict.url}"
      else
        echo "${name} already exists, skipping download"
      fi
    '') skkDictionaries)}

    # ユーザー辞書ファイルを作成(存在しない場合のみ)
    if [ ! -f "$DICT_DIR/skk-jisyo.utf8" ]; then
      $DRY_RUN_CMD touch "$DICT_DIR/skk-jisyo.utf8"
    fi
  '';
}
