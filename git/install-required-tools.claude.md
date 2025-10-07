# install-required-tools.sh

GitHub 계정 설정에 필요한 필수 도구(ssh-keygen, gpg, git)의 설치 여부를 확인하고, 미설치 시 OS별 설치 방법을 안내하는 스크립트입니다.

## 목적

- setup-account.sh 실행 전 필수 도구 설치 확인
- OS별(Linux/macOS/Windows) 맞춤 설치 명령어 제공
- 이미 설치된 경우 버전 정보 표시

## 주요 기능

1. **도구 감지**: ssh-keygen, gpg, git 설치 여부 확인
2. **OS 자동 감지**: Linux, macOS, Windows(Git Bash) 구분
3. **설치 안내**: OS별 패키지 매니저 명령어 제공
4. **버전 확인**: 설치된 도구의 버전 정보 출력

## 사용법

```bash
./install-required-tools.sh
```

## 출력 예시

### 모든 도구 설치됨
```
✅ 모든 필수 도구가 이미 설치되어 있습니다!

설치된 도구:
  ✓ ssh-keygen: OpenSSH_8.9p1
  ✓ gpg: gpg (GnuPG) 2.2.27
  ✓ git: git version 2.34.1

💡 이제 setup-account.sh를 실행할 수 있습니다:
   ./setup-account.sh
```

### 도구 미설치 시 (Ubuntu/Debian)
```
❌ 다음 도구들이 설치되지 않았습니다:
   - gpg

📦 Linux 설치 명령어:

# Ubuntu/Debian:
sudo apt update && sudo apt install -y gnupg
```

## 기술적 세부사항

### OS 감지 로직
```bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    os_type="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    os_type="mac"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    os_type="windows"
fi
```

### 도구 체크
```bash
if ! command -v ssh-keygen &> /dev/null; then
    missing_tools+=("ssh-keygen")
fi
```

## 패키지 매핑

| 도구 | Ubuntu/Debian | Fedora/RHEL | macOS | Windows |
|------|---------------|-------------|-------|---------|
| ssh-keygen | openssh-client | openssh | 기본 포함 | Git Bash 포함 |
| gpg | gnupg | gnupg | gnupg (brew) | Gpg4win |
| git | git | git | git (brew) | Git for Windows |

## 종료 코드

- `0`: 모든 도구 설치됨
- 설치 안내 후 대기 (사용자가 설치 진행)

## 관련 파일

- `setup-account.sh` - 이 스크립트 실행 후 사용
- `README.md` - 전체 도구 설명
