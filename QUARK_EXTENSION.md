# Cross Request Master - 夸克浏览器扩展

Cross Request Master 现已支持夸克浏览器！这是一个专为夸克浏览器构建的扩展版本，具有与Chrome扩展相同的功能。

## 功能特性

- ✅ **跨域请求（CORS bypass）**：在页面侧调用 `crossRequest`，由扩展后台代发
- ✅ **内嵌 cURL**：YApi「运行」页 URL 下方展示可复制的 cURL 命令
- ✅ **路径参数引导**：URL 含 `{param}` 时提示填写，避免请求失败
- ✅ **固定 Header**：为跨域请求自动追加自定义 Header
- ✅ **YApi 工具箱**：一键生成 MCP 配置 / Skill 安装（支持 Codex/Claude/Cursor）/ CLI 使用与 docs-sync
- ✅ **复制给 AI**：把当前接口信息整理为 Markdown 一键复制
- ✅ **jQuery/Fetch 支持**：兼容 `$.ajax` / `fetch` / 脚本能力

## 安装方法

### 方法一：构建安装包

1. 在项目根目录运行构建脚本：
   ```bash
   npm run build:quark
   # 或者直接执行
   bash build-quark-extension.sh
   ```

2. 在夸克浏览器中：
   - 打开地址栏输入 `quark://extensions/` 进入扩展管理页面
   - 启用"开发者模式"
   - 点击"加载已解压的扩展程序"
   - 选择 `dist` 目录下的构建文件

### 方法二：开发者模式安装

1. 克隆或下载项目代码
2. 在夸克浏览器中：
   - 打开地址栏输入 `quark://extensions/` 进入扩展管理页面
   - 启用"开发者模式"
   - 点击"加载已解压的扩展程序"
   - 选择 `quark-build` 目录（使用构建脚本生成）或使用 `quark-manifest.json` 的项目根目录

## 技术实现

### API 兼容层

夸克浏览器扩展使用了统一的浏览器 API 适配层，确保在不同浏览器环境下的兼容性：

- 使用 `browser` 或 `chrome` API 命名空间的兼容性处理
- Promise 化的异步 API 调用
- 统一的错误处理机制

### 文件结构

夸克浏览器扩展包含以下专用文件：

- `background-quark.js` - 适配夸克浏览器的后台脚本
- `popup-quark.js` - 适配夸克浏览器的弹出页面脚本
- `quark-manifest.json` - 夸克浏览器专用的清单文件
- `src/browser-api-adapter.js` - 浏览器 API 兼容层

## 使用方法

安装完成后，使用方法与 Chrome 版本完全相同：

### 在 YApi 中

安装后直接在 YApi「运行」页发送请求即可，扩展会自动处理跨域、显示 cURL，并把 JSON 响应解析为对象供脚本使用。

在接口详情页（基本信息区域右上角）额外提供：
- **YApi 工具箱**：包含 MCP 配置（所有项目）、Skill 一键安装（支持 Codex/Claude/Cursor）、CLI 使用与 docs-sync 说明（自动拼好命令）
- **复制给 AI**：把当前接口信息整理成 Markdown（仅接口相关字段）复制到剪贴板

### YApi OpenAPI（Yapi-MCP tool 同名方法）

扩展在页面侧额外暴露 `window.crossRequest.yapiMcp`（也可用 `window.crossRequest.yapi`），把 YApi OpenAPI 封装成与 Yapi-MCP 一致的 5 个方法，方便直接在浏览器控制台/脚本里操作接口文档：

```js
// 先配置（支持多项目：'28:token1,29:token2'）
window.crossRequest.yapiMcp.configure({
  baseUrl: 'https://your-yapi-domain.com',
  token: '28:your_project_token'
});

// 查接口、拉分类、搜索、保存
const api = await window.crossRequest.yapiMcp.yapi_get_api_desc({ projectId: '28', apiId: '66' });
```

## 注意事项

- 本扩展仅供开发测试使用，请勿在生产环境使用
- 扩展不会上传你的请求数据，所有配置仅保存在本地浏览器
- 所有跨域请求均由扩展后台代理发送，保证安全性

## 问题反馈

如遇到问题，请在 GitHub 仓库提交 Issue：
https://github.com/leeguooooo/cross-request-master/issues

## 许可证

MIT License