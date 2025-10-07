# GitHub 멀티 계정 설정 가이드

여러 GitHub 계정을 하나의 시스템에서 사용하기 위한 완벽한 설정 가이드입니다.

## 📋 목차

- [개요](#개요)
- [1. SSH 키 설정](#1-ssh-키-설정)
- [2. GPG 키 설정](#2-gpg-키-설정)
- [3. Git 설정](#3-git-설정)
- [4. 도구 설치 (gh, fzf)](#4-도구-설치-gh-fzf)
- [5. 자동화 스크립트 사용법](#5-자동화-스크립트-사용법)
- [6. 디렉토리 구조](#6-디렉토리-구조)
- [7. 트러블슈팅](#7-트러블슈팅)

---

## 개요

이 가이드는 다음과 같은 환경을 구축합니다:

- ✅ 여러 GitHub 계정을 하나의 PC에서 사용
- ✅ 폴더별로 자동으로 다른 계정 적용
- ✅ SSH/GPG 자동 전환
- ✅ 대화형 레포지토리 클론 도구

**예시 계정:**
- `koalakid1` (koalakid154@gmail.com)
- `koalakid2` (tm.lee@aifrica.co.kr)

---

## 1. SSH 키 설정

각 계정별로 별도의 SSH 키를 생성하고 설정합니다.

<details>
<summary><b>🐧 Linux</b></summary>

### SSH 키 생성

```bash
# koalakid1 SSH 키 생성
ssh-keygen -t ed25519 -C "koalakid154@gmail.com" -f ~/.ssh/id_ed25519_koalakid1 -N ""

# koalakid2 SSH 키 생성 (기존 키가 있다면 이름 변경)
mv ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_koalakid2
mv ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519_koalakid2.pub
```

### SSH Config 설정

`~/.ssh/config` 파일을 생성/수정:

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

### 권한 설정

```bash
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519_koalakid1
chmod 600 ~/.ssh/id_ed25519_koalakid2
```

### GitHub에 공개키 등록

```bash
# koalakid1 공개키 출력
cat ~/.ssh/id_ed25519_koalakid1.pub

# koalakid2 공개키 출력
cat ~/.ssh/id_ed25519_koalakid2.pub
```

각 계정으로 로그인하여 https://github.com/settings/keys 에서 등록

### 연결 테스트

```bash
ssh -T git@github-koalakid1
ssh -T git@github-koalakid2
```

</details>

<details>
<summary><b>🍎 macOS</b></summary>

### SSH 키 생성

```bash
# koalakid1 SSH 키 생성
ssh-keygen -t ed25519 -C "koalakid154@gmail.com" -f ~/.ssh/id_ed25519_koalakid1 -N ""

# koalakid2 SSH 키 생성 (기존 키가 있다면 이름 변경)
mv ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_koalakid2
mv ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519_koalakid2.pub
```

### SSH Config 설정

`~/.ssh/config` 파일을 생성/수정:

```bash
# GitHub - koalakid1 account
Host github-koalakid1
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_koalakid1
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes

# GitHub - koalakid2 account
Host github-koalakid2
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_koalakid2
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
```

**참고:** macOS는 `AddKeysToAgent`와 `UseKeychain` 옵션 추가 권장

### 권한 설정

```bash
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519_koalakid1
chmod 600 ~/.ssh/id_ed25519_koalakid2
```

### GitHub에 공개키 등록

```bash
# koalakid1 공개키 출력 (클립보드에 복사)
cat ~/.ssh/id_ed25519_koalakid1.pub | pbcopy

# koalakid2 공개키 출력 (클립보드에 복사)
cat ~/.ssh/id_ed25519_koalakid2.pub | pbcopy
```

각 계정으로 로그인하여 https://github.com/settings/keys 에서 등록

### 연결 테스트

```bash
ssh -T git@github-koalakid1
ssh -T git@github-koalakid2
```

</details>

<details>
<summary><b>🪟 Windows (Git Bash / WSL)</b></summary>

### Git Bash 사용 시

#### SSH 키 생성

```bash
# koalakid1 SSH 키 생성
ssh-keygen -t ed25519 -C "koalakid154@gmail.com" -f ~/.ssh/id_ed25519_koalakid1 -N ""

# koalakid2 SSH 키 생성 (기존 키가 있다면 이름 변경)
mv ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_koalakid2
mv ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519_koalakid2.pub
```

#### SSH Config 설정

`C:\Users\사용자명\.ssh\config` 파일을 생성/수정:

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

#### GitHub에 공개키 등록

```bash
# koalakid1 공개키 출력
cat ~/.ssh/id_ed25519_koalakid1.pub

# koalakid2 공개키 출력
cat ~/.ssh/id_ed25519_koalakid2.pub
```

복사하여 https://github.com/settings/keys 에서 등록

#### 연결 테스트

```bash
ssh -T git@github-koalakid1
ssh -T git@github-koalakid2
```

### WSL 사용 시

Linux 섹션과 동일하게 진행

</details>

---

## 2. GPG 키 설정

커밋 서명을 위한 GPG 키를 각 계정별로 생성합니다.

<details>
<summary><b>🐧 Linux</b></summary>

### GPG 키 생성

#### koalakid1 GPG 키

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

#### koalakid2 GPG 키 (이미 있다면 건너뛰기)

```bash
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: koalakid2
Name-Email: tm.lee@aifrica.co.kr
Expire-Date: 2y
%commit
EOF
```

### GPG 키 ID 확인

```bash
gpg --list-secret-keys --keyid-format=long
```

출력 예시:
```
sec   rsa4096/134994D3F1D7E369 2025-10-07 [SCEAR]
uid                 [ultimate] koalakid <koalakid154@gmail.com>

sec   rsa4096/D6B94F8C960A129C 2025-10-04 [SC]
uid                 [ultimate] koalakid2 <tm.lee@aifrica.co.kr>
```

여기서 `134994D3F1D7E369`와 `D6B94F8C960A129C`가 키 ID입니다.

### GitHub에 GPG 공개키 등록

```bash
# koalakid1 GPG 공개키 출력
gpg --armor --export 134994D3F1D7E369

# koalakid2 GPG 공개키 출력
gpg --armor --export D6B94F8C960A129C
```

각 계정으로 로그인하여 https://github.com/settings/keys 에서 등록

</details>

<details>
<summary><b>🍎 macOS</b></summary>

### GPG 설치 (Homebrew 사용)

```bash
brew install gnupg
```

### GPG 키 생성

#### koalakid1 GPG 키

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

#### koalakid2 GPG 키

```bash
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: koalakid2
Name-Email: tm.lee@aifrica.co.kr
Expire-Date: 2y
%commit
EOF
```

### GPG 키 ID 확인

```bash
gpg --list-secret-keys --keyid-format=long
```

### GitHub에 GPG 공개키 등록

```bash
# koalakid1 GPG 공개키 출력 (클립보드에 복사)
gpg --armor --export 키ID | pbcopy

# koalakid2 GPG 공개키 출력 (클립보드에 복사)
gpg --armor --export 키ID | pbcopy
```

https://github.com/settings/keys 에서 등록

</details>

<details>
<summary><b>🪟 Windows</b></summary>

### GPG 설치

1. **Gpg4win 설치**: https://www.gpg4win.org/download.html
2. Git Bash 또는 WSL에서 사용

### GPG 키 생성 (Git Bash)

#### koalakid1 GPG 키

```bash
gpg --full-generate-key
```

옵션 선택:
- Kind: RSA and RSA
- Key size: 4096
- Valid: 2y
- Name: koalakid
- Email: koalakid154@gmail.com

#### koalakid2 GPG 키

동일한 방법으로 koalakid2 정보로 생성

### GPG 키 ID 확인

```bash
gpg --list-secret-keys --keyid-format=long
```

### GitHub에 GPG 공개키 등록

```bash
gpg --armor --export 키ID
```

복사하여 https://github.com/settings/keys 에서 등록

</details>

---

## 3. Git 설정

폴더별로 자동으로 다른 Git 계정이 적용되도록 설정합니다.

### 디렉토리 생성

```bash
mkdir -p ~/github/koalakid1
mkdir -p ~/github/koalakid2
```

### 계정별 Git Config 파일 생성

#### `~/.gitconfig-koalakid1`

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

**⚠️ 주의:** `signingkey`는 본인의 GPG 키 ID로 변경하세요!

#### `~/.gitconfig-koalakid2`

```bash
cat > ~/.gitconfig-koalakid2 << 'EOF'
[user]
	name = koalakid2
	email = tm.lee@aifrica.co.kr
	signingkey = D6B94F8C960A129C
[commit]
	gpgSign = true
[url "git@github-koalakid2:"]
	insteadOf = git@github.com:
EOF
```

**⚠️ 주의:** `signingkey`는 본인의 GPG 키 ID로 변경하세요!

### 전역 Git Config 수정

`~/.gitconfig` 파일 수정:

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

### 설정 확인

```bash
# koalakid1 디렉토리에서 확인
cd ~/github/koalakid1
git config user.email  # koalakid154@gmail.com 출력되어야 함

# koalakid2 디렉토리에서 확인
cd ~/github/koalakid2
git config user.email  # tm.lee@aifrica.co.kr 출력되어야 함
```

---

## 4. 도구 설치 (gh, fzf)

자동화 스크립트 사용을 위해 GitHub CLI와 fzf를 설치합니다.

<details>
<summary><b>🐧 Linux (Ubuntu/Debian)</b></summary>

### 설치 스크립트 실행

```bash
# 설치 스크립트 실행
~/install-gh-fzf.sh
```

또는 수동 설치:

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

### GitHub CLI 인증

```bash
gh auth login
```

선택:
1. GitHub.com
2. SSH
3. Login with a web browser
4. 코드 입력 후 인증

</details>

<details>
<summary><b>🍎 macOS</b></summary>

### Homebrew로 설치

```bash
# fzf 설치
brew install fzf

# GitHub CLI 설치
brew install gh
```

### GitHub CLI 인증

```bash
gh auth login
```

선택:
1. GitHub.com
2. SSH
3. Login with a web browser
4. 코드 입력 후 인증

</details>

<details>
<summary><b>🪟 Windows</b></summary>

### Git Bash 사용 시

#### fzf 설치

```bash
# Chocolatey로 설치
choco install fzf

# 또는 Scoop으로 설치
scoop install fzf
```

#### GitHub CLI 설치

1. https://cli.github.com/ 에서 다운로드
2. 설치 파일 실행

또는 Chocolatey:

```bash
choco install gh
```

### GitHub CLI 인증

```bash
gh auth login
```

### WSL 사용 시

Linux 섹션과 동일하게 진행

</details>

---

## 5. 자동화 스크립트 사용법

대화형 레포지토리 클론 스크립트를 사용합니다.

### 스크립트 실행

```bash
cd ~/github
./clone-repo.sh
```

### 사용 순서

1. **계정 선택**
   - `koalakid1` 또는 `koalakid2` 선택

2. **타입 선택**
   - `내 레포지토리` 또는 `조직 레포지토리` 선택

3. **조직 선택** (조직 레포지토리 선택 시)
   - 참여 중인 조직 목록에서 선택

4. **레포지토리 선택**
   - **Tab 키**로 여러 레포 선택 가능
   - 이미 클론된 레포는 목록에서 제외됨
   - 화살표 키로 이동, Enter로 확정

5. **자동 클론**
   - 선택한 레포들이 자동으로 클론됨
   - 성공/실패 개수 표시

### 스크립트 특징

- ✅ 이미 클론된 레포는 목록에서 제외
- ✅ 여러 레포 한번에 클론 (Tab으로 다중 선택)
- ✅ 개인/조직 레포 자동 구분
- ✅ Git 설정 자동 확인

---

## 6. 디렉토리 구조

레포지토리는 다음과 같은 구조로 관리됩니다:

```
~/github/
├── koalakid1/
│   ├── my-personal-repo/          # 개인 레포
│   ├── my-project/                 # 개인 레포
│   └── serengeti/                  # 조직별 폴더
│       ├── org-repo1/
│       └── org-repo2/
└── koalakid2/
    ├── work-repo/                  # 개인 레포
    └── aifrica/                    # 조직별 폴더
        ├── company-repo1/
        └── company-repo2/
```

### 규칙

- **개인 레포**: `~/github/{계정명}/{레포명}`
- **조직 레포**: `~/github/{계정명}/{조직명}/{레포명}`

### 수동 클론 방법

```bash
# koalakid1 개인 레포
cd ~/github/koalakid1
git clone git@github.com:username/repo.git

# koalakid1 조직 레포
cd ~/github/koalakid1/serengeti
git clone git@github.com:serengeti/repo.git

# koalakid2 레포
cd ~/github/koalakid2
git clone git@github.com:username/repo.git
```

**참고:** `git@github.com`은 폴더에 따라 자동으로 `git@github-koalakid1` 또는 `git@github-koalakid2`로 변환됩니다.

---

## 7. 트러블슈팅

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
chmod 600 ~/.ssh/id_ed25519_koalakid1
chmod 600 ~/.ssh/id_ed25519_koalakid2
chmod 600 ~/.ssh/config

# SSH 연결 테스트
ssh -T git@github-koalakid1
ssh -T git@github-koalakid2
```

</details>

<details>
<summary><b>GPG 서명 실패: gpg failed to sign the data</b></summary>

### 원인
- GPG 키가 만료되었거나
- Git에서 GPG를 찾지 못함

### 해결
```bash
# GPG 키 확인
gpg --list-secret-keys --keyid-format=long

# GPG 프로그램 경로 확인
which gpg

# Git에 GPG 경로 설정
git config --global gpg.program $(which gpg)

# TTY 설정 (Linux/macOS)
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc  # 또는 ~/.zshrc
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
git config user.email
git config user.name

# 올바른 디렉토리로 이동
# ~/github/koalakid1/ 또는 ~/github/koalakid2/

# 마지막 커밋 수정 (아직 push 안 했다면)
git commit --amend --reset-author
```

</details>

<details>
<summary><b>gh auth login 실패</b></summary>

### 원인
- 네트워크 문제 또는
- 브라우저 인증 실패

### 해결
```bash
# 기존 인증 정보 삭제
gh auth logout

# 다시 로그인
gh auth login

# 토큰으로 로그인 (브라우저 사용 불가 시)
# https://github.com/settings/tokens 에서 토큰 생성
gh auth login --with-token < token.txt
```

</details>

<details>
<summary><b>fzf에서 한글이 깨짐 (Windows)</b></summary>

### 원인
- Git Bash의 인코딩 문제

### 해결
```bash
# ~/.bashrc 또는 ~/.bash_profile 에 추가
export LC_ALL=ko_KR.UTF-8
export LANG=ko_KR.UTF-8
```

</details>

<details>
<summary><b>스크립트 실행 시 "command not found"</b></summary>

### 원인
- 스크립트에 실행 권한이 없음

### 해결
```bash
# 실행 권한 부여
chmod +x ~/github/clone-repo.sh

# 실행
~/github/clone-repo.sh
```

</details>

---

## 📚 참고 자료

- [GitHub SSH 키 설정](https://docs.github.com/ko/authentication/connecting-to-github-with-ssh)
- [GitHub GPG 키 설정](https://docs.github.com/ko/authentication/managing-commit-signature-verification)
- [GitHub CLI 공식 문서](https://cli.github.com/manual/)
- [fzf GitHub](https://github.com/junegunn/fzf)

---

## 📝 라이선스

이 가이드는 자유롭게 사용, 수정, 배포할 수 있습니다.

---

**작성일:** 2025-10-07
**버전:** 1.0.0
