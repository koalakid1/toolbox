# Claude Template 관리 규칙

`claude-template/` 폴더의 템플릿 파일 관리 및 업데이트 규칙입니다.

---

## 📋 템플릿 개요

### 목적
- 새 프로젝트에서 재사용 가능한 순수 규칙 시스템 제공
- 프로젝트 무관한 전역 태그/규칙만 포함
- 특정 프로젝트 규칙은 절대 포함 금지

### 파일 구조

```
claude-template/
├── CLAUDE.md.template       # 프로젝트 컨텍스트 템플릿 (자동 프롬프팅)
├── info/                    # 전역 규칙 파일들
│   ├── README.md            # info 폴더 사용법
│   └── init-integration-guide.md  # /init 통합 가이드
├── README.md                # 템플릿 사용법
└── RULE-SYSTEM-GUIDE.md     # 규칙 시스템 상세 가이드
```

---

## ⚠️ 템플릿 순수성 유지

### ✅ 템플릿에 포함해야 할 것

**전역 규칙 시스템:**
- `[규칙 추가]` 프로세스
- 태그 시스템 구조
- 중복 체크 로직
- 키워드 매칭 기준

**확장 가능한 예시:**
- 태그 예시 (`[추가]`, `[수정]` 등)
- 카테고리 예시 (Git, 코드, 테스트 등)

### ❌ 템플릿에 포함하면 안 되는 것

**프로젝트 특화 내용:**
- toolbox 관련 내용 (bash, git 등)
- Spring, React 같은 특정 기술 스택
- 특정 프로젝트의 규칙이나 패턴

**템플릿 관리 내용:**
- 템플릿 업데이트 방법
- 템플릿 수정 규칙
- 이런 내용은 toolbox/.claude/에서 관리

---

## 📂 info/ 폴더 관리

### info/ 폴더의 역할

**전역 규칙 저장소:**
- 모든 프로젝트에 공통 적용되는 규칙
- `/init` 통합 가이드
- 프로젝트 시작 시 함께 복사됨

### 새 규칙을 info/에 추가할 기준

**✅ info/에 추가해야 할 경우:**
- 모든 프로젝트에 적용 가능한 전역 가이드
- `/init` 같은 Claude Code 기본 기능 통합
- 프로젝트 무관한 규칙 시스템 확장

**예시:**
- `init-integration-guide.md` - /init 통합 (전역)
- `CLAUDE-structure-guide.md` - CLAUDE.md 구조 설명 (전역)

**❌ info/에 추가하면 안 되는 경우:**
- 특정 기술 스택 규칙 (React, Spring 등)
- 특정 프로젝트 패턴 (toolbox의 bash 등)

**올바른 위치:**
- 개별 프로젝트의 `.claude/info/`에 추가

### info/ 파일 추가 절차

**1. 전역 규칙 확인:**
```
Q: 이것이 모든 프로젝트에 필요한가?
   YES → claude-template/info/에 추가
   NO → 개별 프로젝트 .claude/info/에 추가
```

**2. 파일 생성:**
```bash
# 파일명 규칙: 소문자-하이픈.md
vim claude-template/info/{규칙명}.md
```

**3. 템플릿 사용법 업데이트:**
```bash
# README.md에 새 파일 설명 추가
vim claude-template/README.md
```

**4. (선택) CLAUDE.md.template 태그 추가:**
필요시 기본 태그로 제공

---

## 🔄 템플릿 업데이트 시점

### 1. 전역 태그 추가

**예시:**
```
기존: [추가], [수정], [삭제]
추가: [리뷰] - 코드 리뷰 시 사용
```

**작업:**
1. `claude-template/CLAUDE.md.template` 수정
2. "추가 태그 시스템" 섹션에 추가
3. 필요시 키워드 매칭 테이블 업데이트

### 2. 규칙 추가 프로세스 개선

**예시:**
- 중복 체크 로직 개선
- 새로운 유사도 판단 기준 추가

**작업:**
1. `claude-template/CLAUDE.md.template` 수정
2. "규칙 추가 프로세스" 섹션 업데이트
3. `RULE-SYSTEM-GUIDE.md`도 함께 업데이트

### 3. 새로운 카테고리 추가

**예시:**
```
기존: Git, 코드, 테스트, 배포, 문서, API, DB, 보안
추가: 성능 - performance, optimization, 최적화
```

**작업:**
1. `claude-template/CLAUDE.md.template` 수정
2. "키워드 매칭" 테이블에 추가

---

## 📝 템플릿 수정 절차

### Step 1: 필요성 확인

다음 질문에 답하기:
- [ ] 이것이 **모든 프로젝트**에 유용한가?
- [ ] 특정 프로젝트(toolbox, Spring 등)에만 해당되지 않는가?
- [ ] 전역 규칙 시스템의 일부인가?

