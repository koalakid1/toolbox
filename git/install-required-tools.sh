#!/bin/bash

# 필수 도구 설치 스크립트
# GitHub 계정 설정에 필요한 도구들을 설치합니다

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

# 필수 도구 체크
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

if [ ${#missing_tools[@]} -eq 0 ]; then
    echo "✅ 모든 필수 도구가 이미 설치되어 있습니다!"
    echo ""
    echo "설치된 도구:"
    echo "  ✓ ssh-keygen: $(ssh-keygen -V 2>&1 | head -1 || echo "$(ssh -V 2>&1 | head -1)")"
    echo "  ✓ gpg: $(gpg --version | head -1)"
    echo "  ✓ git: $(git --version)"
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

elif [ "$os_type" = "mac" ]; then
    echo "📦 macOS 설치 명령어:"
    echo ""

    packages=""
    for tool in "${missing_tools[@]}"; do
        case "$tool" in
            "ssh-keygen")
                echo "✓ ssh-keygen은 macOS에 기본 포함되어 있습니다."
                echo "  Xcode Command Line Tools 설치:"
                echo "  xcode-select --install"
                ;;
            "gpg")
                packages="$packages gnupg"
                ;;
            "git")
                packages="$packages git"
                ;;
        esac
    done

    if [ -n "$packages" ]; then
        echo ""
        echo "# Homebrew로 설치:"
        echo "brew install$packages"
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
