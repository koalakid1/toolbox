# GitHub 레포지토리 자동 클론 가이드

대화형 스크립트를 사용하여 GitHub 레포지토리를 쉽게 클론하는 방법입니다.

---

## 📋 목차

- [빠른 시작](#빠른-시작)
- [사전 요구사항](#사전-요구사항)
- [설치](#설치)
- [사용 방법](#사용-방법)
- [디렉토리 구조](#디렉토리-구조)
- [고급 기능](#고급-기능)
- [트러블슈팅](#트러블슈팅)

---

## 빠른 시작

```bash
cd ~/github
./clone-repo.sh
```

1. 계정 선택 (자동 탐지된 목록에서 선택)
2. 타입 선택 (내 레포 / 조직 레포)
3. 조직 선택 (조직 레포인 경우)
4. 방식 선택 (전체 클론 / 선택적 클론)
5. 레포 선택 (Tab으로 다중 선택 가능)
6. 자동 클론!

---

## 사전 요구사항

### 1. SSH/GPG 설정 완료

먼저 [SSH_GPG_SETUP.md](SSH_GPG_SETUP.md)를 참고하여 계정 설정을 완료하세요.

**간편 설정:**
```bash
./setup-account.sh
```

### 2. 필수 도구 설치

- **gh** (GitHub CLI)
- **fzf** (Fuzzy Finder)

---

## 설치

### Linux (Ubuntu/Debian)

```bash
# fzf 설치
sudo apt update
sudo apt install -y fzf

# GitHub CLI 설치
sudo snap install gh
# 또는
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### macOS

```bash
# Homebrew로 설치
brew install fzf gh
```

### Windows (Git Bash)

```bash
# Chocolatey로 설치
choco install fzf gh

# 또는 Scoop으로 설치
scoop install fzf gh
```

---

### GitHub CLI 인증

**각 계정마다** `gh auth login` 실행:

```bash
gh auth login
```

선택:
1. **GitHub.com**
2. **SSH**
3. **Login with a web browser**
4. 코드 입력 후 인증

**여러 계정 등록:**

```bash
# 첫 번째 계정 (koalakid1)
gh auth login

# 두 번째 계정 (koalakid2)
gh auth login  # 추가 계정 등록
```

**계정 전환:**

```bash
# 등록된 계정 확인
gh auth status

# 계정 전환
gh auth switch -h github.com -u username
```

---

## 사용 방법

### 기본 사용

```bash
cd ~/github
./clone-repo.sh
```

### 단계별 설명

#### 1단계: 계정 선택

`~/github/` 폴더의 디렉토리가 자동으로 탐지됩니다:

```
계정>
  koalakid1
  koalakid2
  alice
  ❌ 종료
```

**자동 탐지 조건:**
- `~/github/` 아래의 모든 디렉토리
- `.gitconfig-{계정명}` 파일이 있으면 이메일/이름도 표시

**계정 추가 방법:**
```bash
# 새 계정 폴더 생성
mkdir -p ~/github/new-account

# Git config 설정
./setup-account.sh  # 자동 설정
```

---

#### 2단계: 타입 선택

```
타입>
  내 레포지토리
  조직 레포지토리
  ← 이전으로 (계정 선택)
```

- **내 레포지토리**: 개인 소유 레포
- **조직 레포지토리**: 참여 중인 조직의 레포

---

#### 3단계: 조직 선택 (조직 레포인 경우만)

```
조직>
  serengeti
  aifrica
  my-company
  ← 이전으로 (타입 선택)
```

참여 중인 모든 조직이 자동으로 표시됩니다.

---

#### 4단계: 클론 방식 선택

```
방식>
  전체 클론 (15개)
  선택적 클론 (직접 선택)
  ← 이전으로
```

- **전체 클론**: 클론 가능한 모든 레포를 한 번에 클론
- **선택적 클론**: 원하는 레포만 선택

**⚠️ 중요:**
- 이미 클론된 레포는 자동으로 제외됩니다!
- 전체 클론을 선택해도 중복 클론되지 않습니다.

---

#### 5단계: 레포 선택 (선택적 클론인 경우)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 다중 선택 방법:
   • Tab 키: 선택/해제 (앞에 > 표시됨)
   • 화살표: 위/아래 이동
   • Enter: 선택 확정
   • ESC: 이전으로 돌아가기
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶ 레포지토리 (Tab=선택)>
  username/repo1
  username/repo2
> username/repo3     ← 선택됨 (Tab으로 선택)
  username/repo4
> username/repo5     ← 선택됨
```

**조작 방법:**
1. **화살표 (↑↓)**: 레포 간 이동
2. **Tab**: 현재 레포 선택/해제
3. **Enter**: 선택 완료
4. **ESC**: 취소

**미리보기:**
- 화살표로 이동하면 오른쪽에 레포 정보 표시 (설명, 언어, 스타 등)

---

#### 6단계: 클론 진행

```
========================================
🔄 클론 중 (1/3): username/repo1
   경로: /home/user/github/koalakid1/repo1
✅ username/repo1 클론 완료!
   User: koalakid <koalakid154@gmail.com>

========================================
🔄 클론 중 (2/3): serengeti/repo2
   경로: /home/user/github/koalakid1/serengeti/repo2
✅ serengeti/repo2 클론 완료!
   User: koalakid <koalakid154@gmail.com>

========================================
📊 클론 완료!
   ✅ 성공: 3개
   ❌ 실패: 0개

📂 디렉토리: /home/user/github/koalakid1
```

---

## 디렉토리 구조

레포지토리는 다음과 같은 구조로 자동 정리됩니다:

```
~/github/
├── koalakid1/
│   ├── my-repo/              # 개인 레포
│   ├── my-project/           # 개인 레포
│   └── serengeti/            # 조직별 폴더
│       ├── org-repo1/
│       └── org-repo2/
└── koalakid2/
    ├── work-repo/            # 개인 레포
    └── aifrica/              # 조직별 폴더
        ├── company-repo1/
        └── company-repo2/
```

### 규칙

- **개인 레포**: `~/github/{계정명}/{레포명}`
- **조직 레포**: `~/github/{계정명}/{조직명}/{레포명}`

### 자동 구분

스크립트가 자동으로:
1. 레포 소유자 확인 (개인 vs 조직)
2. 조직 레포면 조직 폴더 생성
3. 적절한 위치에 클론

---

## 고급 기능

### 이전으로 돌아가기

모든 선택 단계에서 **"← 이전으로"** 옵션 제공:
- 잘못 선택했을 때 쉽게 되돌리기
- ESC 키로도 이전 단계로

### 계정 자동 전환

선택한 계정에 맞춰 **gh 계정 자동 전환**:

```
✓ 선택된 계정: koalakid1
  이메일: koalakid154@gmail.com
  이름: koalakid

🔄 koalakid1 계정으로 전환 시도 중...
✅ 계정 전환 완료!
✓ 활성화된 GitHub 계정: koalakid1
```

**전환 실패 시:**
- 경고 메시지 표시
- 현재 계정으로 계속할지 선택 가능

### 중복 클론 방지

**자동 체크:**
- 로컬에 이미 있는 레포는 목록에서 제외
- "전체 클론" 선택해도 안전

**확인 메시지:**
```
✅ 모든 레포지토리가 이미 클론되어 있습니다!
```

### 대량 클론 확인

5개 이상 클론 시 확인:

```
⚠️  15개의 레포지토리를 클론합니다.
계속하시겠습니까? (y/N):
```

### 클론 완료 후 옵션

```
다음 작업>
  다시 클론하기
  처음으로 돌아가기
  종료
```

---

## 트러블슈팅

<details>
<summary><b>GitHub CLI 인증 오류</b></summary>

### 증상
```
❌ GitHub CLI 인증이 필요합니다.
```

### 해결
```bash
# 계정 로그인
gh auth login

# 계정 확인
gh auth status

# 여러 계정 등록했다면 전환
gh auth switch -h github.com -u username
```

</details>

<details>
<summary><b>계정이 목록에 안 나타남</b></summary>

### 원인
- `~/github/` 폴더에 디렉토리가 없음

### 해결
```bash
# 계정 폴더 생성
mkdir -p ~/github/username

# 또는 자동 설정 스크립트 사용
./setup-account.sh
```

</details>

<details>
<summary><b>클론 실패: Permission denied</b></summary>

### 원인
- SSH 키가 GitHub에 등록되지 않았거나
- SSH config 설정 오류

### 해결
```bash
# SSH 연결 테스트
ssh -T git@github-username

# SSH 키 확인
ls -la ~/.ssh/

# SSH config 확인
cat ~/.ssh/config

# 공개키 다시 등록
cat ~/.ssh/id_ed25519_username.pub
# → https://github.com/settings/keys
```

</details>

<details>
<summary><b>잘못된 계정의 레포가 보임</b></summary>

### 원인
- gh CLI가 다른 계정으로 로그인되어 있음

### 해결
```bash
# 현재 로그인 계정 확인
gh auth status

# 올바른 계정으로 전환
gh auth switch -h github.com -u username

# 또는 스크립트가 자동으로 전환 시도함
# (전환 실패 시 경고 메시지 확인)
```

</details>

<details>
<summary><b>Git 설정이 잘못됨</b></summary>

### 증상
```
User: wrong-user <wrong@email.com>
```

### 원인
- Git config includeIf가 제대로 작동하지 않음

### 해결
```bash
# 현재 디렉토리 확인
pwd  # ~/github/username/ 아래여야 함

# Git 설정 확인
git config user.email
git config user.name

# includeIf 설정 확인
cat ~/.gitconfig | grep -A2 includeIf

# 계정별 config 확인
cat ~/.gitconfig-username
```

</details>

<details>
<summary><b>fzf에서 한글이 깨짐 (Windows)</b></summary>

### 해결
```bash
# ~/.bashrc에 추가
export LC_ALL=ko_KR.UTF-8
export LANG=ko_KR.UTF-8

# 적용
source ~/.bashrc
```

</details>

---

## 💡 Tip & Tricks

### 1. 빠른 클론

```bash
# 모든 개인 레포 한 번에 클론
./clone-repo.sh
# → 계정 선택 → 내 레포 → 전체 클론

# 특정 조직의 모든 레포 클론
./clone-repo.sh
# → 계정 선택 → 조직 레포 → 조직 선택 → 전체 클론
```

### 2. 클론된 레포 확인

```bash
# 디렉토리 구조 확인
tree -L 2 ~/github/

# 또는
ls -la ~/github/username/
```

### 3. 레포 업데이트

```bash
# 모든 레포 업데이트 (간단한 스크립트)
find ~/github/username -name ".git" -type d | while read gitdir; do
    repo=$(dirname "$gitdir")
    echo "Updating $repo"
    cd "$repo" && git pull
done
```

### 4. 레포 검색

```bash
# fzf로 레포 빠르게 찾기
cd ~/github
find . -name ".git" -type d | sed 's|/.git||' | fzf
```

---

## 📚 관련 문서

- [SSH & GPG 설정 가이드](SSH_GPG_SETUP.md)
- [GitHub CLI 공식 문서](https://cli.github.com/manual/)
- [fzf GitHub](https://github.com/junegunn/fzf)

---

**작성일:** 2025-10-07
**버전:** 1.0.0
