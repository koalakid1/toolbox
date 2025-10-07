# GitHub SSH & GPG 설정 가이드

GitHub 멀티 계정을 위한 SSH 키, GPG 키, Git 설정 가이드입니다.

---

## 📋 목차

- [빠른 시작 (자동 설정)](#빠른-시작-자동-설정)
- [수동 설정](#수동-설정)
  - [1. SSH 키 설정](#1-ssh-키-설정)
  - [2. GPG 키 설정](#2-gpg-키-설정)
  - [3. Git 설정](#3-git-설정)
- [설정 확인](#설정-확인)
- [트러블슈팅](#트러블슈팅)

---

## 빠른 시작 (자동 설정)

**자동화 스크립트**를 사용하면 모든 설정을 한 번에 완료할 수 있습니다.

### 사용 방법

```bash
cd ~/github
./setup-account.sh
```

### 입력할 정보

1. **GitHub 사용자명**: 예) `koalakid1`
2. **이메일**: 예) `koalakid154@gmail.com`
3. **실제 이름**: 예) `koalakid`

### 스크립트가 자동으로 하는 일

- ✅ SSH 키 생성 (`~/.ssh/id_ed25519_username`)
- ✅ GPG 키 생성
- ✅ SSH config 업데이트 (`~/.ssh/config`)
- ✅ Git config 파일 생성 (`~/.gitconfig-username`)
- ✅ 전역 Git config 업데이트 (`~/.gitconfig`)
- ✅ 디렉토리 생성 (`~/github/username/`)

### 완료 후 할 일

스크립트 실행 후 출력된 **SSH 공개키**와 **GPG 공개키**를 복사하여:

1. https://github.com/settings/keys 접속
2. SSH 키 등록 (New SSH key)
3. GPG 키 등록 (New GPG key)
4. GitHub CLI 로그인: `gh auth login`

---

## 수동 설정

자동화 스크립트를 사용하지 않고 수동으로 설정하려면 아래 단계를 따르세요.

---

## 1. SSH 키 설정

각 계정별로 별도의 SSH 키를 생성합니다.

### Step 1: SSH 키 생성

<details>
<summary><b>🐧 Linux</b></summary>

```bash
# username을 실제 GitHub 사용자명으로 변경
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_username -N ""
```

**예시:**
```bash
ssh-keygen -t ed25519 -C "koalakid154@gmail.com" -f ~/.ssh/id_ed25519_koalakid1 -N ""
```

</details>

<details>
<summary><b>🍎 macOS</b></summary>

```bash
# username을 실제 GitHub 사용자명으로 변경
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_username -N ""
```

**예시:**
```bash
ssh-keygen -t ed25519 -C "koalakid154@gmail.com" -f ~/.ssh/id_ed25519_koalakid1 -N ""
```

</details>

<details>
<summary><b>🪟 Windows (Git Bash)</b></summary>

```bash
# username을 실제 GitHub 사용자명으로 변경
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_username -N ""
```

**예시:**
```bash
ssh-keygen -t ed25519 -C "koalakid154@gmail.com" -f ~/.ssh/id_ed25519_koalakid1 -N ""
```

</details>

---

### Step 2: SSH Config 설정

`~/.ssh/config` 파일을 생성/수정:

```bash
# GitHub - username account
Host github-username
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_username
    IdentitiesOnly yes
```

**예시 (여러 계정):**

```bash
# GitHub - koalakid1 account
Host github-koalakid1
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_koalakid1
    IdentitiesOnly yes

# GitHub - koalakid2 account
Host github-koalakid2
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_koalakid2
    IdentitiesOnly yes
```

**권한 설정:**

```bash
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519_*
```

---

### Step 3: GitHub에 SSH 공개키 등록

```bash
# 공개키 출력
cat ~/.ssh/id_ed25519_username.pub
```

1. https://github.com/settings/keys 접속
2. **New SSH key** 클릭
3. Title: `My Computer - username`
4. Key: 복사한 공개키 붙여넣기
5. **Add SSH key** 클릭

---

### Step 4: 연결 테스트

```bash
ssh -T git@github-username
```

**성공 시 출력:**
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 2. GPG 키 설정

커밋 서명을 위한 GPG 키를 생성합니다.

### Step 1: GPG 키 생성

<details>
<summary><b>🐧 Linux</b></summary>

```bash
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Your Name
Name-Email: your-email@example.com
Expire-Date: 2y
%commit
EOF
```

**예시:**
```bash
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: koalakid
Name-Email: koalakid154@gmail.com
Expire-Date: 2y
%commit
EOF
```

</details>

<details>
<summary><b>🍎 macOS</b></summary>

```bash
# Homebrew로 GPG 설치 (없다면)
brew install gnupg

# GPG 키 생성
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Your Name
Name-Email: your-email@example.com
Expire-Date: 2y
%commit
EOF
```

</details>

<details>
<summary><b>🪟 Windows</b></summary>

**Gpg4win 설치:**
https://www.gpg4win.org/download.html

**Git Bash에서 키 생성:**
```bash
gpg --full-generate-key
```

옵션 선택:
- Kind: `RSA and RSA`
- Key size: `4096`
- Valid: `2y`
- Name: `Your Name`
- Email: `your-email@example.com`

</details>

---

### Step 2: GPG 키 ID 확인

```bash
gpg --list-secret-keys --keyid-format=long
```

**출력 예시:**
```
sec   rsa4096/134994D3F1D7E369 2025-10-07 [SCEAR]
      877D4F6CAB89D4E7D144A414134994D3F1D7E369
uid                 [ultimate] koalakid <koalakid154@gmail.com>
```

여기서 `134994D3F1D7E369`가 GPG Key ID입니다.

---

### Step 3: GitHub에 GPG 공개키 등록

```bash
# GPG_KEY_ID를 위에서 확인한 ID로 변경
gpg --armor --export GPG_KEY_ID
```

**예시:**
```bash
gpg --armor --export 134994D3F1D7E369
```

1. https://github.com/settings/keys 접속
2. **New GPG key** 클릭
3. 복사한 공개키 붙여넣기 (`-----BEGIN PGP PUBLIC KEY BLOCK-----`부터 `-----END PGP PUBLIC KEY BLOCK-----`까지)
4. **Add GPG key** 클릭

---

## 3. Git 설정

폴더별로 자동으로 다른 Git 계정이 적용되도록 설정합니다.

### Step 1: 디렉토리 생성

```bash
mkdir -p ~/github/username
```

**예시:**
```bash
mkdir -p ~/github/koalakid1
mkdir -p ~/github/koalakid2
```

---

### Step 2: 계정별 Git Config 파일 생성

`~/.gitconfig-username` 파일 생성:

```bash
cat > ~/.gitconfig-username << 'EOF'
[user]
	name = Your Name
	email = your-email@example.com
	signingkey = GPG_KEY_ID
[commit]
	gpgSign = true
[url "git@github-username:"]
	insteadOf = git@github.com:
EOF
```

**예시 (koalakid1):**
```bash
cat > ~/.gitconfig-koalakid1 << 'EOF'
[user]
	name = koalakid
	email = koalakid154@gmail.com
	signingkey = 134994D3F1D7E369
[commit]
	gpgSign = true
[url "git@github-koalakid1:"]
	insteadOf = git@github.com:
EOF
```

**⚠️ 주의:**
- `signingkey`는 본인의 GPG Key ID로 변경하세요!
- `git@github-username:`의 `username`은 SSH config의 Host와 일치해야 합니다!

---

### Step 3: 전역 Git Config 수정

`~/.gitconfig` 파일 수정:

```bash
[core]
	autocrlf = input
[gpg]
	program = gpg

# username account
[includeIf "gitdir:~/github/username/"]
	path = ~/.gitconfig-username
```

**예시 (여러 계정):**
```bash
[core]
	autocrlf = input
[gpg]
	program = gpg

# koalakid1 account
[includeIf "gitdir:~/github/koalakid1/"]
	path = ~/.gitconfig-koalakid1

# koalakid2 account
[includeIf "gitdir:~/github/koalakid2/"]
	path = ~/.gitconfig-koalakid2
```

---

### Step 4: GPG TTY 설정 (Linux/macOS)

`~/.bashrc` 또는 `~/.zshrc`에 추가:

```bash
export GPG_TTY=$(tty)
```

적용:
```bash
source ~/.bashrc  # 또는 source ~/.zshrc
```

---

## 설정 확인

### SSH 설정 확인

```bash
# SSH 연결 테스트
ssh -T git@github-username
```

**성공:**
```
Hi username! You've successfully authenticated...
```

---

### Git 설정 확인

```bash
# 해당 계정 디렉토리로 이동
cd ~/github/username

# 설정 확인
git config user.name    # Your Name 출력
git config user.email   # your-email@example.com 출력
git config user.signingkey  # GPG_KEY_ID 출력
```

---

### GPG 서명 테스트

```bash
cd ~/github/username

# 테스트 레포 생성
mkdir test-repo && cd test-repo
git init

# 커밋 생성
echo "test" > test.txt
git add .
git commit -m "Test commit"

# 서명 확인
git log --show-signature
```

**성공 시 출력:**
```
gpg: Signature made ...
gpg: Good signature from "Your Name <your-email@example.com>"
```

---

## 트러블슈팅

<details>
<summary><b>SSH 연결 실패: Permission denied</b></summary>

### 원인
- SSH 키가 GitHub에 등록되지 않았거나
- SSH config 설정이 잘못됨

### 해결
```bash
# SSH 키 권한 확인
ls -la ~/.ssh/

# 권한이 잘못되었다면 수정
chmod 600 ~/.ssh/id_ed25519_*
chmod 600 ~/.ssh/config

# SSH 연결 테스트 (디버그 모드)
ssh -vT git@github-username
```

</details>

<details>
<summary><b>GPG 서명 실패: gpg failed to sign the data</b></summary>

### 원인
- GPG 키가 만료되었거나
- GPG TTY가 설정되지 않음

### 해결
```bash
# GPG 키 확인
gpg --list-secret-keys --keyid-format=long

# GPG TTY 설정 (Linux/macOS)
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc

# Git에 GPG 경로 설정
git config --global gpg.program $(which gpg)

# 테스트
echo "test" | gpg --clearsign
```

</details>

<details>
<summary><b>잘못된 계정으로 커밋됨</b></summary>

### 원인
- 잘못된 디렉토리에서 작업하거나
- Git config가 제대로 적용되지 않음

### 해결
```bash
# 현재 디렉토리의 Git 설정 확인
pwd
git config user.email
git config user.name

# 올바른 디렉토리로 이동
# ~/github/username/ 아래에서 작업해야 함

# 마지막 커밋 수정 (아직 push 안 했다면)
git commit --amend --reset-author
```

</details>

<details>
<summary><b>Git includeIf가 작동하지 않음</b></summary>

### 원인
- 경로가 정확하지 않거나
- Git 버전이 너무 낮음 (2.13.0 이상 필요)

### 해결
```bash
# Git 버전 확인
git --version  # 2.13.0 이상이어야 함

# includeIf 경로 확인 (절대 경로 사용 권장)
[includeIf "gitdir:~/github/username/"]  # 상대 경로
[includeIf "gitdir:/home/user/github/username/"]  # 절대 경로

# 설정 확인
cd ~/github/username
git config --list --show-origin | grep user
```

</details>

<details>
<summary><b>GPG 키가 너무 오래 걸림</b></summary>

### 원인
- 시스템에 충분한 엔트로피가 없음

### 해결 (Linux)
```bash
# rng-tools 설치
sudo apt install rng-tools

# 또는 활동 생성 (다른 터미널에서)
# 마우스 움직이기, 파일 복사 등
```

</details>

---

## 📚 참고 자료

- [GitHub SSH 키 설정](https://docs.github.com/ko/authentication/connecting-to-github-with-ssh)
- [GitHub GPG 키 설정](https://docs.github.com/ko/authentication/managing-commit-signature-verification)
- [Git Conditional Includes](https://git-scm.com/docs/git-config#_conditional_includes)

---

**작성일:** 2025-10-07
**버전:** 1.0.0
