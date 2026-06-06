# AI Coach 系统 - 技术架构设计文档

> 基于 PRD v1.0，前端采用 Flutter，后端采用 Python (FastAPI)

---

## 一、系统架构总览

```
┌─────────────────────────────────────────────────────────────────────┐
│                       Flutter 跨平台客户端                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ iOS App  │  │Android   │  │ Web (H5) │  │ macOS/Windows    │  │
│  │          │  │ App      │  │          │  │ Desktop          │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───────┬──────────┘  │
│       └──────────────┴─────────────┴────────────────┘              │
│                          共享 Dart 代码                              │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  状态管理(Bloc) │ 网络层(Dio) │ 本地存储(Hive) │ UI组件库   │  │
│  └─────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────┬─────────────────────────────────┘
                                    │ HTTPS / WSS
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Python 后端服务 (FastAPI)                         │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ 用户服务  │  │ 知识库服务 │  │ 训练服务  │  │ AI 服务代理层    │  │
│  │ Auth     │  │ Knowledge │  │ Training │  │ AI Proxy        │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────┬─────────┘  │
│  ┌──────────┐  ┌──────────────────────────────────────────────┘   │
│  │ API      │  │                                                  │
│  │ Gateway  │  │  中间件: JWT认证 | 日志 | 限流 | 错误处理        │
│  │ (FastAPI)│  │                                                  │
│  └──────────┘                                                    │
├─────────────────────────────────────────────────────────────────────┤
│                     数据存储 & 缓存                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ PostgreSQL   │  │ Redis        │  │ OSS / MinIO          │   │
│  │ (主数据库)    │  │ (缓存/会话)   │  │ (文件存储)           │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└───────────────────────────────────┬─────────────────────────────────┘
                                    │ HTTPS
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    外部 AI 服务 (不在本项目范围)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ 知识库问答     │  │ 模拟客户 Agent│  │ 教练评分 Agent      │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、前端架构设计 (Flutter)

### 2.1 技术选型

| 类别 | 选型 | 说明 |
|------|------|------|
| 框架 | Flutter 3.x + Dart 3.x | 支持 iOS / Android / Web / macOS / Windows |
| 状态管理 | flutter_bloc (Cubit) | 分层清晰，适合中大型项目 |
| 网络请求 | Dio + Retrofit | 声明式 API 定义，拦截器统一处理认证/错误 |
| 本地存储 | Hive (或 Isar) | 轻量 KV 存储，用于 Token、用户偏好、对话缓存 |
| 路由 | GoRouter | 声明式路由，支持深链接和路由守卫 |
| 国际化 | flutter_localizations + intl | 预留 i18n 能力 |
| UI 组件 | 自建 Design System | 统一主题、颜色、字体、间距规范 |
| 图表 | fl_chart | 评分雷达图、趋势图 |
| 聊天 UI | 自建 Chat Widget | 气泡组件、消息列表、打字指示器 |
| 桌面适配 | flutter_screenutil + LayoutBuilder | 响应式布局，适配不同屏幕尺寸 |

### 2.2 项目结构

```
lib/
├── app/                          # 应用入口与全局配置
│   ├── app.dart                  # MaterialApp 配置
│   ├── router.dart               # GoRouter 路由定义
│   └── di.dart                   # 依赖注入 (get_it)
│
├── core/                         # 核心基础层
│   ├── constants/                # 常量 (API 地址、存储 Key)
│   ├── errors/                   # 统一异常定义
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                  # 网络层
│   │   ├── dio_client.dart       # Dio 实例 (拦截器、BaseURL)
│   │   ├── auth_interceptor.dart # JWT 自动附加 & 刷新
│   │   └── api_result.dart       # 统一响应包装 (Success / Failure)
│   ├── storage/                  # 本地存储封装
│   │   └── local_storage.dart
│   ├── theme/                    # 主题系统
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   └── utils/                    # 工具函数
│       ├── validators.dart       # 输入校验
│       └── formatters.dart       # 格式化
│
├── features/                     # 业务功能模块 (按 Feature 拆分)
│   ├── auth/                     # 认证模块
│   │   ├── data/
│   │   │   ├── datasources/      # 数据源 (远程API / 本地缓存)
│   │   │   ├── models/           # 数据传输对象 (DTO / JSON序列化)
│   │   │   └── repositories/     # Repository 实现
│   │   ├── domain/
│   │   │   ├── entities/         # 领域实体
│   │   │   ├── repositories/     # Repository 抽象接口
│   │   │   └── usecases/         # 用例 (单一职责)
│   │   └── presentation/
│   │       ├── bloc/             # 状态管理 (Bloc / Cubit)
│   │       ├── pages/            # 页面
│   │       └── widgets/          # 模块内组件
│   │
│   ├── knowledge/                # 知识库问答模块
│   ├── training/                 # 训练模块 (大厅 + 对话 + 报告)
│   ├── profile/                  # 个人中心模块
│   └── home/                     # 首页/工作台
│
├── shared/                       # 跨模块共享组件
│   ├── widgets/                  # 通用 UI 组件
│   │   ├── chat_bubble.dart
│   │   ├── loading_indicator.dart
│   │   ├── score_radar_chart.dart
│   │   └── customer_card.dart
│   └── models/                   # 共享数据模型
│
└── main.dart                     # 入口
```

### 2.3 页面路由设计

```dart
// GoRouter 配置
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authBloc.state.isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) return '/auth/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    // ── 认证相关 ──
    GoRoute(path: '/auth/login',    builder: (_, __) => const LoginPage()),
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/auth/forgot',   builder: (_, __) => const ForgotPasswordPage()),

    // ── 主导航 (ShellRoute 底部 Tab) ──
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/',              builder: (_, __) => const HomePage()),
        GoRoute(path: '/knowledge',     builder: (_, __) => const KnowledgeChatPage()),
        GoRoute(path: '/training',      builder: (_, __) => const TrainingHallPage()),
        GoRoute(path: '/profile',       builder: (_, __) => const ProfilePage()),
      ],
    ),

    // ── 训练子页面 ──
    GoRoute(path: '/training/:customerId',          builder: (_, state) =>
      TrainingChatPage(customerId: state.pathParameters['customerId']!)),
    GoRoute(path: '/training/:sessionId/report',    builder: (_, state) =>
      TrainingReportPage(sessionId: state.pathParameters['sessionId']!)),
    GoRoute(path: '/training/history',              builder: (_, __) => const TrainingHistoryPage()),
  ],
);
```

### 2.4 状态管理示例 (训练对话)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   UI (Page)  │────►│ TrainingChat │────►│  Send Message│
│              │◄────│    Bloc      │◄────│   UseCase    │
│  渲染消息列表 │     │              │     └──────┬───────┘
│  显示加载态   │     │ states:      │            │
│  处理用户输入 │     │ - Loading    │     ┌──────▼───────┐
└──────────────┘     │ - Loaded     │     │  Repository  │
                     │ - Error      │     │  (接口抽象)   │
                     └──────────────┘     └──────┬───────┘
                                                 │
                                          ┌──────▼───────┐
                                          │  Dio Client  │
                                          │  (HTTP 调用)  │
                                          └──────────────┘
```

