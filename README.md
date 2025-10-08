# koalakid-toolbox

개발 작업에 필요한 자동화 스크립트 및 도구 모음

---

## 📦 포함된 도구

### 🔧 [git/](git/)
GitHub 멀티 계정 관리 및 레포지토리 자동 클론 도구

- SSH/GPG 키 자동 생성 및 설정
- 계정별 Git 설정 자동 전환
- 대화형 레포지토리 클론 (fzf 기반)
- 개인/조직 레포 자동 분류

**📖 [자세히 보기](git/README.md)**

### 📋 [claude-template/](claude-template/)
새 프로젝트용 Claude 규칙 시스템 템플릿

- 프로젝트 무관한 순수 규칙 시스템
- `[규칙 추가]` 명령어로 규칙 관리
- 태그 기반 문서 자동 참조
- 중복 규칙 자동 체크

**📖 [자세히 보기](claude-template/README.md)**

---

## 📂 디렉토리 구조

```
toolbox/
├── README.md               # 이 파일
├── CLAUDE.md               # 자동 프롬프팅 (toolbox 전용)
├── .claude/                # toolbox 설정 및 규칙
│   └── info/               # 상세 규칙
│       ├── bash-patterns.md
│       ├── toolbox-folder-management.md
│       └── claude-template-management.md
├── claude-template/        # 재사용 가능한 Claude 템플릿
│   ├── CLAUDE.md.template  # 템플릿 (자동 프롬프팅)
│   ├── info/               # 전역 규칙
│   │   ├── README.md
│   │   └── init-integration-guide.md
│   ├── README.md
│   └── RULE-SYSTEM-GUIDE.md
├── git/                    # GitHub 멀티 계정 관리
│   ├── *.sh                # 스크립트
│   ├── *.claude.md         # 기술 문서
│   └── *.md                # 사용자 가이드
└── ...                     # 향후 추가될 도구들
```

---

## 👤 작성자

koalakid
