# S3cmd 설정 관리 도구

> 🪣 여러 S3 환경을 심볼릭 링크 방식으로 관리하는 대화형 도구 모음

---

## 📋 목차

- [개요](#-개요)
- [주요 기능](#-주요-기능)
- [사전 요구사항](#-사전-요구사항)
- [설치](#-설치)
- [사용법](#-사용법)
- [폴더 구조](#-폴더-구조)
- [트러블슈팅](#-트러블슈팅)

---

## 🎯 개요

S3cmd 설정 관리 도구는 여러 S3 환경 (dev/staging/prod, 여러 회사, 여러 버킷)을 쉽게 관리할 수 있도록 도와주는 Bash 스크립트 모음입니다.

### 핵심 개념

- **독립 설정 파일**: `~/s3cfg/` 폴더에 `{company}-{env}-{bucket}` 형식의 설정 파일 생성
- **심볼릭 링크 전환**: `~/.s3cfg` → 원하는 설정 파일로 심볼릭 링크를 생성하여 전환
- **fzf 대화형 UI**: Git 도구처럼 예쁜 preview와 함께 선택 가능

---

## ✨ 주요 기능

### 1. **설정 생성** (`setup-s3-config.sh`)
- 대화형으로 S3 설정 파일 생성
- 회사명, 환경, 버킷명 기반 구조화된 이름
- fzf preview로 기존 설정 확인

### 2. **설정 전환** (`switch-s3.sh`)
- 심볼릭 링크로 빠른 전환
- 현재 활성 설정 표시
- 전환 후 연결 테스트 옵션

### 3. **설정 목록** (`list-s3-configs.sh`)
- 전체 설정 목록 조회
- 상세 정보 preview
- 설정 전환/삭제 가능

### 4. **설정 삭제** (`remove-s3-config.sh`)
- 안전한 삭제 (확인 절차)
- 삭제 전 백업 옵션
- 활성 설정 삭제 시 추가 경고

---

## 📦 사전 요구사항

### 필수 도구

```bash
# s3cmd
sudo apt install s3cmd  # Ubuntu/Debian
brew install s3cmd      # macOS

# fzf (대화형 선택)
sudo apt install fzf    # Ubuntu/Debian
brew install fzf        # macOS
```

### 버전 확인

```bash
s3cmd --version
fzf --version
```

---

## 🚀 설치

### 1. 저장소 클론 (이미 있으면 생략)

```bash
git clone https://github.com/yourusername/toolbox.git ~/github/yourusername/toolbox
```

### 2. s3cmd 도구로 이동

```bash
cd ~/github/yourusername/toolbox/s3cmd
```

### 3. 실행 권한 확인

```bash
ls -la *.sh
# 모두 실행 권한(-x)이 있어야 함
```

---

## 💻 사용법

### 1️⃣ 첫 번째 설정 생성

```bash
./setup-s3-config.sh
```

**대화형 단계:**

1. **회사 선택**
   - 기존 회사 목록에서 선택 또는 새로 입력
   ```
   회사> cheetah
   ```

2. **환경 선택**
   - dev, staging, prod 또는 직접 입력
   ```
   환경> dev
   ```

3. **버킷 정보 입력**
   ```
   버킷명: serengeti
   ```

4. **인증 정보 입력**
   ```
   Access Key: O0IC...
   Secret Key: ****
   Host Base: cheetah.dev2.aifrica.co.kr
   HTTPS 사용? (y/n, 기본 y): y
   Signature v2 사용? (y/n, 기본 y): y
   ```

5. **설정 확인 및 생성**
   - fzf preview로 설정 내용 확인
   - `✅ 생성` 선택

6. **자동 전환 옵션**
   ```
   지금 바로 이 설정으로 전환하시겠습니까? (y/n): y
   ```

**결과:**
```
✅ 설정 생성 완료!

📁 파일: ~/s3cfg/cheetah-dev-serengeti
🏷️  이름: cheetah-dev-serengeti

✅ 설정이 전환되었습니다!
현재 활성 설정: cheetah-dev-serengeti
```

---

### 2️⃣ 설정 전환

```bash
./switch-s3.sh
```

**화면:**
```
📌 현재 설정: cheetah-dev-serengeti

━━━ 전환할 S3 설정을 선택하세요 ━━━

  cheetah-dev-serengeti
  cheetah-prod-serengeti
  lion-staging-analytics
```

**fzf preview (오른쪽):**
```
┌─────────────────────────────────┐
│  S3 설정 상세 정보              │
└─────────────────────────────────┘

🏷️  이름: cheetah-prod-serengeti

🔐 인증:
   Access Key: O0IC1234***XYZ

🌐 엔드포인트:
   Host: cheetah.prod.aifrica.co.kr
   HTTPS: True

📋 전환 후 사용 예시:
   s3cmd ls
   s3cmd get s3://serengeti/file.txt
```

**선택 후:**
```
✅ 설정 전환 완료!

🔗 활성 설정: cheetah-prod-serengeti
📁 ~/.s3cfg -> ~/s3cfg/cheetah-prod-serengeti

💡 사용법:
   s3cmd ls
   s3cmd ls s3://serengeti

연결 테스트를 하시겠습니까? (y/n): y

🔍 버킷 목록 조회 중...
2024-10-10 13:00  s3://serengeti

✅ 연결 성공!
```

---

### 3️⃣ 설정 목록 조회

```bash
./list-s3-configs.sh
```

**화면:**
```
📋 S3 설정 목록

━━━ S3 설정 목록 (Ctrl-R: 새로고침) ━━━

✅ cheetah-dev-serengeti (활성)
   cheetah-prod-serengeti
   lion-staging-analytics
```

**선택 후 작업:**
```
📌 선택된 설정: cheetah-prod-serengeti

작업>
  🔄 이 설정으로 전환
  📝 설정 파일 보기
  🗑️  설정 삭제
  ❌ 종료
```

---

### 4️⃣ 설정 삭제

```bash
./remove-s3-config.sh
```

**주의사항:**
- 활성 설정 삭제 시 추가 확인 필요
- 삭제 전 백업 옵션 제공
- 삭제 후 복구 불가

---

### 5️⃣ S3cmd 사용

설정 전환 후에는 일반 `s3cmd` 명령어 사용:

```bash
# 버킷 목록
s3cmd ls

# 특정 버킷의 파일 목록
s3cmd ls s3://serengeti

# 파일 다운로드
s3cmd get s3://serengeti/data.csv ./

# 파일 업로드
s3cmd put ./local.txt s3://serengeti/

# 폴더 동기화
s3cmd sync ./local-folder/ s3://serengeti/remote-folder/

# 재귀적 삭제
s3cmd del --recursive s3://serengeti/old-data/
```

---

## 📂 폴더 구조

```
~/s3cfg/                             # S3 설정 폴더
├── cheetah-dev-serengeti            # 설정 파일 (회사-환경-버킷)
├── cheetah-prod-serengeti
├── lion-staging-analytics
├── cheetah-dev-serengeti.backup.20241010_130000  # 백업 파일
└── ...

~/.s3cfg                             # 심볼릭 링크 (현재 활성 설정)
~/.s3cfg.backup.20241010_130000      # 기존 .s3cfg 백업 (자동 생성)
```

**명명 규칙:**
```
~/s3cfg/{company}-{environment}-{bucket}

예시:
~/s3cfg/cheetah-dev-serengeti
~/s3cfg/cheetah-prod-serengeti
~/s3cfg/lion-staging-analytics
```

---

## 🔧 고급 사용법

### 설정 전환 없이 직접 사용

특정 설정 파일을 직접 지정하여 s3cmd 실행:

```bash
s3cmd -c ~/s3cfg/cheetah-prod-serengeti ls s3://serengeti
```

### 현재 활성 설정 확인

```bash
ls -l ~/.s3cfg
# lrwxrwxrwx ... /home/user/.s3cfg -> /home/user/s3cfg/cheetah-dev-serengeti
```

### 수동 설정 전환

```bash
ln -sf ~/s3cfg/cheetah-prod-serengeti ~/.s3cfg
```

### 설정 파일 직접 수정

```bash
vi ~/s3cfg/cheetah-dev-serengeti
```

---

## 🐛 트러블슈팅

### 1. `s3cmd` 명령어를 찾을 수 없음

**증상:**
```
bash: s3cmd: command not found
```

**해결:**
```bash
# Ubuntu/Debian
sudo apt install s3cmd

# macOS
brew install s3cmd
```

---

### 2. `fzf` 명령어를 찾을 수 없음

**증상:**
```
bash: fzf: command not found
```

**해결:**
```bash
# Ubuntu/Debian
sudo apt install fzf

# macOS
brew install fzf
```

---

### 3. 연결 실패: `ERROR: Access denied`

**증상:**
```
ERROR: Access denied: mybucket
```

**원인:**
- Access Key / Secret Key 오류
- 버킷 권한 없음

**해결:**
```bash
# 1. 설정 파일 확인
cat ~/s3cfg/cheetah-dev-serengeti | grep -E "(access_key|secret_key|host_base)"

# 2. 올바른 인증 정보로 재생성
./setup-s3-config.sh
```

---

### 4. 심볼릭 링크가 깨짐

**증상:**
```
ls: cannot access '~/.s3cfg': No such file or directory
```

**원인:**
- 활성 설정 파일이 삭제됨

**해결:**
```bash
# 설정 전환
./switch-s3.sh
```

---

### 5. 기존 `.s3cfg` 파일이 덮어써짐

**원인:**
- 심볼릭 링크 아닌 일반 파일이 있었음

**해결:**
```bash
# 백업 파일 확인
ls ~/.s3cfg.backup.*

# 필요하면 복원
cp ~/.s3cfg.backup.20241010_130000 ~/.s3cfg
```

---

## 💡 팁

### 1. 빠른 전환

자주 사용하는 설정이면 alias 추가:

```bash
# ~/.bashrc 또는 ~/.zshrc
alias s3-dev='ln -sf ~/s3cfg/cheetah-dev-serengeti ~/.s3cfg'
alias s3-prod='ln -sf ~/s3cfg/cheetah-prod-serengeti ~/.s3cfg'
```

### 2. 현재 설정 프롬프트 표시

```bash
# ~/.bashrc
show_s3_config() {
    if [ -L ~/.s3cfg ]; then
        basename $(readlink ~/.s3cfg) | sed 's/^/[S3: /;s/$/]/'
    fi
}

PS1="\$(show_s3_config) $PS1"
```

결과:
```
[S3: cheetah-dev-serengeti] user@host:~$
```

### 3. 여러 터미널에서 다른 설정 사용

심볼릭 링크 대신 직접 지정:

```bash
# Terminal 1 (dev)
s3cmd -c ~/s3cfg/cheetah-dev-serengeti ls

# Terminal 2 (prod)
s3cmd -c ~/s3cfg/cheetah-prod-serengeti ls
```

---

## 📚 관련 문서

- `setup-s3-config.claude.md` - 기술 문서 (개발자/AI용)
- [s3cmd 공식 문서](https://s3tools.org/s3cmd)
- [fzf GitHub](https://github.com/junegunn/fzf)

---

## 🤝 기여

버그 리포트 및 개선 제안은 GitHub Issues로 부탁드립니다.

---

**Made with ❤️ by koalakid**

---

## ⚡ 빠른 실행 (Aliases)

### 설정 방법

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
source ~/github/koalakid1/toolbox/s3cmd/.aliases
```

### 사용 가능한 명령어

```bash
s3setup      # S3 설정 생성
s3switch     # S3 설정 전환
s3list       # S3 설정 목록
s3rm         # S3 설정 삭제
s3current    # 현재 활성 설정 확인
```

### 예시

```bash
# 설정 생성
s3setup

# 설정 전환
s3switch

# 현재 설정 확인
s3current
# → /home/user/s3cfg/cheetah-dev-serengeti
```