---

## 三、后端架构设计 (Python / FastAPI)

### 3.1 技术选型

| 类别 | 选型 | 说明 |
|------|------|------|
| Web 框架 | FastAPI | 高性能异步框架，自动生成 OpenAPI 文档 |
| ASGI 服务器 | Uvicorn | 生产级 ASGI Server |
| ORM | SQLAlchemy 2.0 (async) | 异步 ORM，支持类型提示 |
| 数据库迁移 | Alembic | 数据库 Schema 版本管理 |
| 数据校验 | Pydantic v2 | 请求/响应模型定义与自动校验 |
| 认证 | python-jose + passlib | JWT 生成/验证，密码哈希 (bcrypt) |
| 缓存 | Redis (aioredis) | 会话缓存、限流计数、对话上下文 |
| HTTP 客户端 | httpx (async) | 调用外部 AI 服务 |
| 任务队列 | Celery + Redis (可选) | 异步任务（评分报告生成等耗时操作） |
| 日志 | structlog | 结构化日志 |
| 配置 | pydantic-settings | 环境变量管理 |
| 测试 | pytest + httpx | 单元测试 + API 集成测试 |

### 3.2 项目结构

```
backend/
├── alembic/                      # 数据库迁移
│   ├── versions/
│   └── env.py
│
├── app/
│   ├── __init__.py
│   ├── main.py                   # FastAPI 应用入口
│   ├── config.py                 # 配置管理 (pydantic-settings)
│   │
│   ├── core/                     # 核心基础层
│   │   ├── __init__.py
│   │   ├── security.py           # JWT + 密码哈希
│   │   ├── deps.py               # 依赖注入 (get_db, get_current_user)
│   │   ├── exceptions.py         # 自定义异常
│   │   ├── middleware.py         # 中间件 (日志、CORS、限流)
│   │   └── database.py           # 数据库连接 (async session)
│   │
│   ├── models/                   # SQLAlchemy ORM 模型
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── customer.py
│   │   ├── training_session.py
│   │   ├── message.py
│   │   ├── training_report.py
│   │   └── knowledge_chat.py
│   │
│   ├── schemas/                  # Pydantic 请求/响应模型
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── customer.py
│   │   ├── training.py
│   │   ├── report.py
│   │   ├── knowledge.py
│   │   └── common.py             # 分页、通用响应结构
│   │
│   ├── api/                      # API 路由层
│   │   ├── __init__.py
│   │   ├── deps.py               # 路由级依赖
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py         # v1 路由聚合
│   │       ├── auth.py           # 认证相关 API
│   │       ├── users.py          # 用户管理 API
│   │       ├── knowledge.py      # 知识库问答 API
│   │       ├── training.py       # 训练模块 API
│   │       └── reports.py        # 评分报告 API
│   │
│   ├── services/                 # 业务逻辑层
│   │   ├── __init__.py
│   │   ├── auth_service.py       # 认证业务逻辑
│   │   ├── user_service.py       # 用户业务逻辑
│   │   ├── knowledge_service.py  # 知识库业务逻辑
│   │   ├── training_service.py   # 训练流程编排
│   │   └── report_service.py     # 报告处理逻辑
│   │
│   ├── ai_proxy/                 # AI 服务代理层
│   │   ├── __init__.py
│   │   ├── base.py               # 基础 HTTP 客户端 + 重试策略
│   │   ├── knowledge_client.py   # 知识库问答服务客户端
│   │   ├── customer_client.py    # 模拟客户服务客户端
│   │   └── coach_client.py       # 教练评分服务客户端
│   │
│   └── utils/                    # 工具函数
│       ├── __init__.py
│       └── pagination.py         # 分页工具
│
├── tests/                        # 测试
│   ├── conftest.py
│   ├── test_auth.py
│   ├── test_knowledge.py
│   └── test_training.py
│
├── .env.example                  # 环境变量模板
├── alembic.ini
├── pyproject.toml                # 项目配置 & 依赖
└── Dockerfile
```

