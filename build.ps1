# ============================================================
#  ZEGA Sapphire Build System  —  Z-TEAM
#  Sapphire v2.0 — supports: loops, conditionals, input,
#  concat, debug, extended math, expanded sph::get
# ============================================================

param(
    [string]$Target = "all"   # all | compiler | vm | exe | setup
)

$version   = "2.0.0"
$buildDate = Get-Date -Format "yyyy-MM-dd HH:mm"
$cyan   = "Cyan"
$green  = "Green"
$yellow = "Yellow"
$red    = "Red"

function Banner {
    Write-Host ""
    Write-Host "  ███████╗ █████╗ ██████╗ ██████╗ ██╗  ██╗██╗██████╗ ███████╗" -ForegroundColor $cyan
    Write-Host "  ██╔════╝██╔══██╗██╔══██╗██╔══██╗██║  ██║██║██╔══██╗██╔════╝" -ForegroundColor $cyan
    Write-Host "  ███████╗███████║██████╔╝██████╔╝███████║██║██████╔╝█████╗  " -ForegroundColor $cyan
    Write-Host "  ╚════██║██╔══██║██╔═══╝ ██╔═══╝ ██╔══██║██║██╔══██╗██╔══╝  " -ForegroundColor $cyan
    Write-Host "  ███████║██║  ██║██║     ██║     ██║  ██║██║██║  ██║███████╗" -ForegroundColor $cyan
    Write-Host "  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝" -ForegroundColor $cyan
    Write-Host ""
    Write-Host "  ZEGA Sapphire Build System  •  v$version  •  Z-TEAM" -ForegroundColor $yellow
    Write-Host "  Build Date: $buildDate" -ForegroundColor $yellow
    Write-Host ""
}

function Step([string]$msg) {
    Write-Host "  [BUILD] $msg" -ForegroundColor $green
}

function Fail([string]$msg) {
    Write-Host "  [ERROR] $msg" -ForegroundColor $red
    exit 1
}

function Check([string]$target) {
    if ($LASTEXITCODE -ne 0) { Fail "Failed to build $target" }
    Write-Host "  [OK]    $target" -ForegroundColor $green
}

Banner

$VulkanInc = "include/VulkanSDK/Include"
$VulkanLib = "include/VulkanSDK/Lib"
$CommonFlags = @("-std=c++17", "-Ofast", "-static", "-Wall", "-Wno-deprecated-declarations")

# ── 1. Compiler DLL ─────────────────────────────────────────
if ($Target -eq "all" -or $Target -eq "compiler") {
    Step "Compiling Sapphire_Compiler.dll ..."
    & g++ compiler.cpp @CommonFlags -shared -o Sapphire_Compiler.dll
    Check "Sapphire_Compiler.dll"
}

# ── 2. VM DLL ────────────────────────────────────────────────
if ($Target -eq "all" -or $Target -eq "vm") {
    Step "Compiling Sapphire_VM.dll ..."
    & g++ vm.cpp @CommonFlags -shared `
        -I"$VulkanInc" -L"$VulkanLib" `
        -lvulkan-1 -lgdi32 -luser32 -lshell32 -lnetapi32 `
        -o Sapphire_VM.dll
    Check "Sapphire_VM.dll"
}

# ── 3. Main Executable ───────────────────────────────────────
if ($Target -eq "all" -or $Target -eq "exe") {
    Step "Compiling Sapphire.exe ..."
    & g++ Sapphire.cpp @CommonFlags -o Sapphire.exe
    Check "Sapphire.exe"
}

# ── 4. Installer ─────────────────────────────────────────────
if ($Target -eq "all" -or $Target -eq "setup") {
    Step "Compiling setup.exe ..."
    & g++ setup.cpp @CommonFlags -lshlwapi -o setup.exe
    Check "setup.exe"
}

# ── Summary ──────────────────────────────────────────────────
Write-Host ""
Write-Host "  ════════════════════════════════════════" -ForegroundColor $cyan
Write-Host "   Build complete!  Sapphire v$version" -ForegroundColor $green
Write-Host "   New in v2: loops, if/else, input, concat," -ForegroundColor $yellow
Write-Host "   debug, mod/pow, expanded sph::get, window fix" -ForegroundColor $yellow
Write-Host "  ════════════════════════════════════════" -ForegroundColor $cyan
Write-Host ""
