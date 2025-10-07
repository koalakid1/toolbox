# koalakid-toolbox Context

> 📌 Template Version: 1.0.0 (기반: ~/github/koalakid1/toolbox/claude-template/)

---

## 📋 프로젝트 정보

**프로젝트명:** koalakid-toolbox
**설명:** 개발 작업에 필요한 자동화 스크립트 및 도구 모음
**기술 스택:** Bash, Git, SSH, GPG, fzf

---

## 🏷️ 프로세스별 필수 참고 문서

작업 시 태그 사용하면 관련 문서 자동 참조

### [스크립트 수정]
- `.claude/info/bash-patterns.md` - Bash 스크립트 패턴 및 규칙

---

## 🔍 규칙 추가 프로세스

### 명령어

```
[규칙 추가] {카테고리} - {규칙 내용}
```

### 자동 실행

#### 1단계: 중복 체크
- 키워드 추출 및 기존 파일 비교
- 유사도 50%+ 시 알림

#### 2단계: 유사 규칙 발견 시

```
⚠️ 유사한 규칙이 이미 존재합니다!

기존: [{카테고리}] - .claude/info/{파일명}.md
키워드 일치: "{키워드1}", "{키워드2}"

📋 현재 규칙 요약:
  • 항목 1
  • 항목 2

🆕 새로운 내용: "{규칙}"

선택하세요:
1️⃣ 기존 파일에 추가
2️⃣ 새 파일 생성
3️⃣ 취소
```

#### 3단계: 처리
- **1️⃣**: 기존 파일 업데이트
- **2️⃣**: 새 파일 생성 + context.md 태그 추가
- **3️⃣**: 취소

### 키워드 매칭

| 카테고리 | 키워드 | 파일명 |
|----------|--------|--------|
| Git | git, commit, branch, merge, pr | git-*.md |
| 코드 | code, function, class, refactor | coding-*.md |
| 테스트 | test, jest, unit, e2e | testing-*.md |
| 배포 | deploy, release, build, ci, cd | deployment-*.md |
| 문서 | doc, readme, comment | documentation-*.md |
| API | api, rest, graphql, endpoint | api-*.md |
| DB | db, database, sql, query | database-*.md |
| 보안 | security, auth, 인증, 권한 | security-*.md |
| 스크립트 | bash, shell, script | bash-*.md, script-*.md |

**유사도 판단:**
- 키워드 2개+ 일치
- 태그명 50%+ 유사
- 파일명 패턴 일치

---

## 📌 추가 태그 시스템

확장 가능한 태그 예시:

### 작업 유형
- `[추가]` - 새 기능
- `[수정]` - 코드 수정
- `[삭제]` - 코드 제거
- `[리팩토링]` - 리팩토링

### 우선순위
- `[긴급]` - 긴급
- `[중요]` - 중요
- `[일반]` - 일반

---

## 📂 프로젝트 구조

```
toolbox/
├── .claude/                    # toolbox 전용 Claude 설정
│   ├── context.md              # 이 파일 (자동 프롬프팅)
│   ├── info/
│   │   └── bash-patterns.md    # Bash 패턴
│   ├── README.md
│   └── RULE-SYSTEM-GUIDE.md
├── claude-template/            # 전역 템플릿 (재사용)
│   ├── context.md.template
│   ├── README.md
│   └── RULE-SYSTEM-GUIDE.md
├── git/                        # GitHub 멀티 계정 관리
│   ├── *.sh                    # 스크립트
│   ├── *.claude.md             # 기술 문서
│   └── *.md                    # 사용자 가이드
└── README.md
```

---

## ⚠️ 파일 수정 시 필수 규칙

### 스크립트 수정 전 반드시 참고 문서 읽기

| 수정 대상 | 필수 참고 문서 |
|-----------|----------------|
| `git/clone-repo.sh` | `git/clone-repo.claude.md` |
| `git/setup-account.sh` | `git/setup-account.claude.md` |
| `git/install-required-tools.sh` | `git/install-required-tools.claude.md` |

**이유:**
- 스크립트 의도 및 전체 흐름 파악
- 에러 처리 로직 이해
- 기존 패턴 유지
- 사이드 이펙트 방지

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

## 💻 주요 코딩 규칙

### Bash 스크립트

상세 내용: `.claude/info/bash-patterns.md`

**핵심 패턴:**
```bash
# ✅ fzf 파이프라인
selected=$({ printf '%s\n' "${array[@]}"; echo "옵션"; } | fzf)

# ✅ 경로
base_dir="$HOME/github"  # $HOME 사용

# ✅ 배열
mapfile -t arr < <(command)
for item in "${arr[@]}"; do ...; done
```

### Git 설정

**URL 재작성 (insteadOf):**
```ini
[url "git@github-{username}:"]
    insteadOf = git@github.com:
```

**includeIf (폴더별 계정 전환):**
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

---

## 📝 문서 구조

### 사용자용 vs 개발자용

**사용자용** (README, GUIDE):
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

사용자 요청 → `context.md` 자동 읽음 (이 파일) → 해당 `.claude.md` 읽기 → 정확한 수정

**예시:**
1. 사용자: "clone-repo.sh에 브랜치 선택 기능 추가"
2. Claude: context.md 확인 → "clone-repo.claude.md를 먼저 읽어야 함"
3. Claude: `git/clone-repo.claude.md` 읽기
4. Claude: 기존 로직 이해 후 정확한 위치에 기능 추가

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