### 3.3 API 路由设计

```python
# app/api/v1/router.py
api_router = APIRouter()

# ── 认证 (公开) ──
api_router.include_router(auth.router,     prefix="/auth",    tags=["认证"])

# ── 用户 (需认证) ──
api_router.include_router(users.router,    prefix="/users",   tags=["用户"])

# ── 知识库 (需认证) ──
api_router.include_router(knowledge.router, prefix="/knowledge", tags=["知识库"])

# ── 训练 (需认证) ──
api_router.include_router(training.router, prefix="/training",  tags=["训练"])
```

完整 API 列表：

```
# ═══ 认证 ═══
POST   /api/v1/auth/register          # 用户注册
POST   /api/v1/auth/login             # 用户登录 (返回 access_token + refresh_token)
POST   /api/v1/auth/refresh           # 刷新 Token
POST   /api/v1/auth/logout            # 登出 (可选: 加入黑名单)
POST   /api/v1/auth/password/reset    # 重置密码

# ═══ 用户 ═══
GET    /api/v1/users/me               # 获取当前用户信息
PUT    /api/v1/users/me               # 更新用户信息
PUT    /api/v1/users/me/password      # 修改密码
PUT    /api/v1/users/me/avatar        # 上传/更新头像

# ═══ 知识库 ═══
POST   /api/v1/knowledge/chat         # 发送问题，获取回答
GET    /api/v1/knowledge/history      # 历史记录 (分页)
POST   /api/v1/knowledge/feedback     # 对回答进行反馈

# ═══ 训练 ═══
GET    /api/v1/training/customers            # 模拟客户列表
GET    /api/v1/training/customers/:id        # 客户详情
POST   /api/v1/training/sessions             # 创建训练会话
POST   /api/v1/training/sessions/:id/chat    # 发送消息 (对话中)
POST   /api/v1/training/sessions/:id/end     # 结束训练
GET    /api/v1/training/sessions/:id/report  # 获取评分报告
GET    /api/v1/training/history              # 训练历史 (分页)
GET    /api/v1/training/statistics           # 训练统计
```

