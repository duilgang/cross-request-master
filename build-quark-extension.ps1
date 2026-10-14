# Cross Request Master - Quark Browser Extension Build Script (PowerShell Version)
# 用于打包夸克浏览器扩展

Write-Output "🚀 开始打包 Cross Request Master 夸克浏览器扩展..."

# 设置变量
$EXTENSION_NAME = "cross-request-quark"
$VERSION = (Get-Content package.json | ConvertFrom-Json).version
$BUILD_DIR = "quark-build"
$DIST_DIR = "dist"
$ZIP_NAME = "${EXTENSION_NAME}-v${VERSION}.zip"

Write-Output "📦 版本: $VERSION"
Write-Output "📁 构建目录: $BUILD_DIR"
Write-Output "📁 发布目录: $DIST_DIR"
Write-Output "📄 输出文件: $ZIP_NAME"

# 清理旧的构建目录
if (Test-Path $BUILD_DIR) {
    Write-Output "🧹 清理旧的构建目录..."
    Remove-Item -Path $BUILD_DIR -Recurse -Force
}

# 清理旧的发布目录
if (Test-Path $DIST_DIR) {
    Write-Output "🧹 清理旧的发布目录..."
    Remove-Item -Path $DIST_DIR -Recurse -Force
}

# 创建目录
Write-Output "📁 创建构建和发布目录..."
New-Item -ItemType Directory -Path $BUILD_DIR -Force
New-Item -ItemType Directory -Path $DIST_DIR -Force

# 复制夸克浏览器扩展文件
Write-Output "📋 复制夸克浏览器扩展文件..."

# 核心文件 - 使用夸克专用版本
Copy-Item -Path "quark-manifest.json" -Destination "$BUILD_DIR\manifest.json"  # 使用夸克专用manifest
Copy-Item -Path "background-quark.js" -Destination "$BUILD_DIR\background.js"  # 使用夸克专用background
Copy-Item -Path "popup-quark.js" -Destination "$BUILD_DIR\popup.js"            # 使用夸克专用popup
Copy-Item -Path "popup.html" -Destination $BUILD_DIR

# 其他核心文件
Copy-Item -Path "content-script.js" -Destination $BUILD_DIR
Copy-Item -Path "index.js" -Destination $BUILD_DIR
Copy-Item -Path "jquery-3.1.1.js" -Destination $BUILD_DIR

# API适配层
$adapterDir = "$BUILD_DIR\src"
if (!(Test-Path $adapterDir)) {
    New-Item -ItemType Directory -Path $adapterDir -Force
}
Copy-Item -Path "src\browser-api-adapter.js" -Destination "$adapterDir\"

# 帮助文件
Copy-Item -Path "src\helpers" -Destination "$BUILD_DIR\src" -Recurse

# 图标目录
Copy-Item -Path "icons" -Destination $BUILD_DIR -Recurse

# 创建说明文件
$readmeContent = @"
夸克浏览器扩展 - Cross Request Master v$VERSION

这是一个专为夸克浏览器构建的扩展版本，具有以下特点：
- 使用API适配层兼容夸克浏览器
- 支持跨域请求处理
- 集成YApi增强功能
- 自动cURL命令生成

安装说明:
1. 在夸克浏览器中打开扩展管理页面
2. 启用开发者模式
3. 加载已解压的扩展程序
4. 选择此文件夹
"@

Set-Content -Path "$BUILD_DIR\README.txt" -Value $readmeContent

# 打包成ZIP
Write-Output "📦 打包成ZIP文件..."
Compress-Archive -Path "$BUILD_DIR\*" -DestinationPath "$DIST_DIR\$ZIP_NAME" -Force

# 验证打包结果
Write-Output "✅ 验证打包结果..."
if (Test-Path "$DIST_DIR\$ZIP_NAME") {
    Write-Output "🎉 夸克浏览器扩展打包成功!"
    Write-Output "📁 文件位置: $DIST_DIR\$ZIP_NAME"
    
    # 获取文件大小
    $fileInfo = Get-Item "$DIST_DIR\$ZIP_NAME"
    $sizeInKB = [math]::Round($fileInfo.Length / 1KB, 2)
    Write-Output "📏 文件大小: $sizeInKB KB"
    
    # 显示ZIP内容（前20个项目）
    Write-Output ""
    Write-Output "📋 ZIP文件内容:"
    $zipItems = (Get-ChildItem -Path "$DIST_DIR\$ZIP_NAME" -Stream * -ErrorAction SilentlyContinue | Where-Object {$_.Name -ne ':Zone.Identifier'}).Count
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead("$DIST_DIR\$ZIP_NAME")
    $zip.Entries | Select-Object -First 20 | ForEach-Object {
        Write-Output "  $($_.FullName) - $([math]::Round($_.Length / 1KB, 2)) KB"
    }
    if ($zip.Entries.Count -gt 20) {
        Write-Output "  ... (显示前20个项目，共 $($zip.Entries.Count) 个项目)"
    }
    $zip.Dispose()
} else {
    Write-Output "❌ 打包失败!"
    exit 1
}

Write-Output ""
Write-Output "✨ 夸克浏览器扩展构建完成！"
Write-Output "💡 安装方法：在夸克浏览器中启用开发者模式，然后加载已解压的扩展程序"