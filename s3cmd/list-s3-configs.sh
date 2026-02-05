#!/usr/bin/env bash

# S3 설정 목록 조회 스크립트
# 사용법: ./list-s3-configs.sh

# S3 설정 폴더
S3CFG_DIR="$HOME/s3cfg"

echo "📋 S3 설정 목록"
echo ""

# 현재 활성 설정 확인
current_config=""
if [ -L ~/.s3cfg ]; then
    current_target=$(readlink ~/.s3cfg)
    current_config=$(basename "$current_target")
fi

# 설정 파일 목록 가져오기
mapfile -t configs < <(ls "$S3CFG_DIR"/* 2>/dev/null)

if [ ${#configs[@]} -eq 0 ]; then
    echo "❌ 설정된 S3가 없습니다."
    echo ""
    echo "💡 먼저 설정을 생성하세요:"
    echo "   ./setup-s3-config.sh"
    echo ""
    exit 0
fi

# Preview 생성 함수
preview_s3_config() {
    local config_file=$1

    if [ ! -f "$config_file" ]; then
        echo "설정 파일을 찾을 수 없습니다."
        return
    fi

    local name=$(basename "$config_file")

    # 파일에서 정보 추출
    local access_key=$(grep "^access_key" "$config_file" | cut -d'=' -f2 | xargs)
    local host_base=$(grep "^host_base" "$config_file" | cut -d'=' -f2 | xargs)
    local use_https=$(grep "^use_https" "$config_file" | cut -d'=' -f2 | xargs)
    local signature_v2=$(grep "^signature_v2" "$config_file" | cut -d'=' -f2 | xargs)

    cat <<EOF
┌─────────────────────────────────┐
│  S3 설정 상세 정보              │
└─────────────────────────────────┘

🏷️  이름: $name

🔐 인증:
   Access Key: ${access_key:0:8}***${access_key: -4}

🌐 엔드포인트:
   Host: $host_base
   HTTPS: $use_https
   Signature v2: $signature_v2

📁 설정 파일:
   $config_file

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  전체 설정 (민감 정보 마스킹):

EOF

    cat "$config_file" | sed 's/secret_key = .*/secret_key = ***/g'

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 사용 예시:"
    echo ""
    echo "   # 이 설정으로 전환"
    echo "   ./switch-s3.sh"
    echo "   (또는 fzf에서 선택)"
    echo ""
    echo "   # 수동 전환"
    echo "   ln -sf $config_file ~/.s3cfg"
    echo ""
    echo "   # 직접 사용 (전환 없이)"
    echo "   s3cmd -c $config_file ls"
    echo ""
}

export -f preview_s3_config

# 설정명 추출
mapfile -t config_names < <(printf '%s\n' "${configs[@]}" | xargs -n1 basename)

# 현재 활성 설정 표시용 포맷
format_config_name() {
    for name in "${config_names[@]}"; do
        if [[ "$name" == "$current_config" ]]; then
            echo "✅ $name (활성)"
        else
            echo "   $name"
        fi
    done
}

# 설정 선택 (fzf)
selected=$(format_config_name | fzf \
    --height 90% \
    --prompt="S3 설정> " \
    --header="━━━ S3 설정 목록 (Ctrl-R: 새로고침) ━━━" \
    --preview "preview_s3_config $S3CFG_DIR/\$(echo {} | sed 's/^[✅ ]*//;s/ (활성)//')" \
    --preview-window=right:70%:wrap \
    --bind "ctrl-r:reload(ls $S3CFG_DIR/* 2>/dev/null | xargs -n1 basename | while read name; do if [[ \"\$name\" == \"$current_config\" ]]; then echo \"✅ \$name (활성)\"; else echo \"   \$name\"; fi; done)"
)

if [ -z "$selected" ]; then
    echo "종료합니다."
    exit 0
fi

# 선택된 설정명 추출
selected_name=$(echo "$selected" | sed 's/^[✅ ]*//;s/ (활성)//')
config_file="$S3CFG_DIR/${selected_name}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 선택된 설정: $selected_name"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 작업 선택
action=$(echo -e "🔄 이 설정으로 전환\n📝 설정 파일 보기\n🗑️  설정 삭제\n❌ 종료" | fzf --height 40% --prompt="작업> ")

case "$action" in
    "🔄 이 설정으로 전환")
        # 이미 활성 설정인지 확인
        if [[ "$selected_name" == "$current_config" ]]; then
            echo ""
            echo "ℹ️  이미 '$selected_name' 설정이 활성화되어 있습니다."
            echo ""
        else
            # 기존 .s3cfg 처리
            if [ -f ~/.s3cfg ] && [ ! -L ~/.s3cfg ]; then
                backup_file=~/.s3cfg.backup.$(date +%Y%m%d_%H%M%S)
                echo ""
                echo "⚠️  기존 .s3cfg 백업: $backup_file"
                cp ~/.s3cfg "$backup_file"
                rm ~/.s3cfg
            fi

            # 심볼릭 링크 생성
            ln -sf "$config_file" ~/.s3cfg

            echo ""
            echo "✅ 설정 전환 완료: $selected_name"
            echo ""
            echo "💡 사용법:"
            echo "   s3cmd ls"
            echo ""
        fi
        ;;
    "📝 설정 파일 보기")
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$config_file" | sed 's/secret_key = .*/secret_key = ***/g'
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        ;;
    "🗑️  설정 삭제")
        echo ""
        read -p "⚠️  정말로 '$selected_name' 설정을 삭제하시겠습니까? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # 활성 설정인 경우 경고
            if [[ "$selected_name" == "$current_config" ]]; then
                echo ""
                echo "⚠️  현재 활성 설정입니다. 삭제 후 .s3cfg 링크가 깨집니다."
                read -p "계속하시겠습니까? (y/n): " confirm2
                if [[ ! "$confirm2" =~ ^[Yy]$ ]]; then
                    echo "취소되었습니다."
                    exit 0
                fi
                rm ~/.s3cfg 2>/dev/null
            fi

            rm "$config_file"
            echo ""
            echo "✅ '$selected_name' 설정이 삭제되었습니다."
            echo ""
        else
            echo "취소되었습니다."
        fi
        ;;
    *)
        echo "종료합니다."
        ;;
esac

echo ""