---

## 四、用户系统设计

### 4.1 用户模型

```python
# app/models/user.py
class User(Base):
    __tablename__ = "users"

    id            = Column(UUID, primary_key=True, default=uuid4)
    phone         = Column(String(20), unique=True, index=True, nullable=False)  # 手机号登录
    password_hash = Column(String(255), nullable=False)
    name          = Column(String(50), nullable=False)
    avatar        = Column(String(500), nullable=True)        # 头像 URL
    role          = Column(Enum(UserRole), default=UserRole.SALES)  # 角色
    organization  = Column(String(100), nullable=True)        # 所属组织
    is_active     = Column(Boolean, default=True)
    last_login_at = Column(DateTime, nullable=True)
    created_at    = Column(DateTime, default=func.now())
    updated_at    = Column(DateTime, default=func.now(), onupdate=func.now())

class UserRole(str, Enum):
    ADMIN     = "admin"      # 管理员
    MANAGER   = "manager"    # 销售主管
    SALES     = "sales"      # 销售/课程顾问
```

### 4.2 认证流程

```
┌──────────┐                         ┌──────────┐                      ┌──────────┐
│  Client  │                         │  Backend │                      │ Database │
└────┬─────┘                         └────┬─────┘                      └────┬─────┘
     │                                     │                                 │
     │  POST /auth/register                │                                 │
     │  { phone, password, name }          │                                 │
     │────────────────────────────────────►│  检查手机号唯一性                  │
     │                                     │────────────────────────────────►│
     │                                     │  bcrypt 哈希密码                  │
     │                                     │────────────────────────────────►│
     │           201 Created               │         创建用户                  │
     │◄────────────────────────────────────│                                 │
     │                                     │                                 │
     │  POST /auth/login                   │                                 │
     │  { phone, password }                │                                 │
     │────────────────────────────────────►│  查找用户 & 验证密码              │
     │                                     │────────────────────────────────►│
     │                                     │                                 │
     │           200 OK                    │  生成 JWT (access + refresh)     │
     │  { access_token, refresh_token,     │                                 │
     │    token_type, expires_in }         │                                 │
     │◄────────────────────────────────────│                                 │
     │                                     │                                 │
     │  GET /api/v1/users/me               │                                 │
     │  Authorization: Bearer <token>      │                                 │
     │────────────────────────────────────►│  验证 JWT → 提取 user_id         │
     │                                     │────────────────────────────────►│
     │           200 OK { user }           │                                 │
     │◄────────────────────────────────────│                                 │
```

