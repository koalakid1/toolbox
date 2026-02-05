#!/usr/bin/env bash

# iTerm2 SSH Profile 자동 생성 스크립트
# 사용법: ./setup-ssh-profile.sh

set -euo pipefail

echo "========================================"
echo "iTerm2 SSH Profile 자동 생성"
echo "========================================"
echo ""

# 1. 기본 정보 입력
echo "1/5. SSH 접속 정보 입력"
echo "-------------------"
read -p "서버 주소 (host 또는 IP): " server
read -p "사용자명: " username
read -p "포트 (기본값 22): " port
port=${port:-22}
read -p "Profile 이름 (예: production-server): " profile_name

if [ -z "$server" ] || [ -z "$username" ] || [ -z "$profile_name" ]; then
    echo "❌ 필수 정보를 모두 입력해주세요."
    exit 1
fi

echo ""
echo "2/5. 인증 방식 선택"
echo "-------------------"
auth_type=$(echo -e "Password (비밀번호)\nPEM Key (키 파일)" | fzf --height 40% --prompt="인증 방식> ")

if [ -z "$auth_type" ]; then
    echo "❌ 취소되었습니다."
    exit 0
fi

# 스크립트 저장 경로
script_dir="$HOME/.iterm2-ssh-scripts"
mkdir -p "$script_dir"

# 3. 인증 방식별 처리
if [[ "$auth_type" == "Password"* ]]; then
    echo ""
    echo "3/5. 비밀번호 입력"
    echo "-------------------"
    read -s -p "비밀번호: " password
    echo ""

    # expect 스크립트 생성
    script_file="$script_dir/$profile_name.sh"
    cat > "$script_file" <<EOF
#!/usr/bin/expect -f
set timeout 30
spawn ssh -p $port $username@$server
expect {
    "password:" {
        send "$password\r"
        interact
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof {
        exit
    }
    timeout {
        puts "Connection timed out"
        exit 1
    }
}
EOF

    command_line="$script_file"

elif [[ "$auth_type" == "PEM Key"* ]]; then
    echo ""
    echo "3/5. PEM Key 경로 입력"
    echo "-------------------"
    read -p "Key 파일 경로 (예: ~/.ssh/my-key.pem): " key_path

    # 경로 확장
    key_path="${key_path/#\~/$HOME}"

    if [ ! -f "$key_path" ]; then
        echo "❌ Key 파일을 찾을 수 없습니다: $key_path"
        exit 1
    fi

    # expect 스크립트 생성 (비밀번호가 있는 경우)
    echo ""
    read -p "Key 파일에 비밀번호가 있나요? (y/N): " has_keypass

    if [[ "$has_keypass" =~ ^[Yy]$ ]]; then
        read -s -p "Key 비밀번호: " key_password
        echo ""

        script_file="$script_dir/$profile_name.sh"
        cat > "$script_file" <<EOF
#!/usr/bin/expect -f
set timeout 30
spawn ssh -p $port -i $key_path $username@$server
expect {
    "Enter passphrase" {
        send "$key_password\r"
        expect {
            "password:" {
                send "$key_password\r"
                interact
            }
            eof {
                exit
            }
        }
    }
    "password:" {
        send "$key_password\r"
        interact
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof {
        exit
    }
    timeout {
        puts "Connection timed out"
        exit 1
    }
}
EOF
    else
        # 키 비밀번호 없음
        script_file="$script_dir/$profile_name.sh"
        cat > "$script_file" <<'SCRIPT'
#!/usr/local/bin/bash
ssh -p PORT -i KEY_PATH USERNAME@SERVER
SCRIPT
        # 변수 치환
        sed -i.bak "s|PORT|$port|g" "$script_file"
        sed -i.bak "s|KEY_PATH|$key_path|g" "$script_file"
        sed -i.bak "s|USERNAME|$username|g" "$script_file"
        sed -i.bak "s|SERVER|$server|g" "$script_file"
        rm -f "${script_file}.bak"
    fi

    command_line="$script_file"
fi

# 실행 권한 부여
chmod +x "$script_file"

echo ""
echo "4/5. iTerm2 Dynamic Profile 생성"
echo "-------------------"

# iTerm2 Profiles 경로
iterm_profile_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$iterm_profile_dir"

profile_file="$iterm_profile_dir/SSH Profiles.json"

# 고유한 GUID 생성 (macOS uuidgen 사용)
generate_guid() {
    if command -v uuidgen &> /dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    else
        # fallback: 랜덤 문자열 생성
        printf "%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n" $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM
    fi
}

# 기존 프로필 파일이 있는지 확인
if [ -f "$profile_file" ]; then
    # 기존 파일에 추가
    temp_file=$(mktemp)
    new_guid=$(generate_guid)
    jq ".Profiles += [{
        \"Guid\": \"$new_guid\",
        \"Name\": \"$profile_name\",
        \"Command\": \"$script_file\",
        \"Custom Command\": \"Yes\"
    }]" "$profile_file" > "$temp_file"
    mv "$temp_file" "$profile_file"
else
    # 새 파일 생성
    new_guid=$(generate_guid)
    cat > "$profile_file" <<EOF
{
  "Profiles": [
    {
      "Guid": "$new_guid",
      "Name": "$profile_name",
      "Command": "$script_file",
      "Custom Command": "Yes"
    }
  ]
}
EOF
fi

echo ""
echo "5/5. 완료"
echo "-------------------"
echo ""
echo "✅ Profile이 생성되었습니다!"
echo ""
echo "Profile 정보:"
echo "  이름: $profile_name"
echo "  호스트: $username@$server:$port"
echo "  명령: $script_file"
echo ""
echo "사용 방법:"
echo "  1. iTerm2 재시작 (⌘+Q 후 다시 실행)"
echo "  2. ⌘+Shift+P 또는 메뉴 > Profiles > $profile_name 선택"
echo ""
echo "생성된 파일:"
echo "  스크립트: $script_file"
echo "  프로필: $profile_file"
echo ""
