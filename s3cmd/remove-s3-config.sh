#!/bin/bash

# S3 설정 삭제 스크립트
# 사용법: ./remove-s3-config.sh

# S3 설정 폴더
S3CFG_DIR="$HOME/s3cfg"

echo "🗑️  S3 설정 삭제"
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

    cat <<EOF
⚠️  삭제할 설정 확인

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷️  이름: $name

🔐 인증:
   Access Key: ${access_key:0:8}***${access_key: -4}

🌐 엔드포인트:
   Host: $host_base

📁 파일:
   $config_file

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  경고:

   이 설정을 삭제하면 복구할 수 없습니다.
   삭제 전에 access_key, secret_key 등
   인증 정보를 별도로 백업하세요.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

export -f preview_s3_config

# 설정명 추출
mapfile -t config_names < <(printf '%s\n' "${configs[@]}" | xargs -n1 basename)

# 현재 활성 설정 표시용 포맷
format_config_name() {
    for name in "${config_names[@]}"; do
        if [[ "$name" == "$current_config" ]]; then
            echo "⚠️  $name (활성 - 주의)"
        else
            echo "   $name"
        fi
    done
}

# 설정 선택 (fzf)
selected=$(format_config_name | fzf \
    --height 80% \
    --prompt="삭제할 설정> " \
    --header="━━━ 삭제할 S3 설정을 선택하세요 (ESC: 취소) ━━━" \
    --preview "preview_s3_config $S3CFG_DIR/\$(echo {} | sed 's/^[⚠️ ]*//;s/ (활성 - 주의)//')" \
    --preview-window=right:60%:wrap
)

if [ -z "$selected" ]; then
    echo "취소되었습니다."
    exit 0
fi

# 선택된 설정명 추출
selected_name=$(echo "$selected" | sed 's/^[⚠️ ]*//;s/ (활성 - 주의)//')
config_file="$S3CFG_DIR/${selected_name}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  설정 삭제 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "삭제할 설정: $selected_name"
echo "파일: $config_file"
echo ""

# 활성 설정인 경우 추가 경고
if [[ "$selected_name" == "$current_config" ]]; then
    echo "⚠️  경고: 이 설정은 현재 활성 설정입니다!"
    echo "         삭제하면 ~/.s3cfg 심볼릭 링크가 깨집니다."
    echo ""
fi

read -p "정말로 삭제하시겠습니까? (y/n): " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "취소되었습니다."
    echo ""
    exit 0
fi

# 활성 설정인 경우 추가 확인
if [[ "$selected_name" == "$current_config" ]]; then
    echo ""
    read -p "활성 설정입니다. 정말 삭제하시겠습니까? (yes 입력): " confirm2
    if [[ "$confirm2" != "yes" ]]; then
        echo ""
        echo "취소되었습니다."
        echo ""
        exit 0
    fi

    # ~/.s3cfg 심볼릭 링크 제거
    rm ~/.s3cfg 2>/dev/null
    echo ""
    echo "ℹ️  ~/.s3cfg 심볼릭 링크를 제거했습니다."
fi

# 백업 제안
echo ""
read -p "삭제 전에 백업하시겠습니까? (y/n): " backup_choice

if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
    backup_file="$S3CFG_DIR/${selected_name}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$config_file" "$backup_file"
    echo ""
    echo "✅ 백업 완료: $backup_file"
fi

# 삭제 실행
rm "$config_file"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 설정 삭제 완료"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "삭제된 설정: $selected_name"
echo ""

# 남은 설정 확인
remaining_configs=($(ls "$S3CFG_DIR"/* 2>/dev/null))

if [ ${#remaining_configs[@]} -eq 0 ]; then
    echo "ℹ️  남은 설정이 없습니다."
    echo ""
else
    echo "📋 남은 설정 (${#remaining_configs[@]}개):"
    printf '%s\n' "${remaining_configs[@]}" | xargs -n1 basename | sed 's/^/   • /'
    echo ""

    # 활성 설정이 삭제된 경우 다른 설정으로 전환 제안
    if [[ "$selected_name" == "$current_config" ]]; then
        echo "💡 다른 설정으로 전환하시겠습니까?"
        echo ""
        read -p "전환하시겠습니까? (y/n): " switch_choice

        if [[ "$switch_choice" =~ ^[Yy]$ ]]; then
            exec ./switch-s3.sh
        fi
    fi
fi

echo ""
