# Claude 규칙 시스템 가이드

이 문서는 `.claude/` 폴더를 활용한 규칙 시스템 사용법을 설명합니다.

---

## 📁 .claude 폴더 구조

```
.claude/
├── context.md              # 자동 프롬프팅 (메인 컨텍스트)
├── info/                   # 상세 규칙 저장소
│   ├── bash-patterns.md    # Bash 스크립트 패턴
│   ├── git-workflow.md     # Git 워크플로우
│   └── ...                 # 추가 규칙 파일들
├── README.md               # .claude 폴더 설명
└── RULE-SYSTEM-GUIDE.md    # 이 파일 (규칙 시스템 사용법)
```

---

## 🎯 핵심 개념

### 1. 자동 프롬프팅
- **`context.md`만** 모든 대화에서 자동으로 Claude에게 전달됩니다
- 다른 파일들은 명시적으로 읽어야 합니다

### 2. 태그 기반 참조
- `context.md`에 태그를 정의하면 해당 태그 사용 시 자동으로 관련 문서 참조

### 3. 규칙 중복 방지
- 새 규칙 추가 시 자동으로 기존 규칙과 비교
- 유사한 규칙이 있으면 사용자에게 알림

---

## 🏷️ 태그 사용법

### 정의된 태그

`context.md`에 정의된 태그들:

| 태그 | 참조 문서 | 용도 |
|------|-----------|------|
| `[스크립트 수정]` | `.claude/info/bash-patterns.md` | Bash 스크립트 작업 |
| `[Git 작업]` | `.claude/info/git-workflow.md` | Git 관련 작업 |

### 사용 예시

```
사용자: "[스크립트 수정] clone-repo.sh에 기능 추가"

Claude:
1. context.md 자동 읽음 ✅
2. [스크립트 수정] 태그 감지
3. .claude/info/bash-patterns.md 자동 읽음
4. bash 패턴 준수하며 수정
```

---

## ➕ 규칙 추가하기

### `[규칙 추가]` 명령어

**형식:**
```
[규칙 추가] {카테고리} - {규칙 내용}
```

**예시:**
```
[규칙 추가] Git - 커밋 메시지는 conventional commits 형식 사용
[규칙 추가] 코드 - 모든 함수는 JSDoc 주석 필수
[규칙 추가] 테스트 - 단위 테스트는 jest 사용
```

### 자동 처리 흐름

#### 1️⃣ 키워드 분석
Claude가 카테고리 키워드를 분석하여 기존 규칙과 비교합니다.

**키워드 매칭 테이블:**

| 카테고리 | 키워드 | 파일명 패턴 |
|----------|--------|-------------|
| Git | git, commit, branch, merge, pr | git-*.md |
| 코드 | code, function, class, refactor | coding-*.md |
| 테스트 | test, jest, unit, e2e | testing-*.md |
| 배포 | deploy, release, build, ci, cd | deployment-*.md |
| 문서 | doc, readme, comment | documentation-*.md |
| 스크립트 | bash, shell, script | bash-*.md, script-*.md |

#### 2️⃣ 중복 확인

**유사도 판단 기준:**
- 키워드 2개 이상 일치
- 태그명 50% 이상 유사
- 파일명 패턴 일치

#### 3️⃣ 유사 규칙 발견 시

Claude가 다음과 같이 알려줍니다:

```
⚠️ 유사한 규칙이 이미 존재합니다!

기존: [Git 작업] - .claude/info/git-workflow.md
키워드 일치: "git", "commit"

📋 현재 규칙 요약:
  • 브랜치 전략: feature/*, fix/*
  • PR 템플릿 사용
  • 코드 리뷰 필수

🆕 새로운 내용: "커밋 메시지는 conventional commits 형식 사용"

💡 이것은 Git 워크플로우의 일부입니다.

선택하세요:
1️⃣ 기존 파일에 추가 (git-workflow.md 업데이트)
2️⃣ 새 파일 생성 (git-commit-convention.md)
3️⃣ 취소

→
```

#### 4️⃣ 선택에 따른 처리

**1️⃣ 선택 시:**
- 기존 `.claude/info/{filename}.md` 읽기
- 적절한 섹션에 새 규칙 추가
- 파일 업데이트

**2️⃣ 선택 시:**
- 새 `.claude/info/{new-filename}.md` 생성
- 규칙 내용 작성
- `context.md`의 태그 섹션에 새 항목 추가

**3️⃣ 선택 시:**
- 작업 취소

---

## 📝 실제 사용 예시

### 예시 1: 완전히 새로운 카테고리

