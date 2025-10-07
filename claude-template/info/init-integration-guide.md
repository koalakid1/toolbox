# /init 통합 가이드

Claude Code의 `/init` 명령어와 이 템플릿 규칙 시스템을 함께 사용하는 방법입니다.

---

## 📋 /init 이란?

### Claude Code 기본 기능
```
/init
```

**자동 수행:**
- 프로젝트 구조 분석
- 기술 스택 감지
- **루트에 `CLAUDE.md` 파일 생성** ← 중요!
- 프로젝트 개요 작성

**생성되는 파일:**
- `CLAUDE.md` (프로젝트 루트)

**포함 내용:**
- 프로젝트 설명
- 빌드/테스트 명령어
- 디렉토리 구조
- 아키텍처 설명
- 기술 스택 정보

---

## 🎯 권장 워크플로우 (템플릿 우선)

### Step 1: 템플릿 복사

```bash
# 프로젝트 루트에서
mkdir -p .claude
cp claude-template/context.md.template .claude/context.md
cp -r claude-template/info .claude/info
```

**결과:**
- `.claude/context.md` - 규칙 시스템 준비 ✅
- `.claude/info/` - 전역 규칙 포함 ✅

### Step 2: /init 실행

```bash
# Claude Code에서
/init
```

**결과:**
- `CLAUDE.md` (루트에 생성됨)
- 코드베이스 분석 내용 포함

### Step 3: CLAUDE.md 처리 (자동화)

**규칙 시스템이 자동으로 처리:**

1. **CLAUDE.md 읽기**
2. **내용을 `.claude/info/codebase-overview.md`로 이동**
   ```bash
   # Claude가 자동으로 수행
   mv CLAUDE.md .claude/info/codebase-overview.md
   ```
3. **context.md에 태그 추가** (필요시)
   ```markdown
   ### [코드베이스]
   - `.claude/info/codebase-overview.md` - 프로젝트 구조 및 빌드 방법
   ```

### Step 4: 프로젝트 정보 입력

`.claude/context.md` 수정:
```markdown
**프로젝트명:** [입력]
**설명:** [입력]
**기술 스택:** [입력]
```

**팁:** `codebase-overview.md`에서 복사 가능!

---

## 📝 병합 템플릿

### 권장 구조

```markdown
# {프로젝트명} Context

---

## 📋 프로젝트 정보

<!-- /init에서 자동 생성된 정보 또는 수동 입력 -->

**프로젝트명:** {이름}
**설명:** {설명}
**기술 스택:** {기술}

### 디렉토리 구조

<!-- /init이 분석한 구조 -->

---

## 🏷️ 프로세스별 필수 참고 문서

<!-- 템플릿에서 가져온 태그 시스템 -->

### [코드 수정]
- `.claude/info/coding-rules.md`

---

## 🔍 규칙 추가 프로세스

<!-- 템플릿에서 가져온 규칙 시스템 -->

### 명령어
```
[규칙 추가] {카테고리} - {규칙 내용}
```

...
```

---

## 🎯 단계별 가이드

### Step 1: 상황 파악

**질문:**
- [ ] `/init`을 이미 실행했는가?
- [ ] `.claude/context.md`가 존재하는가?
- [ ] 프로젝트 정보가 자동 생성되었는가?

### Step 2: 통합 방법 선택

**Case A: /init 실행됨**
→ 시나리오 1 사용 (백업 후 병합)

**Case B: /init 미실행**
→ 시나리오 2 사용 (템플릿 먼저)

### Step 3: 템플릿 내용 추가

**필수 섹션:**
- ✅ 규칙 추가 프로세스
- ✅ 프로세스별 필수 참고 문서 (태그)
- ✅ 키워드 매칭 테이블
- ✅ 추가 태그 시스템

**선택 섹션:**
- 테스트 지침
- 문서 구조 설명
- 작업 흐름

### Step 4: info/ 폴더 설정

```bash
# 템플릿 info/ 복사 (아직 안 했다면)
cp -r claude-template/info your-project/.claude/info

# 불필요한 파일 제거
rm your-project/.claude/info/init-integration-guide.md  # 이 파일은 일회용
```

### Step 5: 첫 규칙 추가

```
[규칙 추가] {프로젝트 기술스택} - {규칙 내용}
```

**예시:**
```
[규칙 추가] React - 컴포넌트는 함수형으로 작성
[규칙 추가] Spring - @Transactional은 Service 레이어만
```

---

## 💡 실제 예시

### React 프로젝트

**1. /init 실행 결과:**
```markdown
# My React App

## Project Overview
React 기반 SPA 애플리케이션...

## Tech Stack
- React 18
- TypeScript
- Vite
```

**2. 템플릿 병합 후:**
```markdown
# My React App Context

## 📋 프로젝트 정보

**프로젝트명:** My React App
**설명:** React 기반 SPA 애플리케이션
**기술 스택:** React 18, TypeScript, Vite

---

## 🏷️ 프로세스별 필수 참고 문서

### [컴포넌트 작성]
- `.claude/info/react-component-rules.md`

### [상태 관리]
- `.claude/info/state-management.md`

---

## 🔍 규칙 추가 프로세스

[규칙 추가] {카테고리} - {규칙 내용}
...
```

---

## ⚠️ 주의사항

### /init은 덮어쓰기 가능

`/init`을 다시 실행하면 `.claude/context.md`를 덮어씁니다!

**대응:**
1. 병합 후에는 백업 유지
2. 또는 `/init` 재실행 금지
3. 중요 내용은 `info/*.md`에 분리 저장

### 충돌 방지

**같은 섹션:**
- `/init`: "Project Overview"
- 템플릿: "프로젝트 정보"

**해결:**
- 하나로 통합 (템플릿 형식 권장)
- 또는 `/init` 결과를 주석으로 보관

---

## 🔗 관련 문서

- `context.md.template` - 기본 템플릿
- `info/README.md` - info 폴더 사용법
- `RULE-SYSTEM-GUIDE.md` - 규칙 시스템 전체 가이드

---

## 📌 체크리스트

통합 완료 후 확인:

- [ ] 프로젝트 정보가 정확한가?
- [ ] "규칙 추가 프로세스" 섹션이 있는가?
- [ ] "프로세스별 필수 참고 문서" (태그) 섹션이 있는가?
- [ ] `info/` 폴더가 복사되었는가?
- [ ] `[규칙 추가]` 명령어가 작동하는가?
- [ ] 첫 프로젝트 규칙을 추가했는가?

---

**작성일:** 2025-10-07
**용도:** 일회용 가이드 (통합 후 삭제 가능)
