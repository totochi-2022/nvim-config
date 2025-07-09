# WSLのディストリビューション名を取得する関数
function get_wsl_distro
    if set -q WSL_DISTRO_NAME
        echo $WSL_DISTRO_NAME
    else
        echo "Ubuntu" # フォールバック値
    end
end

function win2wsl
    set -l path $argv[1]
    set -l strict false
    if test (count $argv) -gt 1
        set strict $argv[2]
    end

    # スラッシュをすべて/に統一（入力の正規化）
    set -l normalized_path (string replace -a '\\' '/' -- $path)

    # wsl.localhostパターンの処理
    set -l distro (get_wsl_distro)
    if string match -q "*/wsl.localhost/$distro/*" -- $normalized_path
        set converted (string replace -r ".*/wsl\.localhost/$distro" "" -- $normalized_path)
        if test "$strict" = "true"; and not test -e "$converted"
            return 1
        end
        echo $converted
        return 0
    end

    # 通常のマウントポイントとの照合
    for mount in $WSL_MOUNTS
        set -l win_path (string split ':' $mount)[1]
        set -l wsl_path (string split ':' $mount)[2]

        # Windowsパスの正規化（バックスラッシュ→スラッシュ）
        set -l normalized_win_path (string replace -a '\\' '/' -- $win_path)
        set normalized_win_path (string escape --style=regex "$normalized_win_path")

        if string match -rq "^$normalized_win_path" -- $normalized_path
            set converted (string replace -r "^$normalized_win_path" "$wsl_path" -- $normalized_path)
            if test "$strict" = "true"; and not test -e "$converted"
                return 1
            end
            echo $converted
            return 0
        end
    end

    # そのまま返す（変換できない場合）
    echo $path
end

function wsl2win
    set -l wsl_path $argv[1]
    set -l distro (get_wsl_distro)

    # /mntで始まるパスの処理（マウントポイント）
    if string match -q "/mnt/*" -- $wsl_path
        for mount in $WSL_MOUNTS
            set -l win_path (string split ':' $mount)[1]
            set -l wsl_path_mount (string split ':' $mount)[2]

            if string match -q "$wsl_path_mount*" -- $wsl_path
                set converted (string replace "$wsl_path_mount" "$win_path" -- $wsl_path)
                echo $converted | string replace -a "/" "\\"
                return 0
            end
        end
    end

    # その他のWSLパス
    echo "\\\\wsl.localhost\\$distro$wsl_path" | string replace -a "/" "\\"
end

# WSL → Windows
wsl2win "/etc/lynx"              # → \\wsl.localhost\Ubuntu_mv\etc\lynx
wsl2win "~/projects/test.txt"    # → \\wsl.localhost\Ubuntu_mv\home\user\projects\test.txt

# Windows → WSL





