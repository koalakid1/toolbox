#!/usr/bin/env bash

# GitHub 계정 설정 자동화 스크립트
# SSH 키, GPG 키, Git 설정을 자동으로 생성합니다.

echo "🚀 GitHub 계정 설정 자동화"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 0. 필수 도구 체크
echo "🔍 필수 도구 확인 중..."

if ! command -v ssh-keygen &> /dev/null || ! command -v gpg &> /dev/null || ! command -v git &> /dev/null; then
    echo ""
    echo "❌ 필수 도구가 설치되지 않았습니다!"
    echo ""
    echo "다음 명령어로 필수 도구를 먼저 설치하세요:"
    echo "   ./install-required-tools.sh"
    echo ""
    exit 1
fi

echo "✅ 모든 필수 도구가 설치되어 있습니다."
echo ""

# 1. 기존 계정 목록 확인
github_base="$HOME/github"
mkdir -p "$github_base"

echo "🔍 기존 계정 확인 중..."
mapfile -t existing_accounts < <(find "$github_base" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)

if [ ${#existing_accounts[@]} -gt 0 ]; then
    echo "✓ 기존 계정 발견: ${#existing_accounts[@]}개"
    for acc in "${existing_accounts[@]}"; do
        if [ -f "$HOME/.gitconfig-$acc" ]; then
            email=$(grep "email" "$HOME/.gitconfig-$acc" | head -1 | sed 's/.*= //' | tr -d '\t')
            echo "  - $acc ($email)"
        else
            echo "  - $acc"
        fi
    done
else
    echo "ℹ️  기존 계정 없음"
fi
echo ""

# 2. 작업 선택
echo "작업을 선택하세요:"
action=$(echo -e "신규 계정 생성\n기존 계정 관리\n종료" | fzf --height 40% --prompt="작업> ")

if [ -z "$action" ] || [[ "$action" == "종료" ]]; then
    echo "종료합니다."
    exit 0
fi

if [[ "$action" == "기존 계정 관리" ]]; then
    if [ ${#existing_accounts[@]} -eq 0 ]; then
        echo "❌ 관리할 계정이 없습니다."
        exit 1
    fi

    # 계정 선택
    selected_account=$(printf '%s\n' "${existing_accounts[@]}" | fzf --height 40% --prompt="계정> ")

    if [ -z "$selected_account" ]; then
        echo "취소되었습니다."
        exit 0
    fi

    username="$selected_account"

    # 기존 정보 로드
    ssh_key_path="$HOME/.ssh/id_ed25519_$username"
    gitconfig_file="$HOME/.gitconfig-$username"
    github_dir="$HOME/github/$username"

    # Git config에서 정보 읽기
    if [ -f "$gitconfig_file" ]; then
        email=$(grep "email" "$gitconfig_file" | head -1 | sed 's/.*= //' | tr -d '\t')
        fullname=$(grep "name" "$gitconfig_file" | head -1 | sed 's/.*= //' | tr -d '\t')
    else
        email=""
        fullname=""
    fi

    # 관리 메뉴
    echo ""
    echo "=== 계정: $username ==="
    if [ -n "$email" ]; then
        echo "이메일: $email"
    fi
    if [ -n "$fullname" ]; then
        echo "이름: $fullname"
    fi
    echo ""

    manage_action=$(echo -e "기존 설정 보기\n공개키 다시 출력 (GitHub 재등록용)\n설정 덮어쓰기 (재생성)\n취소" | fzf --height 40% --prompt="작업> ")

    if [ -z "$manage_action" ] || [[ "$manage_action" == "취소" ]]; then
        echo "취소되었습니다."
        exit 0
    fi

    if [[ "$manage_action" == "기존 설정 보기" ]]; then
        echo ""
        echo "=== 기존 설정 ==="
        echo "SSH 키: $ssh_key_path"

        # GPG 키 확인
        if [ -n "$email" ]; then
            gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep "sec" | head -1 | sed 's|.*/\([^ ]*\) .*|\1|')
            if [ -n "$gpg_key_id" ]; then
                echo "GPG 키: $gpg_key_id"
            fi
        fi

        echo "Git config: $gitconfig_file"
        echo "디렉토리: $github_dir"
        echo ""

        if [ -f "$gitconfig_file" ]; then
            echo "=== Git Config 내용 ==="
            cat "$gitconfig_file"
        fi
        exit 0
    fi

    if [[ "$manage_action" == "공개키 다시 출력 (GitHub 재등록용)" ]]; then
        echo ""

        if [ -f "$ssh_key_path.pub" ]; then
            echo "=== SSH 공개키 ==="
            cat "$ssh_key_path.pub"
            echo ""
            echo ""
        else
            echo "❌ SSH 공개키를 찾을 수 없습니다: $ssh_key_path.pub"
            echo ""
        fi

        if [ -n "$email" ]; then
            gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep "sec" | head -1 | sed 's|.*/\([^ ]*\) .*|\1|')
            if [ -n "$gpg_key_id" ]; then
                echo "=== GPG 공개키 ==="
                gpg --armor --export "$gpg_key_id"
                echo ""
                echo ""
            else
                echo "❌ GPG 키를 찾을 수 없습니다 (이메일: $email)"
                echo ""
            fi
        fi

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "위 키들을 GitHub에 등록하세요:"
        echo "https://github.com/settings/keys"
        exit 0
    fi

    if [[ "$manage_action" == "설정 덮어쓰기 (재생성)" ]]; then
        echo ""
        echo "⚠️  경고: 기존 키와 설정을 삭제하고 재생성합니다."

        read -p "정말 계속하시겠습니까? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "취소되었습니다."
            exit 0
        fi

        # 정보가 없으면 다시 입력받기
        if [ -z "$email" ]; then
            read -p "GitHub 이메일 (예: user@example.com): " email
            if [ -z "$email" ]; then
                echo "❌ 이메일은 필수입니다."
                exit 1
            fi
        fi

        if [ -z "$fullname" ]; then
            read -p "실제 이름 (예: John Doe): " fullname
            if [ -z "$fullname" ]; then
                echo "❌ 이름은 필수입니다."
                exit 1
            fi
        fi

        # 재생성 플로우로 진행 (아래에서 계속)
    fi
else
    # 신규 계정 생성
    echo ""
    echo "📝 새 계정 정보를 입력하세요:"
    echo ""

    read -p "GitHub 사용자명 (예: koalakid1): " username
    if [ -z "$username" ]; then
        echo "❌ 사용자명은 필수입니다."
        exit 1
    fi

    read -p "GitHub 이메일 (예: user@example.com): " email
    if [ -z "$email" ]; then
        echo "❌ 이메일은 필수입니다."
        exit 1
    fi

    read -p "실제 이름 (예: John Doe): " fullname
    if [ -z "$fullname" ]; then
        echo "❌ 이름은 필수입니다."
        exit 1
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "입력된 정보:"
echo "  GitHub 사용자명: $username"
echo "  이메일: $email"
echo "  이름: $fullname"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 3. 기존 설정 검증
echo "🔍 기존 설정 확인 중..."
echo ""

# 변수 초기화
ssh_key_path="$HOME/.ssh/id_ed25519_$username"
gitconfig_file="$HOME/.gitconfig-$username"
github_dir="$HOME/github/$username"

ssh_exists=false
gpg_exists=false
gitconfig_exists=false
dir_exists=false
gpg_key_id=""

# SSH 키 체크
if [ -f "$ssh_key_path" ]; then
    ssh_exists=true
    echo "✓ SSH 키 발견: $ssh_key_path"
fi

# GPG 키 체크 (이메일 기준)
gpg_search=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null)
if [ -n "$gpg_search" ]; then
    gpg_exists=true
    gpg_key_id=$(echo "$gpg_search" | grep "sec" | head -1 | sed 's|.*/\([^ ]*\) .*|\1|')
    echo "✓ GPG 키 발견: $gpg_key_id (이메일: $email)"
fi

# Git config 체크
if [ -f "$gitconfig_file" ]; then
    gitconfig_exists=true
    echo "✓ Git config 파일 발견: $gitconfig_file"
fi

# 디렉토리 체크
if [ -d "$github_dir" ]; then
    dir_exists=true
    echo "✓ 디렉토리 발견: $github_dir"
fi

echo ""

# 4. 확인
if [ "$action" != "기존 계정 관리" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -p "위 정보로 설정을 진행하시겠습니까? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "취소되었습니다."
        exit 0
    fi
    echo ""
fi

# 5. 디렉토리 생성
if [ "$dir_exists" = false ]; then
    echo "📁 디렉토리 생성 중..."
    mkdir -p "$github_dir"
    echo "✅ $github_dir 생성 완료"
else
    echo "ℹ️  디렉토리가 이미 존재합니다: $github_dir"
fi
echo ""

# 6. SSH 키 생성/확인
if [ "$ssh_exists" = true ] && [ "$action" != "기존 계정 관리" ]; then
    echo "ℹ️  SSH 키가 이미 존재합니다: $ssh_key_path"
    echo ""

    regenerate_ssh=$(echo -e "기존 SSH 키 사용\nSSH 키 재생성" | fzf --height 40% --prompt="SSH 키> ")

    if [[ "$regenerate_ssh" == "SSH 키 재생성" ]]; then
        echo "🔑 기존 SSH 키 백업 중..."
        mv "$ssh_key_path" "$ssh_key_path.backup.$(date +%s)"
        mv "$ssh_key_path.pub" "$ssh_key_path.pub.backup.$(date +%s)"

        echo "🔑 SSH 키 재생성 중..."
        ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path" -N ""

        if [ $? -eq 0 ]; then
            echo "✅ SSH 키 재생성 완료: $ssh_key_path"
        else
            echo "❌ SSH 키 생성 실패"
            exit 1
        fi
    else
        echo "✅ 기존 SSH 키 사용"
    fi
else
    if [ "$ssh_exists" = false ] || [ "$action" = "기존 계정 관리" ]; then
        echo "🔑 SSH 키 생성 중..."
        ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path" -N ""

        if [ $? -eq 0 ]; then
            echo "✅ SSH 키 생성 완료: $ssh_key_path"
        else
            echo "❌ SSH 키 생성 실패"
            exit 1
        fi
    fi
fi
echo ""

# 7. SSH config 업데이트
ssh_config="$HOME/.ssh/config"

echo "⚙️  SSH config 업데이트 중..."

# SSH config가 없으면 생성
touch "$ssh_config"
chmod 600 "$ssh_config"

# 이미 설정이 있는지 확인
if grep -q "Host github-$username" "$ssh_config"; then
    if [ "$action" != "기존 계정 관리" ]; then
        echo "ℹ️  SSH config에 이미 '$username' 설정이 존재합니다."
        echo ""

        update_ssh=$(echo -e "기존 설정 유지\nSSH config 업데이트" | fzf --height 40% --prompt="SSH config> ")

        if [[ "$update_ssh" == "SSH config 업데이트" ]]; then
            # 기존 설정 제거
            sed -i.backup "/# GitHub - $username account/,/IdentitiesOnly yes/d" "$ssh_config"

            # 새 설정 추가
            cat >> "$ssh_config" << EOF

# GitHub - $username account
Host github-$username
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_$username
    IdentitiesOnly yes
EOF
            echo "✅ SSH config 업데이트 완료"
        else
            echo "✅ 기존 SSH config 유지"
        fi
    else
        # 기존 계정 관리에서는 무조건 업데이트
        sed -i.backup "/# GitHub - $username account/,/IdentitiesOnly yes/d" "$ssh_config"
        cat >> "$ssh_config" << EOF

# GitHub - $username account
Host github-$username
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_$username
    IdentitiesOnly yes
EOF
        echo "✅ SSH config 업데이트 완료"
    fi
else
    cat >> "$ssh_config" << EOF

# GitHub - $username account
Host github-$username
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_$username
    IdentitiesOnly yes
EOF
    echo "✅ SSH config 추가 완료"
fi
echo ""

# 8. GPG 키 생성/확인
if [ "$gpg_exists" = true ] && [ "$action" != "기존 계정 관리" ]; then
    echo "ℹ️  GPG 키가 이미 존재합니다: $gpg_key_id (이메일: $email)"
    echo ""

    regenerate_gpg=$(echo -e "기존 GPG 키 사용\nGPG 키 재생성" | fzf --height 40% --prompt="GPG 키> ")

    if [[ "$regenerate_gpg" == "GPG 키 재생성" ]]; then
        echo ""
        echo "⚠️  경고: 기존 GPG 키를 삭제하면 이전에 서명한 커밋을 검증할 수 없게 됩니다."
        read -p "정말 삭제하고 재생성하시겠습니까? (yes/no): " confirm_gpg_delete

        if [ "$confirm_gpg_delete" = "yes" ]; then
            echo "🔐 기존 GPG 키 삭제 중..."
            gpg --batch --yes --delete-secret-keys "$gpg_key_id" 2>/dev/null
            gpg --batch --yes --delete-keys "$gpg_key_id" 2>/dev/null

            echo "🔐 GPG 키 생성 중... (약 30초 소요)"
            gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $fullname
Name-Email: $email
Expire-Date: 2y
%commit
EOF

            if [ $? -eq 0 ]; then
                echo "✅ GPG 키 생성 완료"
                gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep "sec" | head -1 | sed 's|.*/\([^ ]*\) .*|\1|')
            else
                echo "❌ GPG 키 생성 실패"
                exit 1
            fi
        else
            echo "✅ 기존 GPG 키 유지"
        fi
    else
        echo "✅ 기존 GPG 키 사용"
    fi
else
    if [ "$gpg_exists" = false ] || [ "$action" = "기존 계정 관리" ]; then
        echo "🔐 GPG 키 생성 중... (약 30초 소요)"

        gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $fullname
Name-Email: $email
Expire-Date: 2y
%commit
EOF

        if [ $? -eq 0 ]; then
            echo "✅ GPG 키 생성 완료"
            gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep "sec" | head -1 | sed 's|.*/\([^ ]*\) .*|\1|')
        else
            echo "❌ GPG 키 생성 실패"
            exit 1
        fi
    fi
