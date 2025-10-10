#!/bin/bash

# S3 설정 전환 스크립트 (심볼릭 링크)
# 사용법: ./switch-s3.sh

# S3 설정 폴더
S3CFG_DIR="$HOME/s3cfg"

echo "🔄 S3 설정 전환"
echo ""

# 현재 활성 설정 확인
current_config=""
if [ -L ~/.s3cfg ]; then
    current_target=$(readlink ~/.s3cfg)
    current_config=$(basename "$current_target")
    echo "📌 현재 설정: $current_config"
    echo ""
fi

# 설정 파일 목록 가져오기
mapfile -t configs < <(ls "$S3CFG_DIR"/* 2>/dev/null)

if [ ${#configs[@]} -eq 0 ]; then
    echo "❌ 설정된 S3가 없습니다."
    echo ""
    echo "💡 먼저 설정을 생성하세요:"
    echo "   ./setup-s3-config.sh"
    echo ""
    exit 1
fi

# 설정명 추출
mapfile -t config_names < <(printf '%s\n' "${configs[@]}" | xargs -n1 basename)

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

📋 전환 후 사용 예시:

   # 버킷 목록
   s3cmd ls

   # 특정 버킷의 파일 목록
   s3cmd ls s3://bucket-name

   # 파일 다운로드
   s3cmd get s3://bucket/file.txt

   # 파일 업로드
   s3cmd put local.txt s3://bucket/

   # 폴더 동기화
   s3cmd sync ./local/ s3://bucket/remote/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

export -f preview_s3_config

# 설정 선택
selected=$(printf '%s\n' "${config_names[@]}" | fzf \
    --height 90% \
    --prompt="S3 설정> " \
    --header="━━━ 전환할 S3 설정을 선택하세요 ━━━" \
    --preview "preview_s3_config $S3CFG_DIR/{}" \
    --preview-window=right:65%:wrap \
    --bind "ctrl-r:reload(ls $S3CFG_DIR/* 2>/dev/null | xargs -n1 basename)"
)

if [ -z "$selected" ]; then
    echo "종료합니다."
    exit 0
fi

config_file="$S3CFG_DIR/${selected}"

# 선택한 설정이 현재 설정과 같은지 확인
if [[ "$selected" == "$current_config" ]]; then
    echo ""
    echo "ℹ️  이미 '$selected' 설정이 활성화되어 있습니다."
    echo ""
    exit 0
fi

# 기존 .s3cfg 처리
if [ -f ~/.s3cfg ] && [ ! -L ~/.s3cfg ]; then
    # 심볼릭 링크가 아닌 실제 파일인 경우 백업
    backup_file=~/.s3cfg.backup.$(date +%Y%m%d_%H%M%S)
    echo ""
    echo "⚠️  기존 .s3cfg가 일반 파일입니다."
    echo "백업 생성: $backup_file"
    cp ~/.s3cfg "$backup_file"
    rm ~/.s3cfg
fi

# 심볼릭 링크 생성
ln -sf "$config_file" ~/.s3cfg

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 설정 전환 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 활성 설정: $selected"
echo "📁 ~/.s3cfg -> $config_file"
echo ""
echo "💡 사용법:"
echo "   s3cmd ls"
echo "   s3cmd ls s3://bucket-name"
echo ""

# 연결 테스트 제안
read -p "연결 테스트를 하시겠습니까? (y/n): " test_connection

if [[ "$test_connection" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔍 버킷 목록 조회 중..."
    echo ""
    if s3cmd ls 2>&1; then
        echo ""
        echo "✅ 연결 성공!"
    else
        echo ""
        echo "❌ 연결 실패. 설정을 확인하세요."
        echo ""
        echo "설정 확인:"
        echo "   cat $config_file"
    fi
fi

echo ""
