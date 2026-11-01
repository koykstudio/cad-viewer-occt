# Builds Open CASCADE Technology (OCCT) for CAD & DWG Viewer: shared DLLs, Release, x64 and ARM64, with only the
# modules the app uses (STEP/IGES/BREP reading and writing, meshing, shape healing, XCAF assembly structure and colours).
# No visualization back end (no OpenGL, FreeType, FreeImage, Tcl/Tk, TBB, VTK, RapidJSON).
#
# OCCT is LGPL 2.1 with the OCCT exception. The app loads these DLLs dynamically through OcctBridge.dll and never links
# them statically; this script is how anyone can rebuild them (and Settings > Advanced > "Use my own Open CASCADE
# build" loads a folder built this way, or with their own changes).
#
# Usage (on a Windows PC with Visual Studio 2022 Build Tools: C++ x64 + ARM64, CMake, Ninja):
#   powershell -File tools\occt\build.ps1 [-Arch x64|arm64|both] [-Work C:\work\winapp-cad\occt-build] [-Jobs 12]
# Output: <Work>\install-<arch>\  (bin\*.dll, lib\*.lib, inc\*.hxx)
param(
  [ValidateSet('x64', 'arm64', 'both')][string]$Arch = 'both',
  [string]$Work = 'C:\work\winapp-cad\occt-build',
  [int]$Jobs = 12
)
$ErrorActionPreference = 'Stop'
$Tag = 'V7_9_3'   # pinned upstream tag: https://github.com/Open-Cascade-SAS/OCCT/releases/tag/V7_9_3
$vs = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools'
$vcvars = "$vs\VC\Auxiliary\Build\vcvarsall.bat"
New-Item -ItemType Directory -Force $Work | Out-Null
$src = Join-Path $Work ("OCCT-" + $Tag.TrimStart('V'))   # GitHub's archive folder drops the V
if (-not (Test-Path "$src\CMakeLists.txt")) {
  $tgz = Join-Path $Work "$Tag.tar.gz"
  if (-not (Test-Path $tgz)) { curl.exe -L --fail -o $tgz "https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/$Tag.tar.gz" }
  tar.exe -xzf $tgz -C $Work
}
# Our patches to upstream, if any (none so far): tools\occt\patches\*.patch, applied with git apply.

$archs = if ($Arch -eq 'both') { @('x64', 'arm64') } else { @($Arch) }
foreach ($a in $archs) {
  $build = Join-Path $Work "build-$a"
  $install = Join-Path $Work "install-$a"
  $vcarg = if ($a -eq 'x64') { 'x64' } else { 'x64_arm64' }
  $opts = @(
    '-G Ninja', '-DCMAKE_BUILD_TYPE=Release', "-DINSTALL_DIR=`"$install`"", '-DBUILD_LIBRARY_TYPE=Shared',
    '-DBUILD_MODULE_FoundationClasses=ON', '-DBUILD_MODULE_ModelingData=ON', '-DBUILD_MODULE_ModelingAlgorithms=ON',
    '-DBUILD_MODULE_Visualization=ON', '-DBUILD_MODULE_ApplicationFramework=ON', '-DBUILD_MODULE_DataExchange=ON',
    '-DBUILD_MODULE_DETools=OFF', '-DBUILD_MODULE_Draw=OFF', '-DBUILD_DOC_Overview=OFF', '-DBUILD_SAMPLES_QT=OFF',
    '-DUSE_OPENGL=OFF', '-DUSE_GLES2=OFF', '-DUSE_D3D=OFF', '-DUSE_FREETYPE=OFF', '-DUSE_FREEIMAGE=OFF', '-DUSE_FFMPEG=OFF',
    '-DUSE_OPENVR=OFF', '-DUSE_TBB=OFF', '-DUSE_VTK=OFF', '-DUSE_RAPIDJSON=OFF', '-DUSE_DRACO=OFF', '-DUSE_TK=OFF',
    '-DUSE_TCL=OFF', '-DUSE_XLIB=OFF', '-DBUILD_USE_PCH=ON', '-DBUILD_OPT_PROFILE=Production'
  ) -join ' '
  $cmd = "call `"$vcvars`" $vcarg >nul && cmake -S `"$src`" -B `"$build`" $opts && cmake --build `"$build`" -j $Jobs && cmake --install `"$build`""
  Write-Host "== OCCT $Tag $a"
  cmd.exe /c $cmd
  if ($LASTEXITCODE -ne 0) { throw "OCCT build failed for $a ($LASTEXITCODE)" }
  Get-ChildItem "$install\win64\vc14\bin\*.dll", "$install\bin\*.dll" -ErrorAction SilentlyContinue | Measure-Object Length -Sum |
    ForEach-Object { "{0}: {1} DLLs, {2:N1} MB" -f $a, $_.Count, ($_.Sum / 1MB) }
}
