# Claude Template

새 프로젝트에서 Claude Code의 규칙 시스템을 사용하기 위한 템플릿입니다.

---

## 📦 포함 파일

```
claude-template/
├── CLAUDE.md.template       # 프로젝트 컨텍스트 템플릿 (자동 프롬프팅)
├── info/                    # 전역 규칙 파일들
│   ├── README.md
│   └── init-integration-guide.md
├── README.md                # 이 파일 (템플릿 사용법)
└── RULE-SYSTEM-GUIDE.md     # 규칙 시스템 완전 가이드
```

---

## 🚀 빠른 시작

### 방법 1: 자동 설치 (권장)

Claude Code에서 다음 명령어 입력:

```
[템플릿 설치] ~/your-project/path
```

**자동 실행:**
- ✅ `.claude/` 폴더 생성
- ✅ 템플릿 파일 복사
- ✅ 경로 검증 및 에러 처리
- ✅ 설치 후 가이드 제공

### 방법 2: 수동 설치

```bash
# 프로젝트 루트에 .claude 폴더 생성
mkdir -p your-project/.claude

# 템플릿 복사
cp claude-template/CLAUDE.md.template your-project/CLAUDE.md

# info 폴더 복사 (전역 규칙 포함)
mkdir -p your-project/.claude/info
cp -r claude-template/info/* your-project/.claude/info/

# (선택) 가이드 복사
cp claude-template/RULE-SYSTEM-GUIDE.md your-project/.claude/
```

### 2. 프로젝트 정보 수정

`your-project/CLAUDE.md` 파일 열어서:
- 프로젝트명, 설명, 기술 스택 입력
- 주석(`<!--`) 처리된 예시 제거
- 프로젝트별 내용 추가

### 3. 첫 규칙 추가

```
[규칙 추가] Git - 커밋 메시지는 conventional commits 형식 사용
```

---

## 💡 템플릿의 특징

### 순수한 규칙 시스템만 포함

이 템플릿에는 **프로젝트 무관한 기능**만 포함됩니다:
- ✅ `[규칙 추가]` 프로세스
- ✅ 태그 시스템 (`[코드 수정]`, `[테스트]` 등)
- ✅ 중복 규칙 체크 로직
- ✅ 키워드 매칭 기준
- ❌ 특정 프로젝트 규칙 (toolbox, Spring 등)

### 확장 가능

프로젝트별로 필요한 태그와 규칙을 자유롭게 추가할 수 있습니다.

---

## 📋 사용 시나리오

### 시나리오 1: Spring 프로젝트

```bash
# 1. 템플릿 복사
cp claude-template/CLAUDE.md.template my-spring/CLAUDE.md
mkdir -p my-spring/.claude/info
cp -r claude-template/info/* my-spring/.claude/info/

# 2. 프로젝트 정보 입력
# - 프로젝트명: My Spring App
# - 기술 스택: Spring Boot 3.0, JPA, PostgreSQL

# 3. Spring 규칙 추가
[규칙 추가] Spring - @Transactional은 Service 레이어에서만 사용
[규칙 추가] JPA - Entity는 기본 생성자 필수
[규칙 추가] 테스트 - @SpringBootTest는 통합 테스트에만 사용
```

### 시나리오 2: React 프로젝트

```bash
# 1. 템플릿 복사
cp claude-template/CLAUDE.md.template my-react/CLAUDE.md
mkdir -p my-react/.claude/info
cp -r claude-template/info/* my-react/.claude/info/

# 2. React 규칙 추가
[규칙 추가] React - 모든 컴포넌트는 함수형으로 작성
[규칙 추가] 코드 - Props는 TypeScript interface로 정의
[규칙 추가] 테스트 - Testing Library 사용, enzyme 금지
```

### 시나리오 3: Bash 스크립트 프로젝트

