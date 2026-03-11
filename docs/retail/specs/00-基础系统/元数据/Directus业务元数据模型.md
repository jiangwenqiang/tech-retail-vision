# Directus 业务元数据模型

## 目的
基于 Directus 的数据建模机制，统一描述“业务模型、字段约束、关系定义、物理落库映射”，为零售系统的模型设计、接口治理和环境迁移提供规范。

## Directus 元数据总览
Directus 以数据库为中心，核心概念对应关系如下：

1. `Collection`：业务集合，对应数据库表
2. `Field`：字段定义，对应数据库列或别名字段
3. `Item`：数据记录，对应表记录
4. `Relation`：关系定义（M2O/O2M/M2M/M2A）

Directus 的平台配置与模型元数据保存在系统集合（`directus_*`）中，业务数据保存在业务集合中。

## 1. 业务模型与属性管理

### 1.1 业务模型（Collection）管理
Collection 可通过两种方式管理：

- Data Studio 的 Data Model 可视化界面
- API（如 `/collections`、`/fields`、`/relations`）

Collection 关键定义范围：

- `collection`（集合名，通常对应物理表名）
- 主键策略（`integer`、`bigInteger`、`uuid`、`string`）
- 可选系统字段（如状态、排序、审计字段）
- 访问控制（角色权限与策略）

### 1.2 实体（Collection）定义说明
Collection 的定义建议按“标识、结构、关系、展示”四层管理：

| 定义层 | 主要对象 | 关键定义项 | 说明 |
| --- | --- | --- | --- |
| 标识定义 | `collection` | 集合名、主键类型 | 决定 API 路径和主标识策略 |
| 结构定义 | `fields` | 字段 key、类型、默认值、是否可空、是否唯一、是否索引 | 决定数据存储结构和校验基础 |
| 关系定义 | `relations` | many/one 集合、关联字段、中间集合 | 决定引用关系和导航能力 |
| 展示定义 | `meta` | 图标、备注、分组、界面配置 | 决定 Studio 管理体验，不改变领域语义 |

### 1.3 属性（Field）管理
Field 由“数据库 schema + Studio field 配置”共同构成，管理范围通常包括：

- 字段标识：`field`（同集合内唯一）
- 数据类型：`type`（Directus 统一类型映射到具体数据库）
- 空值与必填：`nullable`、`required`
- 默认值与唯一性：`default_value`、`is_unique`
- 索引与检索：`is_indexed`、是否参与搜索
- 展示与交互：`interface`、`options`、`display`
- 校验规则：`validation`（规则表达式）
- 只读/隐藏：`readonly`、`hidden`

## 2. 数据类型与关系模型

### 2.1 常见数据类型
Directus 统一类型按数据库能力映射，常见类型如下：

| 类型分类 | 常见类型 | 典型业务字段 | 备注 |
| --- | --- | --- | --- |
| 文本类 | `string`、`text`、`uuid` | 名称、编码、描述 | 支持长度与唯一约束 |
| 数值类 | `integer`、`bigInteger`、`float`、`decimal` | 数量、金额、比率 | 支持范围与精度配置 |
| 布尔类 | `boolean` | 启用标识、默认标识 | 常结合默认值 |
| 时间类 | `timestamp`、`dateTime`、`date`、`time` | 生效时间、审计时间 | 注意时区策略 |
| 结构化 | `json`、`csv` | 扩展属性、标签集合 | 适合弱结构场景 |
| 二进制 | `binary` | 文件摘要/特定二进制数据 | 与文件模型配合使用 |
| 地理空间 | `point`、`polygon` 等 | 门店地理数据 | 依赖数据库空间扩展 |

### 2.2 引用关系管理
Directus 关系通过 `relations` 元数据管理，核心关系类型：

