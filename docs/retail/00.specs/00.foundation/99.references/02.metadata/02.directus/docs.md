# Directus 元数据管理方案（源码级整理）

## 1. 研究范围

- 仓库：`projects/directus`
- 分支与提交：`main @ 3fbd4c3fd6`
- 版本：`directus/directus/package.json` -> `11.14.1`
- 关键源码目录：
  - `api/src/services/{collections,fields,relations,schema}.ts`
  - `api/src/controllers/schema.ts`
  - `api/src/utils/{get-snapshot,apply-diff,apply-snapshot,validate-snapshot,validate-diff}.ts`
  - `packages/system-data/src/**/*`

## 2. 方案总览

Directus 采用“**数据库结构 + 系统元数据表 + 代码内 system-data 基线 + snapshot/diff/apply**”方案：

1. 业务结构由数据库实际 schema 决定（table/column/foreign key）。
2. UI/管理元数据存于 `directus_collections / directus_fields / directus_relations` 等系统表。
3. 系统集合基线由 `@directus/system-data` 包（YAML）提供并在运行时注入。
4. 环境迁移通过 schema snapshot + diff + apply 完成，带版本/哈希校验。

## 3. 元数据域模型

### 3.1 核心对象

1. `Collection`：集合定义（物理表 + 元信息）。
2. `Field`：字段定义（列结构 + UI 元信息）。
3. `Relation`：关系定义（外键结构 + 关系元信息）。
4. `Snapshot`：可迁移的结构快照。

### 3.2 类型（源码定义）

在 `packages/types/src`：

1. `CollectionMeta/RawCollection`（`collection.ts`）
2. `FieldMeta/RawField`（`fields.ts`）
3. `RelationMeta/Relation`（`relations.ts`）
4. `Snapshot/SnapshotDiff/SnapshotDiffWithHash`（`snapshot.ts`）

`Snapshot` 包含：

1. `collections`
2. `fields`
3. `systemFields`
4. `relations`

## 4. system-data 基线机制

`packages/system-data` 是 Directus 对系统集合元数据的“内置标准库”。

### 4.1 数据来源

1. `collections/collections.yaml`：系统集合元信息。
2. `fields/*.yaml`：系统字段元信息与索引标记。
3. `relations/relations.yaml`：系统关系元信息。

### 4.2 运行时注入

1. `systemCollectionRows`：从 YAML 转为系统 collection 行。
2. `systemFieldRows`：按各 YAML 聚合系统字段行。
3. `systemRelationRows`：系统关系行。

服务层读取时会把 DB 中的用户定义元数据与这些系统行合并。

## 5. 服务层实现（元数据 CRUD）

### 5.1 CollectionsService

关键行为（`api/src/services/collections.ts`）：

1. 创建集合时校验命名，不允许 `directus_` 前缀。
2. 若未提供主键字段，会自动注入 `id` 自增主键。
3. 在事务中创建表结构并写 `directus_fields/directus_collections`。
4. 可选并发索引创建在事务外执行。

### 5.2 FieldsService

关键行为（`api/src/services/fields.ts`）：

1. `readAll()` 合并三类数据：DB column + directus_fields + systemFieldRows。
2. 支持 alias 字段（不一定有物理列）。
3. 创建/更新字段会同步处理 schema 与 meta。
4. 系统字段更新受严格限制（见校验章节）。

### 5.3 RelationsService

关键行为（`api/src/services/relations.ts`）：

1. 关系读取将 `directus_relations` 与数据库外键信息 stitch。
2. 创建关系时会同时处理 FK 约束和 meta 行。
3. 更新关系支持对约束进行 drop/recreate。

## 6. Schema Snapshot / Diff / Apply

这是 Directus 元数据治理的核心能力。

### 6.1 Snapshot 生成

`getSnapshot()`（`api/src/utils/get-snapshot.ts`）流程：

1. 调用 `CollectionsService/FieldsService/RelationsService` 获取当前全量结构。
2. 过滤系统项与不跟踪项。
3. 对输出做标准化排序与 sanitize。
4. 生成 `Snapshot{version,directus,vendor,...}`。

CLI 对应：`api/src/cli/commands/schema/snapshot.ts`。

### 6.2 Diff 计算

1. API：`POST /schema/diff`
2. CLI：`schema apply` 前先计算差异
3. 实现：`getSnapshotDiff()` + `deep-diff` 变更表达

### 6.3 Apply 执行

`applyDiff()`（`api/src/utils/apply-diff.ts`）按顺序处理：

1. `collections`（先建/删/改，含分组嵌套创建）
2. `fields`
3. `systemFields`
4. `relations`

并在最终统一 `flushCaches` 与事件派发。

### 6.4 并发与安全

`validateApplyDiff()` 会校验：

1. payload 结构完整性。
2. hash 是否匹配当前快照。
3. create/delete 操作是否与当前实际状态冲突。
4. `systemFields` 仅允许修改 `schema.is_indexed`。

### 6.5 版本与供应商校验

`validateSnapshot()` 会校验：

1. snapshot `version`（当前为 1）。
2. Directus 版本一致性（可 `force` 跳过）。
3. 数据库 vendor 一致性（可 `force` 跳过）。

## 7. 管控接口与入口

### 7.1 HTTP API

1. `/collections`
2. `/fields`
3. `/relations`
4. `/schema/snapshot`
5. `/schema/diff`
6. `/schema/apply`

### 7.2 CLI

1. `schema snapshot`
2. `schema apply`

CLI 支持 dry-run、交互确认、ignore rules 等能力。

## 8. 权限与约束

1. 结构级变更通常要求 admin（服务层显式校验）。
2. 字段/关系读取会叠加权限模型过滤可见性。
3. 对系统字段、系统集合有额外保护策略。

## 9. 对我们方案的可复用点

可直接借鉴：

1. Snapshot -> Diff -> Apply 的标准化迁移链路。
2. 哈希校验 + 变更前置验证（防并发漂移）。
3. 结构变更顺序编排（集合、字段、关系分阶段）。
4. 系统元数据基线包（类似 `system-data`）与业务扩展分离。

需要补强：

1. 租户级隔离（Directus 默认是项目级/实例级）。
2. 业务语义层（attribute/composite）抽象能力。
3. 平台基线与租户覆盖的显式双层模型。

## 10. 建议阅读顺序（源码）

1. `packages/system-data/src/{collections,fields,relations}`
2. `api/src/services/{collections,fields,relations}.ts`
3. `api/src/utils/get-snapshot.ts`
4. `api/src/utils/apply-diff.ts`
5. `api/src/utils/{validate-snapshot,validate-diff}.ts`
6. `api/src/controllers/schema.ts` + `api/src/cli/commands/schema/*`
