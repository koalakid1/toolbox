#!/usr/bin/env bash

# GitHub 대화형 클론 스크립트
# 사용법: ./clone-repo.sh
# 크로스 플랫폼 지원 (Linux/Mac/Windows Git Bash)

echo "🚀 GitHub 레포지토리 클론"
echo ""

while true; do
    # 1. ~/github/ 폴더의 디렉토리 목록 가져오기
    github_base="$HOME/github"

    # github 폴더가 없으면 생성
    if [ ! -d "$github_base" ]; then
        mkdir -p "$github_base"
        echo "📁 $github_base 폴더를 생성했습니다."
        echo ""
    fi

    # 계정 목록 가져오기 (디렉토리만)
    mapfile -t accounts < <(find "$github_base" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)

    if [ ${#accounts[@]} -eq 0 ]; then
        echo "❌ $github_base 폴더에 계정이 없습니다."
        echo ""
        echo "💡 먼저 계정 폴더를 생성하세요:"
        echo "   mkdir -p ~/github/your-username"
        echo ""
        exit 1
    fi

    # 계정 선택
    account_name=$({ printf '%s\n' "${accounts[@]}"; echo "❌ 종료"; } | fzf --height 40% --prompt="계정> ")

    if [ -z "$account_name" ] || [[ "$account_name" == "❌ 종료" ]]; then
        echo "종료합니다."
        exit 0
    fi

    base_dir="$github_base/$account_name"

    # 계정 정보 표시 (gitconfig 파일에서 읽기)
    account_email=""
    account_full_name=""

    if [ -f "$HOME/.gitconfig-$account_name" ]; then
        account_email=$(grep "email" "$HOME/.gitconfig-$account_name" | head -1 | sed 's/.*= //' | tr -d '\t')
        account_full_name=$(grep "name" "$HOME/.gitconfig-$account_name" | head -1 | sed 's/.*= //' | tr -d '\t')
    fi

    echo "✓ 선택된 계정: $account_name"
    if [ -n "$account_email" ]; then
        echo "  이메일: $account_email"
    fi
    if [ -n "$account_full_name" ]; then
        echo "  이름: $account_full_name"
    fi
    echo ""

    echo "🔄 $account_name 계정으로 전환 시도 중..."

    # 선택한 계정으로 gh auth switch 시도
    if gh auth switch -h github.com -u "$account_name" 2>/dev/null; then
        echo "✅ 계정 전환 완료!"
    else
        echo "ℹ️  계정 전환 실패 (계정이 등록되지 않았거나 이미 활성화됨)"
    fi
    echo ""

    # 현재 활성화된 GitHub username 가져오기
    github_username=$(gh api user --jq '.login' 2>/dev/null)

    if [ -z "$github_username" ]; then
        echo "❌ GitHub CLI 인증이 필요합니다."
        echo "다음 명령어로 '$account_name' 계정을 등록하세요:"
        echo "   gh auth login"
        echo ""
        read -p "Enter를 눌러 계속..."
        continue
    fi

    echo "✓ 활성화된 GitHub 계정: $github_username"

    # 선택한 계정과 실제 로그인 계정이 다른지 확인
    if [[ "$account_name" != "$github_username" ]]; then
        echo ""
        echo "⚠️  경고: 선택한 계정과 활성화된 계정이 다릅니다!"
        echo "   선택: $account_name"
        echo "   활성화: $github_username"
        echo ""
        echo "   '$github_username' 계정의 레포지토리가 표시됩니다."
        echo ""
        read -p "계속하시겠습니까? (y/N): " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            echo ""
            echo "💡 Tip: '$account_name' 계정을 먼저 등록하세요:"
            echo "   gh auth login"
            echo ""
            continue
        fi
    fi
    echo ""

    while true; do
        # 2. 소유자 타입 선택 (개인/조직)
        repo_type=$(echo -e "내 레포지토리\n조직 레포지토리\n← 이전으로 (계정 선택)" | fzf --height 40% --prompt="타입> ")

        if [ -z "$repo_type" ]; then
            echo "종료합니다."
            exit 0
        fi

        if [[ "$repo_type" == "← 이전으로"* ]]; then
            echo ""
            break  # 계정 선택으로 돌아가기
        fi

        echo "✓ 선택: $repo_type"
        echo ""

        # 3. 레포 목록 가져오기
        if [ "$repo_type" = "내 레포지토리" ]; then
            echo "📋 레포지토리 목록을 가져오는 중..."
            mapfile -t repos < <(gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner')
            selected_org=""
        else
            while true; do
                # 조직 목록 먼저 선택
                echo "📋 조직 목록을 가져오는 중..."
                mapfile -t orgs < <(gh api user/orgs --jq '.[].login')

                if [ ${#orgs[@]} -eq 0 ]; then
                    echo "❌ 조직을 찾을 수 없습니다."
                    read -p "Enter를 눌러 계속..."
                    break
                fi

                # 조직 목록에 이전으로 추가
                selected_org=$({ printf '%s\n' "${orgs[@]}"; echo "← 이전으로 (타입 선택)"; } | fzf --height 40% --prompt="조직> ")

                if [ -z "$selected_org" ]; then
                    echo "종료합니다."
                    exit 0
                fi

                if [[ "$selected_org" == "← 이전으로"* ]]; then
                    echo ""
                    break  # 타입 선택으로 돌아가기
                fi

                echo "✓ 선택된 조직: $selected_org"
                echo ""
                echo "📋 $selected_org 의 레포지토리 목록을 가져오는 중..."
                mapfile -t repos < <(gh repo list "$selected_org" --limit 1000 --json nameWithOwner -q '.[].nameWithOwner')
                break
            done

            # 이전으로 선택했으면 타입 선택으로
            if [[ "$selected_org" == "← 이전으로"* ]]; then
                continue
            fi
        fi

        if [ ${#repos[@]} -eq 0 ]; then
            echo "❌ 레포지토리를 찾을 수 없습니다."
            read -p "Enter를 눌러 계속..."
            continue
        fi

        # 4. 이미 클론된 레포 필터링
        mkdir -p "$base_dir"
        available_repos=()

        for repo in "${repos[@]}"; do
            # owner/repo 형식에서 분리
            owner=$(echo "$repo" | cut -d'/' -f1)
            repo_name=$(basename "$repo")

            # 개인 레포 vs 조직 레포 구분
            if [ "$owner" = "$github_username" ]; then
                # 개인 레포: ~/github/koalakid1/repo
                local_path="$base_dir/$repo_name"
            else
                # 조직 레포: ~/github/koalakid1/조직명/repo
                local_path="$base_dir/$owner/$repo_name"
            fi

            # 로컬에 없는 레포만 추가
            if [ ! -d "$local_path" ]; then
                available_repos+=("$repo")
            fi
        done

        if [ ${#available_repos[@]} -eq 0 ]; then
            echo "✅ 모든 레포지토리가 이미 클론되어 있습니다!"
            read -p "Enter를 눌러 계속..."
            continue
        fi

        echo "✓ 클론 가능한 레포지토리: ${#available_repos[@]}개"
        echo ""

        while true; do
            # 5. 클론 방식 선택
            clone_mode=$(echo -e "전체 클론 (${#available_repos[@]}개)\n선택적 클론 (직접 선택)\n← 이전으로" | fzf --height 40% --prompt="방식> ")

            if [ -z "$clone_mode" ]; then
                echo "종료합니다."
                exit 0
            fi

            if [[ "$clone_mode" == "← 이전으로"* ]]; then
                echo ""
                if [ "$repo_type" = "조직 레포지토리" ]; then
                    # 조직 선택으로 돌아가기
                    break 2
                else
                    # 타입 선택으로 돌아가기
                    break 2
                fi
            fi

            # 6. 레포 선택
            declare -a selected_repos

            if [[ "$clone_mode" == "전체 클론"* ]]; then
                # 전체 클론: available_repos 전체 사용
                selected_repos=("${available_repos[@]}")
                echo "✓ 전체 레포지토리 클론: ${#selected_repos[@]}개"
            else
                # 선택적 클론: fzf로 다중 선택
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "📌 다중 선택 방법:"
                echo "   • Tab 키: 선택/해제 (앞에 > 표시됨)"
                echo "   • 화살표: 위/아래 이동"
                echo "   • Enter: 선택 확정"
                echo "   • ESC: 이전으로 돌아가기"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                mapfile -t selected_repos < <(printf '%s\n' "${available_repos[@]}" | fzf -m --height 60% --prompt="▶ 레포지토리 (Tab=선택)> " --header="Tab으로 선택 | Enter로 확정 | ESC로 뒤로가기" --preview "gh repo view {} 2>/dev/null")

                if [ ${#selected_repos[@]} -eq 0 ]; then
                    echo "선택이 취소되었습니다. 이전 단계로 돌아갑니다."
                    echo ""
                    continue
                fi

                echo "✓ 선택된 레포: ${#selected_repos[@]}개"
            fi

            echo ""

            # 확인 메시지
            if [ ${#selected_repos[@]} -gt 5 ]; then
                echo "⚠️  ${#selected_repos[@]}개의 레포지토리를 클론합니다."
                read -p "계속하시겠습니까? (y/N): " confirm
                if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                    echo "취소되었습니다."
                    echo ""
                    continue
                fi
                echo ""
            fi

            # 7. 선택된 레포들 클론
            success_count=0
            fail_count=0

            for selected_repo in "${selected_repos[@]}"; do
                echo "----------------------------------------"
                echo "🔄 클론 중 ($((success_count + fail_count + 1))/${#selected_repos[@]}): $selected_repo"

                # 클론 경로 결정
                owner=$(echo "$selected_repo" | cut -d'/' -f1)
                repo_name=$(basename "$selected_repo")

                if [ "$owner" = "$github_username" ]; then
                    # 개인 레포
                    clone_path="$base_dir/$repo_name"
                    target_dir="$base_dir"
                else
                    # 조직 레포
                    clone_path="$base_dir/$owner/$repo_name"
                    target_dir="$base_dir/$owner"
                    mkdir -p "$target_dir"
                fi

                echo "   경로: $clone_path"

                cd "$target_dir" || continue

                # git clone 실행 (종료 코드 직접 확인)
                git clone "git@github.com:$selected_repo.git" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "✅ $selected_repo 클론 완료!"
                    ((success_count++))

                    # Git 설정 확인
                    cd "$clone_path" || continue
                    echo "   User: $(git config user.name) <$(git config user.email)>"
                else
                    echo "❌ $selected_repo 클론 실패!"
                    ((fail_count++))
                fi
                echo ""
            done

            # 8. 결과 요약
            echo "========================================"
            echo "📊 클론 완료!"
            echo "   ✅ 성공: ${success_count}개"
            if [ $fail_count -gt 0 ]; then
                echo "   ❌ 실패: ${fail_count}개"
            fi
            echo ""
            echo "📂 디렉토리: $base_dir"
            echo ""
            echo "💡 Tip: 다음 명령어로 클론된 레포지토리 확인:"
            echo "   ls -la $base_dir"
            echo ""

            # 작업 완료 후 선택
            next_action=$(echo -e "다시 클론하기\n처음으로 돌아가기\n종료" | fzf --height 40% --prompt="다음 작업> ")

            if [[ "$next_action" == "종료" ]] || [ -z "$next_action" ]; then
                echo "종료합니다."
                exit 0
            elif [[ "$next_action" == "처음으로 돌아가기" ]]; then
                break 3  # 계정 선택으로
            else
                # 다시 클론하기 - 타입 선택으로
                break 2
            fi
        done
    done
done