1. `Many-to-One (M2O)`：多端字段持有 one 端主键
2. `One-to-Many (O2M)`：M2O 的反向关系
3. `Many-to-Many (M2M)`：通过 junction（中间集合）管理
4. `Many-to-Any (M2A)`：多态引用到多个集合

关系定义常见要素：

- `many_collection`、`many_field`
- `one_collection`、`one_field`
- `junction_field`（M2M）
- 删除策略（如 `nullify` 等）

### 2.3 关系定义逻辑（关键）
关系定义的核心是：先确定“哪一侧持有外键列”，再由 Directus 在 `directus_relations` 中登记双向导航信息。

#### 2.3.1 Many-to-One / One-to-Many
M2O 与 O2M 是同一关系的两种视图：

1. 在 many 端集合新增外键字段（例如 `products.brand_id`）
2. 在关系元数据中登记：
   - `many_collection = products`
   - `many_field = brand_id`
   - `one_collection = brands`
   - `one_field = products`（可选，用于 one 端反向字段）
3. 运行时效果：
   - 读 `products` 可直接展开 `brand`
   - 读 `brands` 可反向拿到 `products` 列表

#### 2.3.2 Many-to-Many
M2M 通过中间集合（junction collection）实现，不直接在任一主集合存数组外键：

1. 创建中间集合（例如 `products_categories`）
2. 中间集合至少包含两列外键：
   - `product_id -> products.id`
   - `category_id -> categories.id`
3. 在关系元数据中登记 two-hop 关系：
   - `products (one) -> products_categories (many)`
   - `categories (one) -> products_categories (many)`
4. Directus 在 API 层将其抽象为 `products <-> categories` 的 M2M 关系

#### 2.3.3 Many-to-Any
M2A（多态关系）通过“目标集合标识 + 目标主键”组合实现：

1. 关系记录需同时保存“目标集合名”和“目标记录ID”
2. 运行时按集合名路由到具体 collection
3. 适合评论、附件、标签这类可挂接多业务对象的场景

#### 2.3.4 删除与一致性策略
关系定义时应明确删除策略（如 `nullify`、`restrict`、`cascade`）：

1. `nullify`：删除 one 端后，many 端外键置空
2. `restrict`：存在引用时禁止删除 one 端
3. `cascade`：删除 one 端时级联删除 many 端或中间关系记录

建议：主数据（品牌、组织）优先 `restrict`，事务附属数据可评估 `cascade`。

## 3. 元数据到物理表/列的映射

### 3.1 Collection 到表
- 业务 Collection 通常对应数据库中的同名表
- 系统元数据由 `directus_*` 系统集合维护
- M2M 关系通过中间表（junction collection）承载

### 3.2 Field 到列
- 普通字段映射为物理列
- Alias 字段可能不直接映射物理列（用于展示或关系别名）
- 关系字段根据类型落为外键列或中间表结构

### 3.3 系统元数据表（常见）
以下系统集合是理解 Directus 元数据模型的关键入口：

| 系统集合 | 作用 |
| --- | --- |
| `directus_collections` | Collection 的元信息（集合级配置） |
| `directus_fields` | Field 的元信息（字段级配置） |
| `directus_relations` | 集合间关系定义 |
| `directus_permissions` | 权限策略元数据 |
| `directus_roles` | 角色定义 |
| `directus_presets` | 默认查询/展示预设 |

### 3.4 相关表结构说明（示例）
以下为理解 Directus 元数据模型时最常用的表结构视图（以 MySQL/PostgreSQL 常见部署为参考，实际列会因版本略有差异）：

1. 业务表（示例：`products`）
   - `id`：主键
   - `name`：商品名称
   - `price`：价格
   - `brand_id`：关联 `brands.id` 的外键字段（M2O）
   - `status` / `date_created` / `date_updated`：按项目启用的系统业务字段

2. 元数据表：`directus_collections`
   - `collection`：集合名（通常对应物理表名）
   - `icon`、`note`、`display_template`：集合展示配置
   - `hidden`、`singleton`：集合行为配置
   - `accountability`：审计记录策略

