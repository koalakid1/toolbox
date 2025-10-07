# koalakid-toolbox Context

개발 작업에 필요한 자동화 스크립트 및 도구 모음

---

## ⚠️ 중요: 파일 수정 시 필수 규칙

### 스크립트 수정 전 반드시 참고 문서 읽기

각 스크립트를 수정하기 전에 **반드시** 해당 `.claude.md` 파일을 먼저 읽어야 합니다.

| 수정 대상 | 필수 참고 문서 |
|-----------|----------------|
| `git/clone-repo.sh` | `git/clone-repo.claude.md` |
| `git/setup-account.sh` | `git/setup-account.claude.md` |
| `git/install-required-tools.sh` | `git/install-required-tools.claude.md` |

**이유:**
- 스크립트의 의도와 전체 흐름 파악
- 에러 처리 로직 이해
- 기존 패턴 유지
- 사이드 이펙트 방지

---

## 📂 프로젝트 구조

```
toolbox/
├── .claude/
│   ├── context.md          # 이 파일 (자동 프롬프팅)
│   └── README.md           # .claude 폴더 설명
├── README.md               # toolbox 소개
└── git/                    # GitHub 멀티 계정 관리 도구
    ├── README.md           # 사용자용 가이드
    ├── *.sh                # 실행 스크립트
    ├── *.claude.md         # 개발자/AI용 상세 기술 문서
    └── *_GUIDE.md          # 사용자용 상세 가이드
```

---

## 🔧 git/ 도구 개요

### 목적
GitHub 멀티 계정 환경에서 계정별 SSH/GPG 키 관리 및 레포지토리 자동 클론

### 핵심 개념
- **계정 분리**: `~/github/{username}/` 폴더 구조
- **자동 전환**: Git의 `includeIf`로 폴더별 자동 계정 전환
- **SSH 별칭**: `git@github-{username}:` 패턴
- **대화형 UI**: fzf 기반 선택 인터페이스

### 주요 스크립트
1. **install-required-tools.sh**: 필수 도구(ssh-keygen, gpg, git) 설치 확인
2. **setup-account.sh**: SSH/GPG 키 생성 및 Git 설정 자동화
3. **clone-repo.sh**: 대화형 레포지토리 클론 (계정/조직/레포 선택)

---

## 💻 코딩 규칙

### Bash 스크립트

#### fzf 파이프라인
```bash
# ✅ 올바른 패턴
selected=$({ printf '%s\n' "${array[@]}"; echo "옵션"; } | fzf)

# ❌ 잘못된 패턴 (배열이 제대로 전달 안 됨)
selected=$(printf '%s\n' "${array[@]}" && echo "옵션" | fzf)
```

#### 경로 사용
```bash
# 항상 $HOME 사용 (현재 위치 무관)
github_base="$HOME/github"

# 상대 경로 사용 금지
github_base="~/github"  # ❌
```

#### 배열 처리
```bash
# mapfile 사용
mapfile -t accounts < <(find "$github_base" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)

# 배열 순회
for account in "${accounts[@]}"; do
    echo "$account"
done
```

### Git 설정

#### URL 재작성 (insteadOf)
`~/.gitconfig-{username}`:
```ini
[url "git@github-{username}:"]
    insteadOf = git@github.com:
```

실제 동작:
```bash
git clone git@github.com:user/repo.git
# → git@github-{username}:user/repo.git 으로 자동 변환
```

#### includeIf (폴더별 계정 전환)
`~/.gitconfig`:
```ini
[includeIf "gitdir:~/github/{username}/"]
    path = ~/.gitconfig-{username}
```

---

## 🧪 테스트 지침

### 스크립트 수정 후
1. 문법 체크: `bash -n script.sh`
2. 실행 테스트 제안
3. 주요 시나리오 확인:
   - 계정 선택
   - fzf 다중 선택 (Tab 키)
   - 이전 단계 돌아가기
   - 중복 방지

### 주의사항
- fzf는 대화형이므로 자동 테스트 불가
- 타임아웃 고려 (`inappropriate ioctl for device` 에러)

---

## 📝 문서 구조

### 사용자용 vs 개발자용

**사용자용** (일반 README, GUIDE):
- 사용법 중심
- 예시와 스크린샷
- 트러블슈팅

**개발자/AI용** (`.claude.md`):
- 기술적 세부사항
- 코드 패턴 설명
- 에러 처리 로직
- 내부 동작 원리

---

## 🎯 작업 흐름

사용자 요청 → `.claude/context.md` 자동 읽음 (이 파일) → 해당 `.claude.md` 읽기 → 정확한 수정

**예시:**
1. 사용자: "clone-repo.sh에 브랜치 선택 기능 추가해줘"
2. Claude: context.md 확인 → "clone-repo.claude.md를 먼저 읽어야 함"
3. Claude: `git/clone-repo.claude.md` 읽기
4. Claude: 기존 로직 이해 후 정확한 위치에 기능 추가

---

## 🔐 보안 주의사항

- 개인키(`id_ed25519_*`) 절대 커밋 금지
- GPG 개인키 백업 권장
- `.gitignore`에 SSH/GPG 키 경로 추가 불필요 (홈 디렉토리에 위치)

---

## 📌 향후 추가 예정

- `docker/` - Docker 환경 설정 도구
- `db/` - 데이터베이스 관리 스크립트
- `deploy/` - 배포 자동화
- `backup/` - 백업 도구

각 도구 추가 시:
1. 폴더 생성: `toolbox/{tool}/`
2. 스크립트 작성
3. `.claude.md` 작성 (기술 문서)
4. `README.md` 작성 (사용자 가이드)
5. 이 파일(context.md)에 항목 추가
