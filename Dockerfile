# 构建阶段
FROM node:18-alpine as builder

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 生产阶段
FROM nginx:alpine

# 复制构建产物到Nginx目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 配置Nginx以支持前端路由
RUN echo '\
server {\
    listen 80;\
    location / {\
        root /usr/share/nginx/html;\
        index index.html;\
        try_files $uri $uri/ /index.html;\
    }\
}' > /etc/nginx/conf.d/default.conf

# 暴露80端口
EXPOSE 80

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]