### 4.3 JWT Token 设计

```python
# Access Token:  短有效期 (30 分钟)，用于 API 认证
# Refresh Token: 长有效期 (7 天)，用于刷新 Access Token

payload = {
    "sub": user_id,           # 用户ID
    "role": user_role,        # 角色 (用于 RBAC)
    "type": "access",         # token 类型
    "exp": expire_timestamp,  # 过期时间
    "iat": issued_at,         # 签发时间
}
```

### 4.4 权限控制 (RBAC)

```python
# app/core/security.py

# 角色权限矩阵
PERMISSIONS = {
    "admin":   ["manage_users", "view_all_reports", "manage_customers", "training"],
    "manager": ["view_team_reports", "manage_customers", "training"],
    "sales":   ["training", "view_own_reports"],
}

# 依赖注入: 要求特定角色
def require_role(*roles: UserRole):
    async def checker(current_user: User = Depends(get_current_user)):
        if current_user.role not in roles:
            raise HTTPException(403, "权限不足")
        return current_user
    return checker

# 使用示例
@router.get("/users")
async def list_users(user: User = Depends(require_role(UserRole.ADMIN))):
    ...
```

---

## 五、数据库设计

### 5.1 ER 图

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────────┐
│    users     │       │ knowledge_chats  │       │    customers     │
├──────────────┤       ├──────────────────┤       ├──────────────────┤
│ id (PK,UUID) │──┐    │ id (PK)          │       │ id (PK)          │
│ phone        │  │    │ user_id (FK) ─────│──►    │ name             │
│ password_hash│  │    │ conversation_id  │       │ avatar           │
│ name         │  │    │ question         │       │ difficulty       │
│ avatar       │  │    │ answer           │       │ persona (JSONB)  │
│ role         │  │    │ sources (JSONB)  │       │ scenario (JSONB) │
│ organization │  │    │ category         │       │ is_active        │
│ is_active    │  │    │ feedback         │       │ created_at       │
│ last_login_at│  │    │ created_at       │       └────────┬─────────┘
│ created_at   │  │    └──────────────────┘                │
│ updated_at   │  │                                        │
└──────┬───────┘  │                                        │
       │          │                                        │
       │          │    ┌──────────────────┐                │
       │          └───►│training_sessions │◄───────────────┘
       │               ├──────────────────┤
       │               │ id (PK, UUID)    │
       └──────────────►│ user_id (FK)     │
                       │ customer_id (FK) │
                       │ status           │──┐
                       │ end_reason       │  │
                       │ started_at       │  │    ┌──────────────────────┐
                       │ ended_at         │  │    │ training_reports     │
                       └──────┬───────────┘  │    ├──────────────────────┤
                              │              └───►│ id (PK)              │
                              │                   │ session_id (FK, UQ)  │
                              │                   │ overall_score        │
                              │                   │ scores (JSONB)       │
                              │                   │ highlights (JSONB)   │
                              │                   │ improvements (JSONB) │
                              │                   │ annotations (JSONB)  │
                              │                   │ created_at           │
                              │                   └──────────────────────┘
                              │
                       ┌──────▼───────────┐
                       │    messages      │
                       ├──────────────────┤
                       │ id (PK)          │
                       │ session_id (FK)  │
                       │ role (enum)      │
                       │ content          │
                       │ emotion          │  ← 模拟客户消息附带情绪状态
                       │ metadata (JSONB) │  ← 扩展字段
                       │ created_at       │
                       └──────────────────┘
```

### 5.2 完整建表 SQL

```sql
-- ══════════════════════════════════════════
-- 用户表
-- ══════════════════════════════════════════
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone         VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name          VARCHAR(50) NOT NULL,
    avatar        VARCHAR(500),
    role          VARCHAR(20) NOT NULL DEFAULT 'sales'
                  CHECK (role IN ('admin', 'manager', 'sales')),
    organization  VARCHAR(100),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role  ON users(role);

