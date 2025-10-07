# clone-repo.sh

GitHub 멀티 계정 환경에서 레포지토리를 대화형으로 클론하는 스크립트입니다. fzf 기반 인터페이스로 계정, 타입, 레포를 선택하여 자동으로 정리된 디렉토리 구조에 클론합니다.

## 목적

- 여러 GitHub 계정의 레포지토리 관리
- 개인/조직 레포 자동 분류
- 중복 클론 방지
- 사용자 친화적인 대화형 인터페이스

## 주요 기능

### 1. 계정 자동 탐지
- `~/github/` 폴더의 디렉토리 자동 스캔
- `.gitconfig-{username}` 파일에서 이메일/이름 표시
- 계정 선택 시 자동으로 `gh auth switch` 시도

### 2. 레포지토리 타입 선택
- **내 레포지토리**: 개인 소유 레포
- **조직 레포지토리**: 참여 중인 조직의 레포
  - 조직 목록 자동 조회 (GitHub API)
  - 조직 선택 후 해당 조직 레포 목록 표시

### 3. 클론 방식 선택
- **전체 클론**: 클론 가능한 모든 레포를 한 번에
- **선택적 클론**: fzf 다중 선택으로 원하는 레포만

### 4. 자동 디렉토리 정리
- 개인 레포: `~/github/{계정}/{레포명}`
- 조직 레포: `~/github/{계정}/{조직명}/{레포명}`

### 5. 스마트 기능
- 이미 클론된 레포 자동 필터링 (중복 방지)
- 5개 이상 클론 시 확인 메시지
- 각 레포 클론 후 Git 설정 표시 (user.name, user.email)
- 이전 단계로 돌아가기 지원

## 사용법

```bash
./clone-repo.sh
```

## 사용 흐름

```
1. 계정 선택
   ↓
2. gh auth switch 시도
   ↓
3. 타입 선택 (내 레포 / 조직 레포)
   ↓
4. [조직 레포인 경우] 조직 선택
   ↓
5. 레포 목록 조회 (GitHub API)
   ↓
6. 이미 클론된 레포 필터링
   ↓
7. 클론 방식 선택 (전체 / 선택적)
   ↓
8. [선택적인 경우] fzf 다중 선택
   ↓
9. 클론 진행
   ↓
10. 다음 작업 선택 (다시 클론 / 처음으로 / 종료)
```

## fzf 단축키

### 계정/조직 선택
- `↑↓`: 이동
- `Enter`: 선택
- `ESC`: 종료

### 레포 다중 선택
- `↑↓`: 이동
- `Tab`: 선택/해제 (앞에 `>` 표시)
- `Enter`: 선택 확정
- `ESC`: 취소
- **타이핑**: 실시간 검색 필터링
- `Ctrl+P/N`: 이전/다음 항목
- `--preview`: 오른쪽에 레포 정보 미리보기

## 출력 예시

### 계정 선택
```
🚀 GitHub 레포지토리 클론

계정>
  koalakid1
  koalakid2
  ❌ 종료
```

### 계정 전환
```
✓ 선택된 계정: koalakid1
  이메일: koalakid154@gmail.com
  이름: koalakid

🔄 koalakid1 계정으로 전환 시도 중...
✅ 계정 전환 완료!
✓ 활성화된 GitHub 계정: koalakid1
```

### 클론 진행
```
----------------------------------------
🔄 클론 중 (1/3): koalakid1/my-repo
   경로: /home/user/github/koalakid1/my-repo
✅ koalakid1/my-repo 클론 완료!
   User: koalakid <koalakid154@gmail.com>

----------------------------------------
🔄 클론 중 (2/3): serengeti/org-repo
   경로: /home/user/github/koalakid1/serengeti/org-repo
✅ serengeti/org-repo 클론 완료!
   User: koalakid <koalakid154@gmail.com>
```