fi

echo "  GPG Key ID: $gpg_key_id"
echo ""

# 9. Git config 파일 생성
echo "⚙️  Git config 생성 중..."

if [ "$gitconfig_exists" = true ] && [ "$action" != "기존 계정 관리" ]; then
    echo "ℹ️  Git config 파일이 이미 존재합니다: $gitconfig_file"
    echo ""

    overwrite_git=$(echo -e "기존 설정 유지\nGit config 덮어쓰기" | fzf --height 40% --prompt="Git config> ")

    if [[ "$overwrite_git" == "기존 설정 유지" ]]; then
        echo "✅ 기존 Git config 유지"
        echo ""
    else
        cat > "$gitconfig_file" << EOF
[user]
	name = $fullname
	email = $email
	signingkey = $gpg_key_id
[commit]
	gpgSign = true
[url "git@github-$username:"]
	insteadOf = git@github.com:
EOF
        echo "✅ Git config 덮어쓰기 완료: $gitconfig_file"
        echo ""
    fi
else
    cat > "$gitconfig_file" << EOF
[user]
	name = $fullname
	email = $email
	signingkey = $gpg_key_id
[commit]
	gpgSign = true
[url "git@github-$username:"]
	insteadOf = git@github.com:
EOF
    echo "✅ Git config 생성 완료: $gitconfig_file"
    echo ""
