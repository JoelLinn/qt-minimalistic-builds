# 1. Start Visual Studio x64 Native Tools command line.
# 2. Run powershell.exe from Native Tools cmd.
# 3. cd to path of qt5-minimalistic-builds repo.

$version_base = "6.2"
$version = "6.2.3"

$base_folder = $pwd.Path
$qt_sources_url = "https://download.qt.io/official_releases/qt/" + $version_base + "/" + $version + "/single/qt-everywhere-src-" + $version + ".zip"
$qt_archive_file = $pwd.Path + "\qt-" + $version + ".zip"
$qt_src_base_folder = $pwd.Path + "\qt-everywhere-src-" + $version

$tools_folder = $pwd.Path + "\tools\"
$type = "static-md-release"
$prefix_base_folder = "qt-" + $version + "-" + $type + "-msvc2019-x86_64"
$prefix_folder = $pwd.Path + "\" + $prefix_base_folder
$build_folder = $pwd.Path + "\bld"

# Download Qt sources, unpack.
$ProgressPreference = 'SilentlyContinue'
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

If (!(Test-Path -Path $qt_src_base_folder)) {
    Invoke-WebRequest -Uri $qt_sources_url -OutFile $qt_archive_file
    & "$tools_folder\7za.exe" x $qt_archive_file
}

# Configure.
mkdir $build_folder
pushd $build_folder

& "$qt_src_base_folder\configure.bat" `
    -release -opensource -confirm-license -opengl desktop `
    -no-dbus -no-icu -no-fontconfig -nomake examples -nomake tests `
    -optimize-size -static -prefix $prefix_folder `
    -- `
    -DQT_BUILD_SUBMODULES="qtbase"

# Compile.
cmake --build . --parallel
cmake --install . --config Release

# Copy qt.conf.
cp "$base_folder\qt.conf" "$prefix_folder\bin\"

popd
