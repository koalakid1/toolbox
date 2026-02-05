# setup-ssh-profile.sh 기술 문서

## 목적
iTerm2에 SSH Profile 자동 생성 스크립트. 고객사 등에서 받은 서버 접속 정보를 쉽게 등록하기 위한 도구.

## 인증 방식 지원
1. **Password** - 비밀번호 인증
2. **PEM Key** - 키 파일 인증 (비밀번호 있음/없음 지원)

## 스크립트 흐름

### 1단계: 기본 정보 입력
- 서버 주소 (host 또는 IP)
- 사용자명
- 포트 (기본값: 22)
- Profile 이름

### 2단계: 인증 방식 선택
- fzf로 대화형 선택

### 3단계: 인증 정보 입력
- **Password**: 비밀번호 입력 (hidden)
- **PEM Key**: 키 파일 경로 + 비밀번호 (선택)

### 4단계: Expect 스크립트 생성
- `~/.iterm2-ssh-scripts/{profile_name}.sh` 생성
- SSH 연결 + 비밀번호 자동 입력 처리

### 5단계: iTerm2 Dynamic Profile 생성
- `~/Library/Application Support/iTerm2/DynamicProfiles/SSH Profiles.json`
- iTerm2 재시작 시 자동 로드

## 생성되는 파일

### 1. 연결 스크립트
**위치:** `~/.iterm2-ssh-scripts/{profile_name}.sh`

**Password 방식** (expect 스크립트):
```tcl
#!/usr/bin/expect -f
set timeout 30
spawn ssh -p 22 user@server
expect {
    "password:" {
        send "password\r"
        interact
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof {
        exit
    }
    timeout {
        puts "Connection timed out"
        exit 1
    }
}
```

**PEM Key (비밀번호 있음)** (expect 스크립트):
```tcl
#!/usr/bin/expect -f
set timeout 30
spawn ssh -p 22 -i ~/.ssh/key.pem user@server
expect {
    "Enter passphrase" {
        send "key_password\r"
        expect {
            "password:" {
                send "key_password\r"
                interact
            }
            eof {
                exit
            }
        }
    }
    "password:" {
        send "key_password\r"
        interact
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof {
        exit
    }
    timeout {
        puts "Connection timed out"
        exit 1
    }
}
```

**PEM Key (비밀번호 없음)** (일반 bash 스크립트):
```bash
#!/usr/local/bin/bash
ssh -p 22 -i ~/.ssh/key.pem user@server
```

### 2. iTerm2 Dynamic Profile
**위치:** `~/Library/Application Support/iTerm2/DynamicProfiles/SSH Profiles.json`

```json
{
  "Profiles": [
    {
      "Name": "production-server",
      "Command": "~/.iterm2-ssh-scripts/production-server.sh",
      "Custom Command": "Yes"
    }
  ]
}
```

## 에러 처리

### 필수 정보 누락
```bash
if [ -z "$server" ] || [ -z "$username" ]; then
    echo "❌ 필수 정보를 모두 입력해주세요."
    exit 1
fi
```

### PEM Key 파일 없음
```bash
if [ ! -f "$key_path" ]; then
    echo "❌ Key 파일을 찾을 수 없습니다: $key_path"
    exit 1
fi
```

### Expect 패턴 매칭 순서
expect는 여러 패턴을 순차적으로 검사하므로 순서가 중요함:

1. **구체적인 패턴 먼저** - "Enter passphrase"가 "password:"보다 먼저 와야 함
2. **yes/no 처리** - host key 확인을 위한 `"yes/no"` 패턴 + `exp_continue`
3. **exp_continue** - 패턴 매칭 후 다시 expect 블록 시작으로 돌아감
4. **interact** - 세션 제어를 사용자에게 반환 (없으면 연결 후 바로 종료됨)

### expect 블록 구조
```tcl
expect {
    "pattern1" {
        # 패턴1 매칭 시 실행
        action1
    }
    "pattern2" {
        # 패턴2 매칭 시 실행
        action2
    }
    eof {
        # 연결 종료 시
        exit
    }
    timeout {
        # 30초 타임아웃 시
        puts "Connection timed out"
        exit 1
    }
}
```

## 보안 고려사항

### 현재 구현의 보안 문제
- 비밀번호가 평문으로 스크립트에 저장됨
- 누군가 `~/.iterm2-ssh-scripts/`를 읽으면 비밀번호 노출

### 개선 방안 (향후)
1. macOS Keychain 연동
2. 1Password 등 비밀번호 관리자 연동
3. 별도 암호화 저장소

## 사용자 경험

### fzf 대화형 선택
```bash
auth_type=$(echo -e "Password\nPEM Key" | fzf --height 40%)
```

### 숨겨진 입력 (비밀번호)
```bash
read -s -p "비밀번호: " password
echo ""
```

### 자동 완료 안내
```
✅ Profile이 생성되었습니다!

사용 방법:
  1. iTerm2 재시작 (⌘+Q 후 다시 실행)
  2. ⌘+Shift+P 또는 메뉴 > Profiles > {profile_name} 선택
```

## 의존성
- `expect` (brew install expect)
- `fzf` (brew install fzf)
- `jq` (brew install jq) - Dynamic Profile JSON 병합용

## 수정 시 주의사항

### Expect 스크립트
- `interact`는 세션 제어를 사용자에게 반환 (없으면 연결 후 바로 종료)
- `\r`은 개행 문자 (Enter 키)
- `timeout` 설정으로 무한 대기 방지 (기본 30초)
- `exp_continue`는 패턴 매칭 후 다시 expect 블록 시작으로 돌아감
- **중요**: "Enter passphrase"가 "password:"보다 먼저 와야 함 (구체적 패턴 우선)

### Dynamic Profile JSON
- 이미 파일이 존재하면 `jq`로 병합
- 처음이면 새 JSON 생성
- 잘못된 JSON은 iTerm2 시작 시 모든 Profile 무시
- `Command`는 스크립트 파일의 전체 경로
- `Custom Command`는 `"Yes"` 리터럴 값

## 테스트 시나리오

### 1. Password 방식
- 입력: server, user, password
- 예상: 스크립트 생성 + Profile 등록 + 연결 성공

### 2. PEM Key (비밀번호 없음)
- 입력: server, user, key.pem
- 예상: 비밀번호 없이 바로 연결

### 3. PEM Key (비밀번호 있음)
- 입력: server, user, key.pem, key_password
- 예상: 키 비밀번호 입력 후 연결

### 4. 중복 Profile 이름
- 현재: 덮어쓰기
- 개선 필요: 중복 체크 후 사용자 확인
