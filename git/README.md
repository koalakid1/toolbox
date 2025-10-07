# GitHub 멀티 계정 관리 도구

GitHub 멀티 계정을 위한 SSH/GPG 키 관리 및 자동 클론 도구입니다.

---

## 🚀 빠른 시작

### 1. 필수 도구 설치

```bash
./install-required-tools.sh
```

### 2. 계정 설정

```bash
./setup-account.sh
```

### 3. 레포지토리 클론

```bash
./clone-repo.sh
```

---

## 📦 포함된 파일

### 🔧 Scripts

#### `install-required-tools.sh`
필수 도구(ssh-keygen, gpg, git) 설치 안내 스크립트

**기능:**
- 설치된 도구 자동 감지
- OS별 설치 명령어 제공 (Linux/macOS/Windows)
- 버전 정보 출력

**사용:**
```bash
./install-required-tools.sh
```

---

#### `setup-account.sh`
GitHub 계정별 SSH/GPG 키 및 Git 설정 자동 생성 스크립트

**기능:**
- 신규 계정 생성
- 기존 계정 관리 (설정 보기, 공개키 재출력, 설정 재생성)
- 자동 생성 항목:
  - SSH 키 (ed25519)
  - GPG 키 (RSA 4096-bit)
  - `~/.gitconfig-{username}` (계정별 Git 설정)
  - `~/.ssh/config` 업데이트
  - `~/.gitconfig` includeIf 설정

**사용:**
```bash
./setup-account.sh
```

**상세 가이드:** [SSH_GPG_SETUP.md](SSH_GPG_SETUP.md)

---

#### `clone-repo.sh`
GitHub 레포지토리 대화형 클론 스크립트

**기능:**
- 계정 자동 탐지 (`~/github/` 폴더 기반)
- 개인/조직 레포 선택
- 다중 선택 지원 (fzf Tab 키)
- 중복 클론 자동 방지
- 자동 디렉토리 정리
  - 개인 레포: `~/github/{계정}/{레포}`
  - 조직 레포: `~/github/{계정}/{조직}/{레포}`

**사용:**
```bash
./clone-repo.sh
```

**상세 가이드:** [CLONE_GUIDE.md](CLONE_GUIDE.md)

---

### 📚 Documentation

#### `SSH_GPG_SETUP.md`
SSH & GPG 설정 완전 가이드

**내용:**
- SSH 키 생성 및 GitHub 등록
- GPG 키 생성 및 커밋 서명 설정
- Git 멀티 계정 설정 (includeIf)
- OS별 설정 방법 (Linux/macOS/Windows)
- 트러블슈팅

---

#### `CLONE_GUIDE.md`
레포지토리 클론 스크립트 사용 가이드

**내용:**
- clone-repo.sh 사용법
- gh/fzf 설치 방법
- 단계별 설명 (계정 선택 → 타입 선택 → 클론)
- 디렉토리 구조 설명
- 고급 기능 (다중 선택, 중복 방지)
- 트러블슈팅

---

#### `SETUP_GUIDE.md`
처음부터 끝까지 완전한 설정 가이드

**내용:**
- 전체 설정 프로세스
- 단계별 상세 설명
- 스크립트 + 수동 설정 모두 포함
- 검증 방법

---

## 📂 디렉토리 구조

```
~/github/
├── koalakid1/
│   ├── my-repo/              # 개인 레포
│   └── serengeti/            # 조직 레포
│       └── org-repo/
└── koalakid2/
    ├── work-repo/            # 개인 레포
    └── aifrica/              # 조직 레포
        └── company-repo/
```

**규칙:**
- 개인 레포: `~/github/{계정명}/{레포명}`
- 조직 레포: `~/github/{계정명}/{조직명}/{레포명}`

---

## 🔑 주요 기능

### 멀티 계정 지원
- 계정별 독립된 SSH/GPG 키
- 폴더별 자동 Git 설정 전환
- 계정별 커밋 서명

### 자동화
- SSH/GPG 키 자동 생성
- Git config 자동 설정
- 레포지토리 자동 분류 및 클론

### 사용 편의성
- fzf 기반 대화형 인터페이스
- 이전 단계 돌아가기 지원
- 기존 설정 자동 감지

---

## 📚 상세 가이드

### 📖 [SSH & GPG 설정 가이드](SSH_GPG_SETUP.md)
- SSH 키 생성 및 등록
- GPG 키 생성 및 서명 설정
- Git 설정 방법
- 트러블슈팅

### 📖 [레포지토리 클론 가이드](CLONE_GUIDE.md)
- clone-repo.sh 사용법
- gh/fzf 설치 방법
- 고급 기능 설명

### 📖 [전체 설정 가이드](SETUP_GUIDE.md)
- 처음부터 끝까지 완전한 설정 가이드
- 단계별 상세 설명

---

## 💡 편의 기능

### Alias 설정 (선택사항)

스크립트를 어디서든 실행하려면 `~/.bashrc` 또는 `~/.zshrc`에 추가:

```bash
# koalakid-toolbox git aliases
alias install-tools='~/github/koalakid1/koalakid-toolbox/git/install-required-tools.sh'
alias setup-account='~/github/koalakid1/koalakid-toolbox/git/setup-account.sh'
alias clone-repo='~/github/koalakid1/koalakid-toolbox/git/clone-repo.sh'
```

적용:
```bash
source ~/.bashrc  # 또는 source ~/.zshrc
```

이후 어디서든:
```bash
clone-repo        # 레포 클론
setup-account     # 계정 설정
install-tools     # 도구 설치
```

---

## 🛠️ 요구사항

### 필수 도구
- **ssh-keygen** (OpenSSH)
- **gpg** (GnuPG)
- **git**

### 권장 도구
- **gh** (GitHub CLI) - 레포 목록 조회용
- **fzf** - 대화형 선택용

---

## 🔄 설정 흐름

```
1. install-required-tools.sh
   ↓
2. setup-account.sh (각 계정마다)
   ↓
3. GitHub에 SSH/GPG 키 등록
   ↓
4. gh auth login (각 계정마다)
   ↓
5. clone-repo.sh (레포 클론)
```

---

## 🐛 트러블슈팅

### 계정이 목록에 안 나타남
```bash
# 계정 폴더가 없는 경우
mkdir -p ~/github/username
./setup-account.sh
```

### SSH 연결 실패
```bash
# SSH 키 권한 확인
chmod 600 ~/.ssh/id_ed25519_*
chmod 600 ~/.ssh/config

# 연결 테스트
ssh -T git@github-username
```

### gh CLI 인증 오류
```bash
# 계정 전환
gh auth switch -h github.com -u username

# 재로그인
gh auth login
```

더 많은 트러블슈팅은 [SSH_GPG_SETUP.md](SSH_GPG_SETUP.md#트러블슈팅) 참조

---

## 📝 라이선스

MIT License

---

## 👤 작성자

koalakid

**작성일:** 2025-10-07
**버전:** 1.0.0