3. 元数据表：`directus_fields`
   - `collection`：字段所属集合
   - `field`：字段名
   - `special`：特殊语义（如 `m2o`、`m2m`、`o2m`、`m2a` 等）
   - `interface`：Studio 输入组件
   - `options`、`display`、`display_options`：前端配置
   - `readonly`、`hidden`、`sort`：可见性与排序

4. 元数据表：`directus_relations`
   - `many_collection`、`many_field`：many 端集合与字段
   - `one_collection`、`one_field`：one 端集合与反向字段
   - `junction_field`：M2M/M2A 场景下通过中间集合连接的关键字段
   - `one_deselect_action`：删除/解绑策略（如 `nullify`）

5. M2M 中间表（示例：`products_categories`）
   - `id`：主键（可选，取决于设计）
   - `product_id`：关联 `products.id`
   - `category_id`：关联 `categories.id`
   - 可扩展字段：`sort`、`note`、`created_at`（当关系本身有业务属性时）

建议：数据库侧可通过 `SHOW CREATE TABLE`（MySQL）或 `information_schema.columns` 统一核验字段落库结果。

## 4. 环境迁移与版本治理
Directus 提供 schema migration 能力，可导出/应用数据模型变更：

1. 在开发环境调整 collections/fields/relations
2. 通过 schema migration endpoint 导出模型快照
3. 在目标环境应用快照并校验差异

建议：

1. 将 schema 快照纳入 Git 管理
2. 禁止直接在生产环境手工改模型
3. 变更前先评估字段重命名与关系变更影响

## 5. 业务模型与 UI 模型分层策略
Directus 在 Collection/Field 层同时承载了业务结构与 Studio 界面配置，实际项目中应主动分层治理，避免模型耦合失控。

### 5.1 风险说明
1. 结构耦合：字段结构变更可能连带影响界面渲染与录入流程。
2. 评审混杂：业务 schema 调整与 UI 调整混在同一变更中，难以审查。
3. 可移植性弱：过多依赖 Directus 界面元数据，迁移到其他前端成本高。

### 5.2 分层原则
1. 业务模型层（Directus 核心）
   - 仅保留 Collection/Field/Relation 的业务语义定义。
   - 聚焦主键、约束、索引、引用关系、权限策略。
2. UI 模型层（外置）
   - 页面布局、分组、组件、交互规则放在独立 UI 元数据中。
   - Directus Studio 配置仅作为后台运营辅助，不作为主应用唯一 UI 来源。

### 5.3 落地规则（建议）
1. 核心业务集合禁止新增仅用于展示的 `Presentation/Groups` 字段。
2. `interface/display/options` 字段变更单独提 PR，与 schema 变更分开评审。
3. 关系与约束（`relations`、非空、唯一、索引）优先在业务模型层定义，不放在 UI 层兜底。
4. 发布前执行“模型差异检查”：区分结构变更（DDL 影响）和 UI 变更（仅 Studio 影响）。
5. 对外部应用使用独立页面元数据，避免把 Directus Studio 配置直接暴露为前台契约。

## 6. 示例（概念化片段）
```json
{
  "collection": "products",
  "fields": [
    { "field": "id", "type": "uuid", "required": true },
    { "field": "name", "type": "string", "required": true, "is_unique": false },
    { "field": "price", "type": "decimal", "required": false },
    { "field": "brand_id", "type": "uuid", "required": false }
  ],
  "relations": [
    {
      "many_collection": "products",
      "many_field": "brand_id",
      "one_collection": "brands"
    }
  ]
}
```

## 变更记录
- 2026-03-11：新增 Directus 业务元数据模型文档
- 2026-03-11：补充关系定义逻辑（M2O/O2M/M2M/M2A）
- 2026-03-11：补充业务模型与 UI 模型分层策略
- 2026-03-11：补充相关表结构说明
