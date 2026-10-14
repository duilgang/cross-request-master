#!/bin/bash

# Cross Request Master - Quark Browser Extension Build Script
# 用于打包夸克浏览器扩展

set -e

echo "🚀 开始打包 Cross Request Master 夸克浏览器扩展..."

# 设置变量
EXTENSION_NAME="cross-request-quark"
VERSION=$(node -p "require('./package.json').version")
BUILD_DIR="quark-build"
DIST_DIR="dist"
ZIP_NAME="${EXTENSION_NAME}-v${VERSION}.zip"

echo "📦 版本: ${VERSION}"
echo "📁 构建目录: ${BUILD_DIR}"
echo "📁 发布目录: ${DIST_DIR}"
echo "📄 输出文件: ${ZIP_NAME}"

# 清理旧的构建目录
if [ -d "$BUILD_DIR" ]; then
    echo "🧹 清理旧的构建目录..."
    rm -rf "$BUILD_DIR"
fi

# 清理旧的发布目录
if [ -d "$DIST_DIR" ]; then
    echo "🧹 清理旧的发布目录..."
    rm -rf "$DIST_DIR"
fi

# 创建目录
echo "📁 创建构建和发布目录..."
mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"

# 复制夸克浏览器扩展文件
echo "📋 复制夸克浏览器扩展文件..."

# 核心文件 - 使用夸克专用版本
cp quark-manifest.json "$BUILD_DIR/manifest.json"  # 使用夸克专用manifest
cp background-quark.js "$BUILD_DIR/background.js"  # 使用夸克专用background
cp popup-quark.js "$BUILD_DIR/popup.js"            # 使用夸克专用popup
cp popup.html "$BUILD_DIR/"

# 其他核心文件
cp content-script.js "$BUILD_DIR/"
cp index.js "$BUILD_DIR/"
cp jquery-3.1.1.js "$BUILD_DIR/"

# API适配层
cp -r src/browser-api-adapter.js "$BUILD_DIR/src/"

# 帮助文件
cp -r src/helpers "$BUILD_DIR/src/"

# 图标目录
cp -r icons "$BUILD_DIR/"

# 创建说明文件
cat > "$BUILD_DIR/README.txt" << EOF
夸克浏览器扩展 - Cross Request Master v${VERSION}

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
EOF

# 打包成ZIP
echo "📦 打包成ZIP文件..."
cd "$BUILD_DIR"
zip -r "../$DIST_DIR/$ZIP_NAME" . -x "node_modules/*" ".git/*" ".github/*" "tests/*" "*.md" ".eslintrc.json" ".prettierrc.json" ".prettierignore" ".eslintignore" ".gitignore" "package*.json" "*.pem" "*.crx" "*.zip"
cd ..

# 验证打包结果
echo "✅ 验证打包结果..."
if [ -f "$DIST_DIR/$ZIP_NAME" ]; then
    echo "🎉 夸克浏览器扩展打包成功!"
    echo "📁 文件位置: $DIST_DIR/$ZIP_NAME"
    echo "📏 文件大小: $(du -h "$DIST_DIR/$ZIP_NAME" | cut -f1)"
    
    # 显示ZIP内容
    echo ""
    echo "📋 ZIP文件内容:"
    unzip -l "$DIST_DIR/$ZIP_NAME" | tail -n +4 | head -20
    if [ $(unzip -l "$DIST_DIR/$ZIP_NAME" | wc -l) -gt 25 ]; then
        echo "... (显示前20个项目)"
    fi
else
    echo "❌ 打包失败!"
    exit 1
fi

echo ""
echo "✨ 夸克浏览器扩展构建完成！"
echo "💡 安装方法：在夸克浏览器中启用开发者模式，然后加载已解压的扩展程序"