```
사용자: "[규칙 추가] Docker - 모든 이미지는 alpine 베이스 사용"

Claude:
- 키워드 분석: "docker", "이미지"
- 기존 규칙 검색: 없음
- 새 파일 생성: .claude/info/docker-rules.md
- context.md 업데이트: [Docker] 태그 추가
```

### 예시 2: 기존 카테고리에 추가

```
사용자: "[규칙 추가] Git - PR은 최소 2명의 approve 필요"

Claude:
⚠️ 유사한 규칙이 이미 존재합니다!

기존: [Git 작업] - .claude/info/git-workflow.md
키워드 일치: "git", "pr"

📋 현재 규칙 요약:
  • 브랜치 전략: feature/*, fix/*
  • PR 템플릿 사용
  • 코드 리뷰 필수

🆕 새로운 내용: "PR은 최소 2명의 approve 필요"

선택하세요:
1️⃣ git-workflow.md에 추가
2️⃣ 새 파일 생성
3️⃣ 취소

사용자: 1

Claude:
- git-workflow.md 읽기
- "PR 프로세스" 섹션에 규칙 추가
- 파일 업데이트 완료
```

### 예시 3: 세분화 필요

```
사용자: "[규칙 추가] Git - 커밋 메시지는 다음 형식 사용: type(scope): subject"

Claude:
⚠️ 유사한 규칙이 이미 존재합니다!

기존: [Git 작업] - .claude/info/git-workflow.md

선택하세요:
1️⃣ git-workflow.md에 추가
2️⃣ 새 파일 생성 (git-commit-convention.md)
3️⃣ 취소

사용자: 2

Claude:
- 새 파일 생성: .claude/info/git-commit-convention.md
- 커밋 메시지 규칙 상세 작성
- context.md에 태그 추가: [커밋 규칙]
```

---

## 🔄 새 프로젝트에 적용하기

### 1. .claude 폴더 복사

```bash
# toolbox의 .claude 폴더를 새 프로젝트로 복사
cp -r ~/github/koalakid1/toolbox/.claude ~/github/koalakid1/new-project/
```

### 2. context.md 수정

프로젝트에 맞게 내용 수정:
- 프로젝트 구조 업데이트
- 기존 규칙 제거 (필요시)
- 프로젝트별 규칙 추가

### 3. info/ 폴더 정리

```bash
# 불필요한 규칙 파일 삭제
rm ~/github/koalakid1/new-project/.claude/info/bash-patterns.md

# 프로젝트별 규칙 파일 추가
# [규칙 추가] 명령어 사용
```

### 4. 규칙 추가

```
[규칙 추가] {카테고리} - {규칙 내용}
```

---

## 💡 Best Practices

### ✅ 좋은 예

**명확한 카테고리:**
```
[규칙 추가] Git - 커밋 메시지는 conventional commits 사용
```

**구체적인 내용:**
```
[규칙 추가] 테스트 - 모든 API 함수는 단위 테스트 필수, 커버리지 80% 이상
```

**실행 가능한 규칙:**
```
[규칙 추가] 코드 - 함수는 최대 50줄 이내, 초과 시 분리
```

### ❌ 나쁜 예

**모호한 카테고리:**
```
[규칙 추가] 기타 - 좋은 코드 작성
```

**너무 일반적:**
```
[규칙 추가] 개발 - 잘 만들기
```

**측정 불가:**
```
[규칙 추가] 코드 - 예쁘게 작성
```

---

## 🎓 학습 경로

1. **이 문서 읽기** ← 지금 여기
2. **`.claude/README.md` 읽기** - .claude 폴더 전반적 이해
3. **`context.md` 읽기** - 현재 프로젝트의 규칙 확인
4. **실습**: `[규칙 추가]` 명령어로 규칙 추가해보기

---

## 🔗 관련 문서

- `.claude/README.md` - .claude 폴더 설명
- `.claude/context.md` - 프로젝트 컨텍스트 (자동 프롬프팅)
- `.claude/info/*.md` - 개별 규칙 파일들

---

## 📌 핵심 정리

1. **`context.md`**: 자동 프롬프팅, 태그 정의, 규칙 추가 프로세스
2. **`info/*.md`**: 카테고리별 상세 규칙
3. **`[규칙 추가]`**: 새 규칙 추가 명령어
4. **자동 중복 체크**: 유사 규칙 자동 감지 및 알림
5. **다른 프로젝트 재사용**: `.claude` 폴더 복사 후 수정

---

**작성자**: koalakid
**최종 수정**: 2025-10-07
