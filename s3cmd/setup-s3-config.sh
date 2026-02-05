#!/usr/bin/env bash

# S3 설정 생성 스크립트
# 사용법: ./setup-s3-config.sh
# 심볼릭 링크 방식으로 .s3cfg 관리

echo "🪣 S3 설정 생성"
echo ""

# Shell RC 파일 감지
detect_shell_rc() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        echo "$HOME/.bashrc"
    else
        echo "$HOME/.profile"
    fi
}

# S3 설정 폴더
S3CFG_DIR="$HOME/s3cfg"

# 1단계: 회사 선택
select_company() {
    # 기존 설정에서 회사명 추출
    mapfile -t existing_companies < <(ls "$S3CFG_DIR"/* 2>/dev/null | xargs -n1 basename | sed 's/\([^-]*\)-.*/\1/' | sort -u)

    local company
    company=$({
        [ ${#existing_companies[@]} -gt 0 ] && printf '%s\n' "${existing_companies[@]}"
        echo "➕ 새 회사 입력"
        echo "❌ 종료"
    } | fzf \
        --height 50% \
        --prompt="회사> " \
        --header="기존 회사 선택 또는 새로 입력" \
        --preview "
            if [[ '{}' == '➕ 새 회사 입력' ]] || [[ '{}' == '❌ 종료' ]]; then
                echo ''
            else
                echo '📊 {} 의 기존 설정:'
                echo ''
                ls $S3CFG_DIR/{}-* 2>/dev/null | xargs -n1 basename | sed 's/^/   • /' || echo '   (없음)'
            fi
        " \
        --preview-window=right:50%:wrap
    )

    if [[ "$company" == "➕ 새 회사 입력" ]]; then
        echo "" >&2
        read -p "회사명 입력: " company
        company=$(echo "$company" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    elif [[ "$company" == "❌ 종료" ]] || [ -z "$company" ]; then
        echo "종료합니다."
        exit 0
    fi

    echo "✓ 회사: $company" >&2
    echo "" >&2
    echo "$company"
}

# 2단계: 환경 선택
select_environment() {
    local company=$1

    # 해당 회사의 기존 환경 추출
    mapfile -t existing_envs < <(ls "$S3CFG_DIR/${company}"-* 2>/dev/null | xargs -n1 basename | sed "s/${company}-\([^-]*\)-.*/\1/" | sort -u)

    local env
    env=$({
        [ ${#existing_envs[@]} -gt 0 ] && printf '%s\n' "${existing_envs[@]}"
        echo "dev"
        echo "staging"
        echo "prod"
        echo "➕ 직접 입력"
        echo "← 이전으로"
    } | sort -u | fzf \
        --height 50% \
        --prompt="환경> " \
        --header="$company 환경 선택" \
        --preview "
            if [[ '{}' == '➕ 직접 입력' ]] || [[ '{}' == '← 이전으로' ]]; then
                echo ''
            else
                echo '📋 $company-{} 의 기존 설정:'
                echo ''
                ls $S3CFG_DIR/$company-{}-* 2>/dev/null | xargs -n1 basename | sed 's/^/   🪣 /' || echo '   (없음)'
            fi
        " \
        --preview-window=right:50%:wrap
    )

    if [[ "$env" == "➕ 직접 입력" ]]; then
        echo "" >&2
        read -p "환경명 입력: " env
        env=$(echo "$env" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    elif [[ "$env" == "← 이전으로" ]] || [ -z "$env" ]; then
        return 1
    fi

    echo "✓ 환경: $env" >&2
    echo "" >&2
    echo "$env"
    return 0
}

# 3단계: 버킷명 입력
input_bucket() {
    echo "📝 버킷 정보 입력" >&2
    echo "" >&2
    read -p "버킷명: " bucket

    if [ -z "$bucket" ]; then
        echo "❌ 버킷명은 필수입니다." >&2
        return 1
    fi

    bucket=$(echo "$bucket" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    echo "$bucket"
    return 0
}

# 4단계: 인증 정보 입력
input_credentials() {
    echo "🔐 인증 정보 입력"
    echo ""

    read -p "Access Key: " access_key
    read -sp "Secret Key: " secret_key
    echo ""
    read -p "Host Base (예: s3.amazonaws.com): " host_base
    echo ""

    # 옵션
    read -p "HTTPS 사용? (y/n, 기본 y): " use_https_input
    use_https=${use_https_input:-y}
    [[ "$use_https" =~ ^[Yy]$ ]] && use_https="True" || use_https="False"

    read -p "Signature v2 사용? (y/n, 기본 y): " sig_v2_input
    signature_v2=${sig_v2_input:-y}
    [[ "$signature_v2" =~ ^[Yy]$ ]] && signature_v2="True" || signature_v2="False"

    echo ""
}

# 5단계: 설정 파일 생성 (미리보기 포함)
create_config() {
    local company=$1
    local env=$2
    local bucket=$3
    local access_key=$4
    local secret_key=$5
    local host_base=$6
    local use_https=$7
    local signature_v2=$8

    # s3cfg 폴더 생성
    mkdir -p "$S3CFG_DIR"

    local config_file="$S3CFG_DIR/${company}-${env}-${bucket}"
    local config_name="${company}-${env}-${bucket}"

    # 중복 체크
    if [ -f "$config_file" ]; then
        echo "⚠️  설정이 이미 존재합니다: $config_name"
        read -p "덮어쓰시겠습니까? (y/n): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo "취소되었습니다."
            return 1
        fi
        echo ""
    fi

    # 설정 내용 미리보기
    local config_preview
    config_preview=$(cat <<EOF
[default]
access_key = ${access_key:0:5}***${access_key: -3}
secret_key = ***
host_base = $host_base
host_bucket = $host_base/%(bucket)
use_https = $use_https
signature_v2 = $signature_v2
recursive = True
human_readable_sizes = True
EOF
    )

    # 확인 단계 (fzf로 예쁘게)
    local action
    action=$(echo -e "✅ 생성\n✏️  다시 입력\n❌ 취소" | fzf \
        --height 70% \
        --prompt="확인> " \
        --header="━━━ 설정을 확인하세요 ━━━" \
        --preview "echo '$config_preview'; echo ''; echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━'; echo ''; echo '📁 파일: $config_file'; echo '🏷️  이름: $config_name'; echo ''; echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━'; echo ''; echo '📋 사용 예시:'; echo ''; echo '   # 심볼릭 링크로 전환'; echo '   switch-s3.sh'; echo '   # 또는'; echo '   ln -sf $config_file ~/.s3cfg'; echo ''; echo '   # s3cmd 사용'; echo '   s3cmd ls s3://$bucket'; echo '   s3cmd get s3://$bucket/file.txt .'; echo '   s3cmd put local.txt s3://$bucket/'" \
        --preview-window=right:60%:wrap
    )

    case "$action" in
        "✅ 생성")
            # 파일 생성
            touch "$config_file"
            chmod 600 "$config_file"

            cat > "$config_file" <<EOF
[default]
access_key = $access_key
secret_key = $secret_key
host_base = $host_base
host_bucket = $host_base/%(bucket)
use_https = $use_https
signature_v2 = $signature_v2
recursive = True
human_readable_sizes = True
EOF

            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "✅ 설정 생성 완료!"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "📁 파일: $config_file"
            echo "🏷️  이름: $config_name"
            echo ""
            echo "💡 다음 단계:"
            echo ""
            echo "   1️⃣ 설정 전환 (권장)"
            echo "      ./switch-s3.sh"
            echo ""
            echo "   2️⃣ 수동 전환"
            echo "      ln -sf $config_file ~/.s3cfg"
            echo ""
            echo "   3️⃣ 사용"
            echo "      s3cmd ls s3://$bucket"
            echo ""

            # 자동 전환 여부 묻기
            read -p "지금 바로 이 설정으로 전환하시겠습니까? (y/n): " switch_now
            if [[ "$switch_now" =~ ^[Yy]$ ]]; then
                # 기존 .s3cfg 백업
                if [ -f ~/.s3cfg ] && [ ! -L ~/.s3cfg ]; then
                    backup_file=~/.s3cfg.backup.$(date +%Y%m%d_%H%M%S)
                    cp ~/.s3cfg "$backup_file"
                    echo ""
                    echo "ℹ️  기존 .s3cfg를 백업했습니다: $backup_file"
                fi

                # 심볼릭 링크 생성
                ln -sf "$config_file" ~/.s3cfg
                echo ""
                echo "✅ 설정이 전환되었습니다!"
                echo ""
                echo "현재 활성 설정: $config_name"
                echo ""
            fi
            ;;
        "✏️  다시 입력")
            echo "다시 입력하세요..."
            return 2
            ;;
        *)
            echo "취소되었습니다."
            exit 0
            ;;
    esac

    return 0
}

# 메인 루프
while true; do
    company=$(select_company)

    while true; do
        env=$(select_environment "$company")
        if [ $? -ne 0 ]; then
            break
        fi

        bucket=$(input_bucket)
        if [ $? -ne 0 ]; then
            continue
        fi

        input_credentials

        create_result=0
        while true; do
            create_config "$company" "$env" "$bucket" "$access_key" "$secret_key" "$host_base" "$use_https" "$signature_v2"
            create_result=$?

            if [ $create_result -eq 0 ]; then
                # 성공
                break
            elif [ $create_result -eq 2 ]; then
                # 다시 입력
                input_credentials
                continue
            else
                # 취소 또는 실패
                break
            fi
        done

        if [ $create_result -eq 0 ]; then
            # 다음 작업
            next=$(echo -e "다시 생성하기\n종료" | fzf --height 40% --prompt="다음> ")

            if [[ "$next" == "종료" ]] || [ -z "$next" ]; then
                exit 0
            else
                break 2
            fi
        else
            break
        fi
    done
done