-- ══════════════════════════════════════════
-- 模拟客户表
-- ══════════════════════════════════════════
CREATE TABLE customers (
    id          VARCHAR(50) PRIMARY KEY,     -- customer_001
    name        VARCHAR(50) NOT NULL,
    avatar      VARCHAR(500),
    difficulty  VARCHAR(20) NOT NULL DEFAULT '中等'
                CHECK (difficulty IN ('简单', '中等', '困难')),
    persona     JSONB NOT NULL,              -- 画像数据
    scenario    JSONB NOT NULL,              -- 场景数据
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ══════════════════════════════════════════
-- 训练会话表
-- ══════════════════════════════════════════
CREATE TABLE training_sessions (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    customer_id   VARCHAR(50) NOT NULL REFERENCES customers(id),
    status        VARCHAR(20) NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active', 'completed')),
    end_reason    VARCHAR(20)
                  CHECK (end_reason IN ('purchased', 'manual')),
    started_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at      TIMESTAMPTZ
);

CREATE INDEX idx_sessions_user     ON training_sessions(user_id);
CREATE INDEX idx_sessions_customer ON training_sessions(customer_id);
CREATE INDEX idx_sessions_status   ON training_sessions(status);

-- ══════════════════════════════════════════
-- 对话消息表
-- ══════════════════════════════════════════
CREATE TABLE messages (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id  UUID NOT NULL REFERENCES training_sessions(id) ON DELETE CASCADE,
    role        VARCHAR(20) NOT NULL CHECK (role IN ('user', 'customer')),
    content     TEXT NOT NULL,
    emotion     VARCHAR(50),                  -- 模拟客户情绪
    metadata    JSONB DEFAULT '{}',           -- 扩展元数据
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_messages_session ON messages(session_id);
CREATE INDEX idx_messages_created ON messages(session_id, created_at);

-- ══════════════════════════════════════════
-- 训练报告表
-- ══════════════════════════════════════════
CREATE TABLE training_reports (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id    UUID NOT NULL UNIQUE REFERENCES training_sessions(id) ON DELETE CASCADE,
    overall_score SMALLINT NOT NULL CHECK (overall_score BETWEEN 0 AND 100),
    scores        JSONB NOT NULL,             -- 六维度评分
    highlights    JSONB NOT NULL DEFAULT '[]',
    improvements  JSONB NOT NULL DEFAULT '[]',
    annotations   JSONB NOT NULL DEFAULT '[]', -- 对话批注
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ══════════════════════════════════════════
-- 知识库对话表
-- ══════════════════════════════════════════
CREATE TABLE knowledge_chats (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id UUID NOT NULL,             -- 多轮对话会话ID
    question        TEXT NOT NULL,
    answer          TEXT NOT NULL,
    sources         JSONB DEFAULT '[]',
    category        VARCHAR(50),
    feedback        VARCHAR(10)                 -- 'helpful' / 'unhelpful'
                  CHECK (feedback IN ('helpful', 'unhelpful') OR feedback IS NULL),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_knowledge_user    ON knowledge_chats(user_id);
CREATE INDEX idx_knowledge_conv    ON knowledge_chats(user_id, conversation_id);
```

---

## 六、核心业务流程

### 6.1 AI 服务代理层设计

```python
# app/ai_proxy/base.py
class AIServiceClient:
    """外部 AI 服务基础客户端"""

    def __init__(self, base_url: str, timeout: int = 30):
        self.client = httpx.AsyncClient(
            base_url=base_url,
            timeout=timeout,
            headers={"Authorization": f"Bearer {settings.AI_SERVICE_API_KEY}"},
        )

    async def _request(self, method: str, path: str, **kwargs) -> dict:
        """统一请求封装，含重试与降级"""
        for attempt in range(3):
            try:
                response = await self.client.request(method, path, **kwargs)
                response.raise_for_status()
                return response.json()
            except httpx.TimeoutException:
                if attempt == 2:
                    raise AIServiceTimeoutError("AI 服务响应超时")
                await asyncio.sleep(0.5 * (attempt + 1))
            except httpx.HTTPStatusError as e:
                raise AIServiceError(f"AI 服务错误: {e.response.status_code}")
```

### 6.2 训练流程编排

```python
# app/services/training_service.py
class TrainingService:

    async def start_session(self, user_id: UUID, customer_id: str, db: AsyncSession):
        """创建训练会话"""
        customer = await db.get(Customer, customer_id)
        if not customer or not customer.is_active:
            raise NotFoundError("客户不存在")

        session = TrainingSession(
            user_id=user_id,
            customer_id=customer_id,
        )
        db.add(session)
        await db.commit()

        # 返回会话信息 + 客户开场白 (由 AI 服务生成)
        opening = await self.customer_client.get_opening(customer_id, session.id)
        return session, opening

    async def send_message(self, session_id: UUID, content: str, db: AsyncSession):
        """发送消息并获取模拟客户回复"""
        session = await self._get_active_session(session_id, db)

        # 1. 存储用户消息
        user_msg = Message(session_id=session_id, role="user", content=content)
        db.add(user_msg)

        # 2. 加载对话历史
        history = await self._load_history(session_id, db)

        # 3. 调用外部模拟客户服务
        ai_response = await self.customer_client.chat(
            customer_id=session.customer_id,
            session_id=str(session_id),
            message=content,
            dialogue_history=history,
        )

        # 4. 存储模拟客户回复
        customer_msg = Message(
            session_id=session_id,
            role="customer",
            content=ai_response["reply"],
            emotion=ai_response.get("emotion"),
        )
        db.add(customer_msg)
        await db.commit()

        # 5. 检查是否成交
        if ai_response.get("is_purchased"):
            await self._end_session(session, db, end_reason="purchased")

        return {
            "message": customer_msg,
            "is_purchased": ai_response.get("is_purchased", False),
            "emotion": ai_response.get("emotion"),
            "session_ended": ai_response.get("is_purchased", False),
        }

    async def end_session(self, session_id: UUID, db: AsyncSession):
        """手动结束训练"""
        session = await self._get_active_session(session_id, db)
        await self._end_session(session, db, end_reason="manual")

    async def _end_session(self, session, db: AsyncSession, end_reason: str):
        """结束会话并触发评分"""
        session.status = "completed"
        session.end_reason = end_reason
        session.ended_at = func.now()
        await db.commit()

        # 异步触发评分 (可选: 放入 Celery 任务队列)
        await self._generate_report(session, db)

    async def _generate_report(self, session, db: AsyncSession):
        """调用外部教练评分服务生成报告"""
        dialogue = await self._load_dialogue_for_report(session.id, db)

        evaluation = await self.coach_client.evaluate(
            session_id=str(session.id),
            customer_id=session.customer_id,
            dialogue=dialogue,
            end_reason=session.end_reason,
        )

        report = TrainingReport(
            session_id=session.id,
            overall_score=evaluation["overall_score"],
            scores=evaluation["scores"],
            highlights=evaluation.get("highlights", []),
            improvements=evaluation.get("improvements", []),
            annotations=evaluation.get("dialogue_annotations", []),
        )
        db.add(report)
        await db.commit()
```

---

## 七、缓存策略

```
┌────────────────────────────────────────────────────────────┐
│                       Redis 缓存设计                        │
├──────────────────────┬─────────────────────────────────────┤
│ Key 模式              │ 说明                 │ TTL          │
├──────────────────────┼─────────────────────┼──────────────┤
│ user:{id}            │ 用户信息缓存          │ 30 min       │
│ customer:list        │ 模拟客户列表缓存       │ 1 hour       │
│ customer:{id}        │ 客户详情缓存          │ 1 hour       │
│ session:{id}:history │ 训练会话对话历史       │ 会话存活期    │
│ knowledge:conv:{id}  │ 知识库对话上下文       │ 2 hours      │
│ ratelimit:{user_id}  │ API 限流计数器        │ 1 min        │
│ token:blacklist:{jti}│ Token 黑名单 (登出)   │ Token 有效期  │
└──────────────────────┴─────────────────────┴──────────────┘
```

---

## 八、安全设计

| 层级 | 措施 |
|------|------|
| 传输 | 全站 HTTPS，HSTS 头 |
| 认证 | JWT (RS256 签名)，Access Token 30min 过期 |
| 密码 | bcrypt 哈希，salt rounds=12 |
| API | 速率限制 (100 req/min per user) |
| 输入 | Pydantic 严格校验，防 SQL 注入 (ORM 参数化) |
| CORS | 白名单域名，非 * 通配 |
| 敏感数据 | 手机号脱敏展示，密码/Token 不入日志 |
| AI 代理 | 出站请求签名，超时熔断 |

---

## 九、部署架构

```
                    ┌─────────────┐
                    │   Nginx     │  (反向代理 + SSL 终结)
                    │   / CDN     │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼────┐ ┌────▼─────┐ ┌───▼──────┐
        │ FastAPI  │ │ FastAPI  │ │ Flutter  │
        │ Worker 1 │ │ Worker 2 │ │ Web (静态)│
        │ (Uvicorn)│ │ (Uvicorn)│ │          │
        └─────┬────┘ └────┬─────┘ └──────────┘
              │            │
        ┌─────▼────────────▼─────┐
        │      PostgreSQL        │
        │      + Redis           │
        └────────────────────────┘
```

### Docker Compose (开发环境)

```yaml
services:
  backend:
    build: ./backend
    ports: ["8000:8000"]
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/ai_coach
      - REDIS_URL=redis://redis:6379/0
      - AI_SERVICE_BASE_URL=https://ai-service.example.com
      - AI_SERVICE_API_KEY=${AI_SERVICE_API_KEY}
      - JWT_SECRET_KEY=${JWT_SECRET_KEY}
    depends_on: [db, redis]

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ai_coach
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports: ["5432:5432"]
    volumes: [pgdata:/var/lib/postgresql/data]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

volumes:
  pgdata:
```

---

## 十、开发阶段规划

### Phase 1 - 基础框架搭建

| 任务 | 前端 (Flutter) | 后端 (FastAPI) |
|------|----------------|----------------|
| 项目初始化 | Flutter 项目结构搭建，Design System | FastAPI 项目结构，Alembic 初始化 |
| 用户系统 | 登录/注册页面，Token 持久化 | 注册/登录 API，JWT 认证，用户 CRUD |
| 基础设施 | Dio 封装，路由守卫，Bloc 模板 | 中间件 (日志/CORS/限流)，统一响应格式 |
| 数据库 | - | 建表，Alembic 迁移脚本 |

### Phase 2 - 核心功能开发

| 任务 | 前端 | 后端 |
|------|------|------|
| 知识库问答 | 聊天 UI，消息气泡，打字效果 | 知识库 API，AI 代理层 (Mock) |
| 训练大厅 | 客户卡片列表，难度筛选 | 客户 CRUD API，客户数据 Seed |
| 训练对话 | 聊天界面，消息收发，结束流程 | 训练会话管理，消息转发 AI 代理 |
| 训练报告 | 雷达图，维度评分，对话回放 | 报告生成 API，AI 评分代理 |

### Phase 3 - 完善与上线

| 任务 | 说明 |
|------|------|
| 对接真实 AI 服务 | 替换 Mock，联调外部 AI 服务 |
| 训练历史与统计 | 历史记录列表，趋势图表 |
| PC/Web 适配 | Flutter Web 编译，响应式布局优化 |
| 性能优化 | 缓存策略，懒加载，分页优化 |
| 部署上线 | Docker 化，CI/CD，生产环境配置 |