**NO 하나라도 있으면**: 템플릿이 아닌 개별 프로젝트 `.claude/`에 추가

### Step 2: 파일 수정

```bash
# CLAUDE.md.template 수정
vim claude-template/CLAUDE.md.template

# 필요시 README, GUIDE도 업데이트
vim claude-template/README.md
vim claude-template/RULE-SYSTEM-GUIDE.md
```

### Step 3: 기존 프로젝트 영향 평가

**질문:**
- 이 변경이 기존 프로젝트에 영향을 주는가?
- 기존 프로젝트가 업데이트 필요한가?

**YES인 경우:**
- 변경 로그 작성
- 기존 프로젝트 마이그레이션 가이드 작성

### Step 4: 버전 업데이트

```markdown
# CLAUDE.md.template 상단
> 📌 Template Version: 1.1.0
```

**버전 규칙:**
- 패치 (1.0.0 → 1.0.1): 오타 수정, 설명 개선
- 마이너 (1.0.0 → 1.1.0): 새 태그/카테고리 추가
- 메이저 (1.0.0 → 2.0.0): 구조 대폭 변경

---

## 🔍 품질 체크리스트

템플릿 수정 후 확인:

### 순수성 체크
- [ ] 프로젝트 특화 내용이 없는가?
- [ ] toolbox 관련 내용이 제거되었는가?
- [ ] 모든 프로젝트에 적용 가능한가?

### 완성도 체크
- [ ] 주석(`<!--`)으로 예시/설명 제공했는가?
- [ ] 사용자가 채워야 할 부분이 명확한가?
- [ ] README.md에 사용법이 잘 설명되어 있는가?

### 문서 일관성
- [ ] CLAUDE.md.template, README.md, RULE-SYSTEM-GUIDE.md가 일치하는가?
- [ ] 예시가 실제 동작과 일치하는가?

---

## 📌 템플릿 사용 흐름 (참고)

템플릿이 어떻게 사용되는지 이해:

```
1. 새 프로젝트 시작
   ↓
2. claude-template/ 복사
   cp CLAUDE.md.template new-project/CLAUDE.md
   cp -r info/* new-project/.claude/info/
   ↓
3. 프로젝트 정보 입력
   - 프로젝트명, 설명, 기술 스택
   ↓
4. [규칙 추가]로 프로젝트별 규칙 축적
   ↓
5. 프로젝트 특화 태그 추가
```

**템플릿 관리는 toolbox의 책임이지만, 사용은 각 프로젝트의 몫**

---

## 🎯 실제 예시

### 예시 1: 전역 태그 추가

**상황:** 모든 프로젝트에서 `[리뷰]` 태그 필요

**작업:**
```markdown
# claude-template/CLAUDE.md.template

## 📌 추가 태그 시스템

### 작업 유형
- `[추가]` - 새 기능
- `[수정]` - 코드 수정
- `[삭제]` - 코드 제거
- `[리팩토링]` - 리팩토링
- `[리뷰]` - 코드 리뷰  ← 추가
```

**버전:** 1.0.0 → 1.1.0

### 예시 2: 잘못된 수정 (하면 안 됨)

**상황:** bash 스크립트 패턴을 템플릿에 추가하고 싶음

**판단:**
- bash는 특정 프로젝트(toolbox)에만 해당 ❌
- 모든 프로젝트가 bash를 쓰지 않음 ❌
- 템플릿에 추가하면 안 됨 ❌

**올바른 방법:**
- `toolbox/.claude/info/bash-patterns.md`에 유지 ✅

---

## 🔗 관련 파일

### toolbox 내부
- `CLAUDE.md` - toolbox 전용 컨텍스트 (자동 프롬프팅)
- `.claude/info/toolbox-folder-management.md` - 도구 추가 규칙
- `.claude/info/bash-patterns.md` - Bash 패턴 (toolbox 전용)

### 템플릿
- `claude-template/CLAUDE.md.template` - 순수 템플릿
- `claude-template/README.md` - 사용법
- `claude-template/RULE-SYSTEM-GUIDE.md` - 상세 가이드

---

## ⚡ 빠른 참조

### 템플릿 수정 시 자문

```
Q: 이것이 모든 프로젝트에 필요한가?
   YES → 템플릿 수정
   NO → 개별 프로젝트 .claude/에 추가

Q: 프로젝트 특화 내용인가?
   YES → 템플릿에 넣지 말 것
   NO → 템플릿 수정 가능

Q: 템플릿 관리 내용인가?
   YES → .claude/info/claude-template-management.md
   NO → claude-template/
```

---

**작성일:** 2025-10-07
**관리자:** koalakid (toolbox)