### 결과 요약
```
========================================
📊 클론 완료!
   ✅ 성공: 2개
   ❌ 실패: 0개

📂 디렉토리: /home/user/github/koalakid1

💡 Tip: 다음 명령어로 클론된 레포지토리 확인:
   ls -la /home/user/github/koalakid1

다음 작업>
  다시 클론하기
  처음으로 돌아가기
  종료
```

## 기술적 세부사항

### 계정 탐지
```bash
github_base="$HOME/github"
mapfile -t accounts < <(find "$github_base" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)
```

### GitHub API 사용 (gh CLI)
```bash
# 개인 레포 목록
gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner'

# 조직 목록
gh api user/orgs --jq '.[].login'

# 조직 레포 목록
gh repo list "$selected_org" --limit 1000 --json nameWithOwner -q '.[].nameWithOwner'
```

### 중복 클론 방지
```bash
for repo in "${repos[@]}"; do
    owner=$(echo "$repo" | cut -d'/' -f1)
    repo_name=$(basename "$repo")

    if [ "$owner" = "$github_username" ]; then
        local_path="$base_dir/$repo_name"
    else
        local_path="$base_dir/$owner/$repo_name"
    fi

    if [ ! -d "$local_path" ]; then
        available_repos+=("$repo")
    fi
done
```

### Git 클론
```bash
git clone "git@github.com:$selected_repo.git"
```

URL은 자동으로 `git@github-{username}:`으로 변환됩니다 (`~/.gitconfig-{username}`의 `insteadOf` 설정).

## 디렉토리 구조

```
~/github/
├── koalakid1/
│   ├── my-repo/              # 개인 레포
│   ├── my-project/           # 개인 레포
│   └── serengeti/            # 조직 폴더
│       ├── org-repo1/
│       └── org-repo2/
└── koalakid2/
    ├── work-repo/            # 개인 레포
    └── aifrica/              # 조직 폴더
        └── company-repo/
```

## 계정 불일치 경고

선택한 계정과 `gh` CLI 로그인 계정이 다를 경우:

```
⚠️  경고: 선택한 계정과 활성화된 계정이 다릅니다!
   선택: koalakid2
   활성화: koalakid1

   'koalakid1' 계정의 레포지토리가 표시됩니다.

계속하시겠습니까? (y/N):
```

이 경우 `gh auth login`으로 계정을 추가하거나 `gh auth switch`로 전환해야 합니다.

## 에러 처리

### GitHub CLI 인증 필요
```
❌ GitHub CLI 인증이 필요합니다.
다음 명령어로 'koalakid1' 계정을 등록하세요:
   gh auth login
```

### 조직 없음
```
❌ 조직을 찾을 수 없습니다.
```

### 레포지토리 없음
```
❌ 레포지토리를 찾을 수 없습니다.
```

### 모든 레포 클론됨
```
✅ 모든 레포지토리가 이미 클론되어 있습니다!
```

## 네비게이션

모든 선택 단계에서:
- **"← 이전으로"** 옵션으로 이전 단계 복귀
- **ESC** 키로 종료
- **"❌ 종료"** 선택으로 종료

## 필수 도구

- **gh** (GitHub CLI) - 레포 목록 조회
- **fzf** - 대화형 선택
- **git** - 레포 클론

## 제한사항

- 레포 목록 최대 1000개 (`--limit 1000`)
- Private 레포는 해당 계정에 gh CLI 인증이 필요
- SSH 인증 사용 (HTTPS 아님)

## 관련 파일

- `setup-account.sh` - 계정 설정 (이 스크립트 실행 전 필요)
- `CLONE_GUIDE.md` - 상세 사용 가이드
- `~/.gitconfig-{username}` - Git 설정 (URL 재작성)
- `~/.ssh/config` - SSH 설정

## 검색 기능

fzf에서 타이핑하면 실시간 검색:
- `react` → react가 포함된 레포만 표시
- `'wild` → wild로 시작하는 레포
- `wild$` → wild로 끝나는 레포
- `!exclude` → exclude를 포함하지 않는 레포