fi

# 10. 전역 .gitconfig 업데이트
main_gitconfig="$HOME/.gitconfig"

echo "⚙️  전역 Git config 업데이트 중..."

# .gitconfig가 없으면 생성
if [ ! -f "$main_gitconfig" ]; then
    cat > "$main_gitconfig" << EOF
[core]
	autocrlf = input
[gpg]
	program = gpg
EOF
fi

# includeIf 섹션이 있는지 확인
if grep -q "\[includeIf \"gitdir:~/github/$username/\"\]" "$main_gitconfig"; then
    echo "ℹ️  전역 Git config에 이미 '$username' 설정이 존재합니다."
else
    cat >> "$main_gitconfig" << EOF

# $username account
[includeIf "gitdir:~/github/$username/"]
	path = ~/.gitconfig-$username
EOF
    echo "✅ 전역 Git config 업데이트 완료"
fi
echo ""

# 11. 설정 확인
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 계정 설정 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 설정 요약:"
echo "  GitHub 사용자명: $username"
echo "  이메일: $email"
echo "  이름: $fullname"
echo "  SSH 키: $ssh_key_path"
echo "  GPG 키 ID: $gpg_key_id"
echo "  Git config: $gitconfig_file"
echo "  디렉토리: $github_dir"
echo ""