```bash
# toolbox 같은 경우
cp claude-template/CLAUDE.md.template toolbox/CLAUDE.md
mkdir -p toolbox/.claude/info
cp -r claude-template/info/* toolbox/.claude/info/

# Bash 규칙 추가
[규칙 추가] 스크립트 - fzf 파이프라인은 { } 그룹 명령 사용
[규칙 추가] 스크립트 - 경로는 $HOME 사용, ~ 금지
```

---

## 🔄 템플릿 업데이트

### 전역 규칙 추가 (모든 프로젝트 공통)

템플릿에 새 태그나 규칙 추가:

1. `claude-template/CLAUDE.md.template` 수정
2. 기존 프로젝트에 수동 반영 (필요시)

**예시: `[추가]`, `[수정]` 태그 추가**

```markdown
## 📌 추가 태그 시스템

### 작업 유형 태그:
- `[추가]` - 새 기능 추가 시
- `[수정]` - 기존 코드 수정 시
```

이제 모든 새 프로젝트에서 이 태그 사용 가능!

---

## 📚 문서 구조

### 템플릿 파일
- **context.md.template**: 프로젝트 컨텍스트 기본 구조
- **README.md**: 템플릿 사용법 (이 파일)
- **RULE-SYSTEM-GUIDE.md**: 규칙 시스템 상세 가이드

### 프로젝트별 파일 (복사 후 생성)
```
your-project/
├── CLAUDE.md               # 템플릿에서 복사 + 프로젝트 내용 추가 (자동 프롬프팅)
└── .claude/
    ├── info/               # 프로젝트별 규칙 파일들
    │   ├── coding-rules.md
    │   ├── git-workflow.md
    │   └── ...
    └── RULE-SYSTEM-GUIDE.md    # (선택) 가이드 복사
```

---

## 🎯 Best Practices

### ✅ 좋은 사용법

**1. 템플릿은 순수하게 유지**
- 특정 프로젝트 규칙은 템플릿에 추가하지 않기
- 전역 태그 시스템, 프로세스만 템플릿에 포함

**2. 프로젝트별 커스터마이징**
- CLAUDE.md에 프로젝트 특화 내용 추가
- .claude/info/ 폴더에 상세 규칙 파일 생성

**3. 일관성 유지**
- 모든 프로젝트에서 같은 태그 형식 사용
- 키워드 매칭 기준 통일

### ❌ 피해야 할 사용법

**1. 템플릿에 프로젝트 규칙 추가**
```markdown
# ❌ 나쁜 예: CLAUDE.md.template에 추가
[규칙 추가] Spring - @Transactional 사용법
```

**2. 매번 처음부터 작성**
- 템플릿 사용하지 않고 매번 새로 작성 ❌
- 템플릿 복사 후 수정 ✅

---

## 🔗 관련 문서

- **RULE-SYSTEM-GUIDE.md** - 규칙 시스템 완전 가이드
  - `[규칙 추가]` 명령어 상세 설명
  - 실제 사용 예시
  - 중복 체크 프로세스

---

## 💬 FAQ

### Q1. 기존 프로젝트에 적용하려면?
```bash
# 1. 템플릿 복사
cp claude-template/CLAUDE.md.template existing-project/CLAUDE.md

# 2. info 폴더 생성
mkdir -p existing-project/.claude/info
cp -r claude-template/info/* existing-project/.claude/info/

# 3. 기존 규칙을 [규칙 추가]로 입력
```

### Q2. 여러 프로젝트에서 공통 규칙 공유하려면?
- 템플릿에 공통 규칙 추가
- 또는 별도의 공통 규칙 파일 생성 후 각 프로젝트에서 참조

### Q3. 템플릿 업데이트 후 기존 프로젝트에 반영하려면?
- 수동으로 CLAUDE.md 비교 후 반영
- 또는 새 태그/프로세스만 복사

---

## 📌 핵심 정리

1. **템플릿 = 순수 규칙 시스템** (프로젝트 무관)
2. **프로젝트별로 복사 후 커스터마이징**
3. **`[규칙 추가]`로 프로젝트 규칙 축적**
4. **템플릿 업데이트 = 전역 규칙 개선**

---

**작성자**: koalakid
**최종 수정**: 2025-10-07
