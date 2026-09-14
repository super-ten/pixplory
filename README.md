# Pixplory · AI 全棧創作索引

一个面向小团队的实时协作知识索引。前端为 React PWA，GitHub Pages 托管；认证、数据、实时同步和版本历史由 Supabase 提供。

## 本地运行

1. 安装依赖：`npm install`
2. 复制 `.env.example` 为 `.env.local`，填入 Supabase URL 和 publishable key。
3. 启动：`npm run dev`

未配置 Supabase 时，页面只显示从原 HTML 提取的迁移预览，并禁止编辑；预览内容不是正式保存数据。

## Supabase 初始化

1. 创建 Supabase 项目并安装 Supabase CLI。
2. 关联项目：`supabase link --project-ref <project-ref>`。
3. 推送数据库：`supabase db push`。
4. 导入原始内容：在 SQL Editor 执行 `supabase/seed.sql`，或使用 CLI 的种子流程。
5. 在 Supabase 中设置私密邀请码：`supabase secrets set APP_INVITE_CODE=<你的邀请码>`。不要把实际邀请码提交到公开仓库。
6. 部署函数：
   - `supabase functions deploy register --no-verify-jwt`
   - `supabase functions deploy username-login --no-verify-jwt`
7. 在 Auth URL Configuration 中设置 Site URL 为 `https://pixplory.com`，并加入本地与 `www` 回调地址。
8. 在 Realtime Settings 中关闭 public channel access，使 `workspace:main` 的 RLS 策略生效。

数据库迁移会建立分类、条目、详细笔记、审计历史、命名快照、RLS、实时发布、乐观并发控制和管理员恢复函数。首次成功注册者会在事务锁保护下成为唯一的首位管理员。

## GitHub Pages 部署

1. 创建 GitHub 仓库并将本项目推送到 `main`。
2. 仓库 Settings → Pages，将 Source 设为 GitHub Actions。
3. 添加 Actions secrets：`VITE_SUPABASE_URL` 和 `VITE_SUPABASE_PUBLISHABLE_KEY`。
4. 在 Pages 中先配置 `pixplory.com`，再到阿里云 DNS 配置根域名 A 记录与 `www` CNAME。
5. DNS 生效后启用 Enforce HTTPS。

`public/CNAME` 会随构建进入 Pages 产物。发布工作流会先执行测试和构建，成功后才部署。

## PWA 与数据原则

- 支持浏览器安装到 macOS 程序坞和 Windows 开始菜单。
- Service Worker 只缓存程序代码、样式和图标，不缓存 Supabase API 响应。
- 离线时隐藏业务内容并禁止编辑；联网后重新加载云端最新版。
- 浏览器只使用 publishable key。绝不要把 service-role key、邀请码或其他密钥写入 `.env` 并提交。

## 原始数据

- `AI全棧創作索引.html`：保留的原始文件，不再作为运行入口。
- `scripts/extract-legacy-data.mjs`：从原文件的唯一 `app-data` 区块提取数据。
- `src/data/seed.json`：未配置云端时使用的只读迁移预览。
- `supabase/seed.sql`：供新数据库首次导入的 5 个分类与 27 个条目。
