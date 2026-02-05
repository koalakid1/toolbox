#!/usr/bin/env bash

# 필수 도구 설치 스크립트
# GitHub 계정 설정에 필요한 도구들을 설치합니다

set -e  # 오류 시 중지

echo "🔧 GitHub 계정 설정 필수 도구 설치"
echo ""

# OS 감지
os_type=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    os_type="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    os_type="mac"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    os_type="windows"
else
    os_type="unknown"
fi

echo "🖥️  감지된 OS: $os_type"
echo ""

# macOS 자동 설치 함수
install_macos_tools() {
    echo "🍎 macOS Homebrew 자동 설치 모드"
    echo ""

    # Homebrew 체크
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew가 설치되지 않았습니다."
        echo ""
        echo "Homebrew 설치 중..."
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            # Homebrew PATH 설정
            if [[ "$(uname -m)" == "arm64" ]]; then
                export PATH="/opt/homebrew/bin:$PATH"
            else
                export PATH="/usr/local/bin:$PATH"
            fi
            echo "✅ Homebrew 설치 완료!"
        else
            echo "❌ Homebrew 설치 실패. 수동으로 설치해주세요:"
            echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    else
        echo "✅ Homebrew 이미 설치됨"
    fi
    echo ""

    # 설치할 패키지 목록
    packages_to_install=()

    # 필수 도구 체크
    if ! command -v git &> /dev/null; then
        packages_to_install+=("git")
    fi

    if ! command -v gpg &> /dev/null; then
        packages_to_install+=("gnupg")
    fi

    # 추가 도구 체크
    if ! command -v fzf &> /dev/null; then
        packages_to_install+=("fzf")
    fi

    if ! command -v gh &> /dev/null; then
        packages_to_install+=("gh")
    fi

    # ssh-keygen은 macOS에 기본 포함
    if ! command -v ssh-keygen &> /dev/null; then
        echo "⚠️  ssh-keygen이 없습니다. Xcode Command Line Tools 설치 필요:"
        echo "   xcode-select --install"
        echo ""
    fi

    # 설치 진행
    if [ ${#packages_to_install[@]} -eq 0 ]; then
        echo "✅ 모든 도구가 이미 설치되어 있습니다!"
        echo ""
        echo "설치된 도구:"
        echo "  ✓ git: $(git --version 2>/dev/null || echo '미설치')"
        echo "  ✓ gpg: $(gpg --version 2>/dev/null | head -1 || echo '미설치')"
        echo "  ✓ ssh-keygen: $(command -v ssh-keygen &>/dev/null && echo "설치됨" || echo "미설치")"
        echo "  ✓ fzf: $(fzf --version 2>/dev/null || echo '미설치')"
        echo "  ✓ gh: $(gh --version 2>/dev/null || echo '미설치')"
        echo ""
        echo "💡 이제 setup-account.sh를 실행할 수 있습니다:"
        echo "   ./setup-account.sh"
        exit 0
    fi

    echo "📦 다음 패키지들을 설치합니다:"
    for pkg in "${packages_to_install[@]}"; do
        echo "   - $pkg"
    done
    echo ""

    read -p "계속하시겠습니까? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "취소되었습니다."
        exit 0
    fi
    echo ""

    # Homebrew로 설치
    echo "🔨 Homebrew로 설치 중..."
    if brew install "${packages_to_install[@]}"; then
        echo ""
        echo "✅ 모든 도구 설치 완료!"

        # fzf shell integration 설치
        if command -v fzf &> /dev/null; then
            echo ""
            echo "🔧 fzf shell integration 설정 중..."
            if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
                "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-zsh --no-fish
            fi
        fi

        echo ""
        echo "설치된 도구:"
        echo "  ✓ git: $(git --version)"
        echo "  ✓ gpg: $(gpg --version | head -1)"
        echo "  ✓ ssh-keygen: 설치됨"
        echo "  ✓ fzf: $(fzf --version)"
        echo "  ✓ gh: $(gh --version)"
        echo ""
        echo "💡 이제 setup-account.sh를 실행할 수 있습니다:"
        echo "   ./setup-account.sh"
    else
        echo "❌ 설치 실패. 수동으로 설치해주세요."
        exit 1
    fi
}

# 필수 도구 체크 (비-macOS)
check_manual_install() {
    echo "🔍 필수 도구 확인 중..."
    echo ""

    missing_tools=()

    if ! command -v ssh-keygen &> /dev/null; then
        missing_tools+=("ssh-keygen")
    fi

    if ! command -v gpg &> /dev/null; then
        missing_tools+=("gpg")
    fi

    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi

    if ! command -v fzf &> /dev/null; then
        missing_tools+=("fzf")
    fi

    if ! command -v gh &> /dev/null; then
        missing_tools+=("gh")
    fi

    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo "✅ 모든 필수 도구가 이미 설치되어 있습니다!"
        echo ""
        echo "설치된 도구:"
        echo "  ✓ git: $(git --version)"
        echo "  ✓ gpg: $(gpg --version | head -1)"
        echo "  ✓ ssh-keygen: 설치됨"
        echo "  ✓ fzf: $(fzf --version)"
        echo "  ✓ gh: $(gh --version)"
        echo ""
        echo "💡 이제 setup-account.sh를 실행할 수 있습니다:"
        echo "   ./setup-account.sh"
        exit 0
    fi

    echo "❌ 다음 도구들이 설치되지 않았습니다:"
    for tool in "${missing_tools[@]}"; do
        echo "   - $tool"
    done
    echo ""

    # OS별 설치 안내
    if [ "$os_type" = "linux" ]; then
        echo "📦 Linux 설치 명령어:"
        echo ""

        if [[ -n "${missing_tools[*]}" ]]; then
            packages=""
            for tool in "${missing_tools[@]}"; do
                case "$tool" in
                    "ssh-keygen")
                        packages="$packages openssh-client"
                        ;;
                    "gpg")
                        packages="$packages gnupg"
                        ;;
                    "git")
                        packages="$packages git"
                        ;;
                    "fzf")
                        packages="$packages fzf"
                        ;;
                    "gh")
                        packages="$packages gh"
                        ;;
                esac
            done

            echo "# Ubuntu/Debian:"
            echo "sudo apt update && sudo apt install -y$packages"
            echo ""
            echo "# Fedora/RHEL:"
            echo "sudo dnf install -y$packages"
            echo ""
            echo "# Arch Linux:"
            packages_arch="${packages//openssh-client/openssh}"
            packages_arch="${packages_arch//gnupg/gnupg}"
            echo "sudo pacman -S$packages_arch"
        fi

    elif [ "$os_type" = "windows" ]; then
        echo "📦 Windows 설치 방법:"
        echo ""

        for tool in "${missing_tools[@]}"; do
            case "$tool" in
                "ssh-keygen")
                    echo "✓ ssh-keygen (Git Bash에 포함):"
                    echo "  https://git-scm.com/download/win"
                    ;;
                "gpg")
                    echo "✓ gpg (Gpg4win):"
                    echo "  https://www.gpg4win.org/download.html"
                    echo "  또는 Chocolatey: choco install gpg4win"
                    ;;
                "git")
                    echo "✓ git:"
                    echo "  https://git-scm.com/download/win"
                    echo "  또는 Chocolatey: choco install git"
                    ;;
                "fzf")
                    echo "✓ fzf:"
                    echo "  Chocolatey: choco install fzf"
                    echo "  또는 수동: https://github.com/junegunn/fzf#installation"
                    ;;
                "gh")
                    echo "✓ GitHub CLI:"
                    echo "  Chocolatey: choco install gh"
                    echo "  또는: https://cli.github.com/"
                    ;;
            esac
            echo ""
        done

    else
        echo "⚠️  알 수 없는 OS입니다. 수동으로 설치하세요:"
        echo ""
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 설치 후 다음 명령어로 다시 확인하세요:"
    echo "   ./install-required-tools.sh"
    echo ""
    echo "✅ 모든 도구 설치 후 계정 설정을 진행하세요:"
    echo "   ./setup-account.sh"
    echo ""
}

# 메인 로직
if [ "$os_type" = "mac" ]; then
    install_macos_tools
else
    check_manual_install
fi
