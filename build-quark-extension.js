const fs = require('fs');
const path = require('path');
const archiver = require('archiver');

// 读取package.json获取版本号
const packageJson = JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8'));

const version = packageJson.version;
const extensionName = 'cross-request-quark';
const outputDir = path.join(__dirname, 'dist');
const outputFile = path.join(outputDir, `${extensionName}-v${version}.zip`);

// 创建输出目录
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// 创建一个输出流
const output = fs.createWriteStream(outputFile);
const archive = archiver('zip', {
  zlib: { level: 9 } // 设置最大压缩级别
});

// 监听完成事件
output.on('close', function () {
  console.log(`✅ 夸克浏览器扩展构建完成!`);
  console.log(`📦 文件: ${outputFile}`);
  console.log(`💾 大小: ${(archive.pointer() / 1024).toFixed(2)} KB`);
});

archive.on('error', function (err) {
  throw err;
});

// 将输出流连接到归档
archive.pipe(output);

// 添加夸克浏览器扩展的文件
const quarkFiles = [
  'quark-manifest.json', // 使用夸克专用的manifest
  'background-quark.js', // 使用夸克专用的background脚本
  'content-script.js',
  'index.js',
  'jquery-3.1.1.js',
  'popup.html',
  'popup-quark.js', // 使用夸克专用的popup脚本
  'src/browser-api-adapter.js', // API适配层
];

// 添加必要的src/helpers文件
const helperFiles = fs.readdirSync(path.join(__dirname, 'src', 'helpers')).map(file => 
  path.join('src', 'helpers', file)
);

// 添加图标目录
const iconFiles = fs.readdirSync(path.join(__dirname, 'icons')).map(file => 
  path.join('icons', file)
);

// 合并所有文件
const allFiles = [...quarkFiles, ...helperFiles, ...iconFiles];

allFiles.forEach(filePath => {
  const fullPath = path.join(__dirname, filePath);
  if (fs.existsSync(fullPath)) {
    // 如果是manifest文件，使用夸克专用的
    if (filePath === 'quark-manifest.json') {
      archive.file(path.join(__dirname, 'quark-manifest.json'), { name: 'manifest.json' });
    } else {
      archive.file(fullPath, { name: filePath });
    }
  } else {
    console.warn(`⚠️  文件不存在: ${fullPath}`);
  }
});

// 添加一个README文件说明
const readmeContent = `夸克浏览器扩展 - Cross Request Master v${version}

这是一个专为夸克浏览器构建的扩展版本，具有以下特点：
- 使用API适配层兼容夸克浏览器
- 支持跨域请求处理
- 集成YApi增强功能
- 自动cURL命令生成

安装说明:
1. 在夸克浏览器中打开扩展管理页面
2. 启用开发者模式
3. 加载已解压的扩展程序
4. 选择此文件夹`;

archive.append(readmeContent, { name: 'README.txt' });

// 完成归档
archive.finalize();