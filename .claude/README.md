# .claude 폴더 설명

이 폴더는 Claude Code가 프로젝트를 이해하는 데 필요한 컨텍스트와 설정을 담고 있습니다.

---

## 📋 파일 구조

```
.claude/
├── context.md          # 프로젝트 컨텍스트 (자동 프롬프팅)
└── README.md           # 이 파일 (.claude 폴더 설명)
```

---

## 🔄 context.md의 역할

### 자동 프롬프팅 ✅

`context.md` 파일은 **모든 대화에서 자동으로 Claude에게 전달**됩니다.

**동작 방식:**
```
사용자: "clone-repo.sh 수정해줘"
  ↓
Claude: (context.md 자동 읽음)
  ↓
Claude: "clone-repo.claude.md를 먼저 읽어야 함" (context.md에 명시됨)
  ↓
Claude: git/clone-repo.claude.md 읽기
  ↓
정확한 수정 진행
```

### 포함 내용

1. **필수 작업 규칙**: 스크립트 수정 시 참고 문서 읽기
2. **프로젝트 구조**: 전체 디렉토리 구조
3. **코딩 규칙**: bash 스크립트 패턴, fzf 사용법
4. **테스트 지침**: 수정 후 테스트 방법
5. **문서 구조**: 사용자용 vs 개발자용 문서 구분

---

## 📚 문서 체계

### 3단계 문서 구조

#### 1. `.claude/context.md` (자동 프롬프팅)
- **역할**: 프로젝트 전체 컨텍스트
- **독자**: Claude (AI)
- **내용**: 작업 규칙, 구조, 패턴
- **특징**: 모든 대화에 자동 포함 ✅

#### 2. `*.claude.md` (수동 참조)
- **역할**: 개별 파일 상세 기술 문서
- **독자**: 개발자, Claude (필요시)
- **내용**: 목적, 기능, 동작 원리, 코드 패턴
- **특징**: 명시적으로 읽어야 함 ❌

**예시:**
```
git/clone-repo.sh           # 스크립트
git/clone-repo.claude.md    # 기술 문서 (AI/개발자용)
```

#### 3. `README.md`, `*_GUIDE.md` (사용자 가이드)
- **역할**: 사용자용 설명서
- **독자**: 최종 사용자
- **내용**: 사용법, 예시, 트러블슈팅
- **특징**: 일반 문서

**예시:**
```
git/README.md           # 간단한 소개
git/CLONE_GUIDE.md      # 상세 사용 가이드
git/SSH_GPG_SETUP.md    # 설정 가이드
```

---

## 🎯 문서 선택 가이드

| 상황 | 읽을 문서 |
|------|-----------|
| 프로젝트 전체 이해 | `.claude/context.md` |
| 특정 스크립트 수정 | `{script}.claude.md` |
| 사용법 확인 | `README.md`, `*_GUIDE.md` |
| 새 기능 추가 | `context.md` + 관련 `.claude.md` |

---

## ✏️ context.md 업데이트 시점

다음 경우 `context.md`를 업데이트해야 합니다:

1. **새 도구 추가**: 폴더 및 스크립트 추가 시
2. **공통 패턴 변경**: 코딩 규칙 변경 시
3. **프로젝트 구조 변경**: 디렉토리 구조 수정 시
4. **중요 작업 규칙 추가**: 새로운 필수 절차 생길 시

---

## 🔍 `.claude.md` vs `README.md`

### `.claude.md` (기술 문서)
```markdown
# clone-repo.sh

## 목적
GitHub 멀티 계정 환경에서...

## 기술적 세부사항
### 계정 탐지
```bash
mapfile -t accounts < <(find "$github_base" ...)
```

### fzf 파이프라인
올바른 패턴: `{ printf '%s\n' "${array[@]}"; } | fzf`
```

### `README.md` (사용자 가이드)
```markdown
# GitHub 멀티 계정 관리 도구

## 빠른 시작
```bash
./clone-repo.sh
```

1. 계정 선택
2. 타입 선택
3. 레포 선택
...
```

---

## 🚀 빠른 참조

### 스크립트 수정 시
```
1. context.md 확인 (자동)
2. 해당 .claude.md 읽기
3. 수정 진행
4. 테스트
```

### 새 도구 추가 시
```
1. 폴더 생성: toolbox/{tool}/
2. 스크립트 작성
3. {script}.claude.md 작성
4. README.md 작성
5. context.md에 항목 추가
6. toolbox/README.md에 도구 추가
```

---

## 💡 핵심 개념

**자동 프롬프팅 = context.md만**

- ✅ `.claude/context.md` → 자동으로 모든 대화에 포함
- ❌ `*.claude.md` → 수동으로 읽어야 함

**하지만!**

`context.md`에 "이 파일 수정 시 반드시 `.claude.md` 읽기"라고 명시하면,
Claude가 자동으로 해당 `.claude.md`를 읽게 됩니다!

---

## 📌 참고

- **Claude Code 공식 문서**: https://docs.claude.com/en/docs/claude-code
- **프로젝트 초기화**: `/init` 명령어로 `.claude/` 폴더 자동 생성 가능
- **커스텀 명령어**: `.claude/commands/` 폴더에 슬래시 커맨드 추가 가능
