# setup-account.sh

GitHub 멀티 계정을 위한 SSH 키, GPG 키, Git 설정을 자동으로 생성하고 관리하는 대화형 스크립트입니다.

## 목적

- 계정별 독립된 SSH/GPG 키 생성
- Git 설정 자동화 (폴더별 계정 전환)
- 기존 계정 관리 (보기, 재생성, 공개키 재출력)

## 주요 기능

### 1. 필수 도구 체크
- ssh-keygen, gpg, git 설치 확인
- 미설치 시 `install-required-tools.sh` 실행 안내 후 종료

### 2. 기존 계정 탐지
- `~/github/` 폴더에서 계정 디렉토리 자동 탐지
- `.gitconfig-{username}` 파일에서 이메일/이름 정보 로드

### 3. 작업 선택 (fzf)
- **신규 계정 생성**: 새 계정 설정
- **기존 계정 관리**: 설정 보기, 공개키 재출력, 재생성

### 4. 자동 생성 항목

#### SSH 키
- **형식**: ed25519
- **위치**: `~/.ssh/id_ed25519_{username}`
- **SSH config**: `~/.ssh/config`에 Host 추가

```
Host github-{username}
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_{username}
    IdentitiesOnly yes
```

#### GPG 키
- **형식**: RSA 4096-bit
- **만료**: 2년
- **용도**: 커밋 서명

#### Git 설정
- **계정별 config**: `~/.gitconfig-{username}`
  ```
  [user]
      name = {fullname}
      email = {email}
      signingkey = {GPG_KEY_ID}
  [commit]
      gpgSign = true
  [url "git@github-{username}:"]
      insteadOf = git@github.com:
  ```

- **전역 config**: `~/.gitconfig`에 includeIf 추가
  ```
  [includeIf "gitdir:~/github/{username}/"]
      path = ~/.gitconfig-{username}
  ```

#### 디렉토리
- `~/github/{username}/` 생성

## 사용법

```bash
./setup-account.sh
```

## 사용 흐름

### 신규 계정 생성
```
1. 작업 선택: "신규 계정 생성"
2. 정보 입력:
   - GitHub 사용자명
   - 이메일
   - 실제 이름
3. 확인
4. 자동 생성:
   - SSH 키
   - GPG 키 (약 30초 소요)
   - Git config 파일들
5. 공개키 출력 (GitHub 등록용)
```

### 기존 계정 관리
```
1. 작업 선택: "기존 계정 관리"
2. 계정 선택 (fzf)
3. 관리 작업 선택:
   - 기존 설정 보기
   - 공개키 다시 출력 (GitHub 재등록용)
   - 설정 덮어쓰기 (재생성)
```

## 출력 예시

### 계정 생성 완료
```
✅ 계정 설정 완료!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 설정 요약:
  GitHub 사용자명: koalakid1
  이메일: koalakid154@gmail.com
  이름: koalakid
  SSH 키: /home/user/.ssh/id_ed25519_koalakid1
  GPG 키 ID: 134994D3F1D7E369
  Git config: /home/user/.gitconfig-koalakid1
  디렉토리: /home/user/github/koalakid1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 다음 단계:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  SSH 공개키를 GitHub에 등록하세요:
   https://github.com/settings/keys

=== SSH 공개키 ===
ssh-ed25519 AAAAC3...

2️⃣  GPG 공개키를 GitHub에 등록하세요:
   https://github.com/settings/keys

=== GPG 공개키 ===
-----BEGIN PGP PUBLIC KEY BLOCK-----
...
-----END PGP PUBLIC KEY BLOCK-----

3️⃣  GitHub CLI에 로그인하세요:
   gh auth login

4️⃣  레포지토리 클론 스크립트 실행:
   cd ~/github
   ./clone-repo.sh
```

## 스마트 기능

### 중복 감지 및 선택
- 기존 SSH 키 발견 시: "기존 키 사용" 또는 "재생성" 선택
- 기존 GPG 키 발견 시: "기존 키 사용" 또는 "재생성" 선택
- 기존 Git config 발견 시: "유지" 또는 "덮어쓰기" 선택

### 안전 장치
- GPG 키 삭제 시 경고 및 재확인 (yes 입력 필요)
- 설정 덮어쓰기 시 확인 (yes 입력 필요)
- 기존 파일 백업 (타임스탬프 추가)

### 연결 테스트 (선택)
- SSH 연결 테스트: `ssh -T git@github-{username}`
- GPG 서명 테스트: `echo "test" | gpg --clearsign`

## 기술적 세부사항

### includeIf 동작 원리
Git은 현재 디렉토리가 `~/github/{username}/` 아래에 있을 때 자동으로 해당 계정의 설정을 적용합니다.

```bash
cd ~/github/koalakid1/my-repo
git config user.email  # → koalakid154@gmail.com

cd ~/github/koalakid2/work-repo
git config user.email  # → work@example.com
```

### URL 재작성 (insteadOf)
SSH config의 Host 별칭을 사용하기 위해 URL을 자동 변환합니다:

```bash
git clone git@github.com:user/repo.git
# 실제로는 이렇게 변환됨
git clone git@github-koalakid1:user/repo.git
```

## 종료 코드

- `0`: 성공
- `1`: 에러 (필수 도구 없음, 입력 오류 등)

## 생성되는 파일

- `~/.ssh/id_ed25519_{username}` - SSH 개인키
- `~/.ssh/id_ed25519_{username}.pub` - SSH 공개키
- `~/.ssh/config` - SSH 설정 (추가됨)
- `~/.gitconfig-{username}` - 계정별 Git 설정
- `~/.gitconfig` - 전역 Git 설정 (includeIf 추가됨)
- `~/github/{username}/` - 계정 디렉토리

## 관련 파일

- `install-required-tools.sh` - 필수 도구 설치
- `clone-repo.sh` - 레포지토리 클론
- `SSH_GPG_SETUP.md` - 상세 설정 가이드