# 12. SSH/GPG 연결 테스트
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 연결 테스트"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

test_choice=$(echo -e "SSH 연결 테스트\nGPG 서명 테스트\n건너뛰기" | fzf --height 40% --prompt="테스트> ")

if [[ "$test_choice" == "SSH 연결 테스트" ]]; then
    echo ""
    echo "SSH 테스트 중... (GitHub에 SSH 키가 등록되어 있어야 합니다)"
    ssh -T git@github-$username
    echo ""
fi

if [[ "$test_choice" == "GPG 서명 테스트" ]]; then
    echo ""
    echo "GPG 테스트 중..."
    echo "test" | gpg --clearsign
    if [ $? -eq 0 ]; then
        echo "✅ GPG 서명 테스트 성공!"
    else
        echo "❌ GPG 서명 테스트 실패"
    fi
    echo ""
fi

# 13. 다음 단계 안내
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 다음 단계:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  SSH 공개키를 GitHub에 등록하세요:"
echo "   https://github.com/settings/keys"
echo ""
echo "=== SSH 공개키 ==="
cat "$ssh_key_path.pub"
echo ""
echo ""
echo "2️⃣  GPG 공개키를 GitHub에 등록하세요:"
echo "   https://github.com/settings/keys"
echo ""
echo "=== GPG 공개키 ==="
gpg --armor --export "$gpg_key_id"
echo ""
echo ""
echo "3️⃣  GitHub CLI에 로그인하세요:"
echo "   gh auth login"
echo ""
echo "4️⃣  레포지토리 클론 스크립트 실행:"
echo "   cd ~/github"
echo "   ./clone-repo.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Tip: 공개키를 클립보드에 복사하려면:"
echo "   cat $ssh_key_path.pub | xclip -selection clipboard"
echo "   gpg --armor --export $gpg_key_id | xclip -selection clipboard"
echo ""
