# GitHub Actions + Docker + Nginx Demo

一个学习 GitHub Actions 的练习项目，演示如何在提交代码到 main 分支时自动构建 Docker 镜像并推送到 GitHub Packages。

start test

## 项目结构

```
.
├── .github/workflows/
│   └── docker-publish.yml  # GitHub Actions 工作流
├── public/
│   └── index.html          # 前端页面
├── Dockerfile              # Docker 构建文件
├── nginx.conf              # Nginx 配置
└── README.md
```

## 工作原理

1. 当代码推送到 `main` 分支时，GitHub Actions 自动触发
2. 工作流登录到 GitHub Container Registry (ghcr.io)
3. 构建 Docker 镜像（基于 nginx:alpine）
4. 推送镜像到 GitHub Packages

## 本地测试

```bash
# 构建镜像
docker build -t hello-nginx .

# 运行容器
docker run -p 8080:80 hello-nginx

# 访问 http://localhost:8080
```

## 拉取已发布的镜像

```bash
docker pull ghcr.io/<owner>/<repo>:latest
docker run -p 8080:80 ghcr.io/<owner>/<repo>:latest
```

将 `<owner>/<repo>` 替换为实际的 GitHub 用户名和仓库名。

## 配置要求

仓库需要启用以下权限（默认已启用）：
- **Actions** - 读写权限
- **Packages** - 读写权限
