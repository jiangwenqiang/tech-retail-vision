# AtroCore 业务元数据模型

## 目的
结合 AtroCore 的元数据机制，统一零售系统在“业务模型定义、字段约束、关系建模、数据库映射”上的表达方式，确保配置可维护、可演进、可追溯。

## AtroCore 元数据总览
AtroCore 使用 JSON 元数据驱动业务模型，核心文件位于模块的 `app/Resources/metadata/` 目录，常见分层如下：

1. `scopes/{Entity}.json`：实体级行为与能力（如类型、是否可导入、是否启用 ACL）
2. `entityDefs/{Entity}.json`：实体结构定义（字段、关系、索引、集合行为）
3. `clientDefs/{Entity}.json`：前端视图与交互配置
4. `fields/*.json`：字段类型定义与通用行为
5. `app/*.json`：应用级配置

## 1. 业务模型与属性管理

### 1.1 业务模型（Entity）管理
AtroCore 中业务模型以 Entity 形式存在，可通过两种方式管理：

- 管理后台 `Administration > Entities`（可视化创建/修改）
- 元数据文件（模块化、可版本管理）

实体支持的核心类型：

- `Base`：单表存储的标准业务实体（最常用）
- `Hierarchy`：支持父子层级继承
- `Relation`：多对多关系中间实体（自动创建或扩展）
- `Reference`：参考数据实体（文件化数据）

### 1.2 实体（Entity）定义说明
实体定义建议按“标识、能力、结构、展示”四层管理：

| 定义层 | 主要配置位置 | 关键定义项 | 说明 |
| --- | --- | --- | --- |
| 标识定义 | `scopes/{Entity}.json` | `entity code`、`name`、`type` | 定义实体唯一身份与实体类型（Base/Hierarchy/Relation/Reference） |
| 能力定义 | `scopes/{Entity}.json` | 导入导出、审计、ACL、搜索行为 | 定义实体是否可导入、是否启用权限和活动流等平台能力 |
| 结构定义 | `entityDefs/{Entity}.json` | `fields`、`relations`、`indexes` | 定义字段、关系、索引与约束，是实体物理映射的核心来源 |
| 展示定义 | `clientDefs/{Entity}.json` | 列表字段、表单布局、交互规则 | 定义前端展示形态，不改变领域语义 |

实体定义的最小建议集合：

1. 实体编码与名称（稳定、不可复用）
2. 实体类型（Base/Hierarchy/Relation/Reference）
3. 字段集合（至少包含主业务识别字段）
4. 关系集合（外部引用、反向引用）
5. 索引定义（高频查询字段）

### 1.3 属性（Field）管理
属性以字段形式定义在 `entityDefs/{Entity}.json` 的 `fields` 节点中。字段由以下关键维度组成：

- 字段标识：`code`（唯一编码，创建后不可变）
- 字段类型：`type`（如 string/int/float/date/link/linkMultiple 等）
- UI 文案：`name`、`tooltip`、多语言标签
- 行为控制：可编辑性、可比较性、继承行为、变更记录策略
- 关系配置：关联实体、反向字段、关系实体编码

## 2. 业务模型属性的管理范围

以下为 AtroCore 中字段管理的主要范围（覆盖必填、选填、数据类型、校验与引用关系）：

| 管理维度 | 典型配置项 | 说明 |
| --- | --- | --- |
| 必填/选填 | `required` | 控制是否必填；`linkMultiple` 不支持设为必填 |
| 数据类型 | `type` | 决定存储结构、UI 控件、查询行为、关系行为 |
| 默认值 | `default`/`defaultFrom`/`defaultTo` | 新建记录或历史数据补齐的默认策略 |
| 唯一性 | `unique` | 字段值唯一约束 |
| 空值约束 | `disableNullValue` | 禁止空值（按类型支持） |
| 长度与精度 | `maxLength`、`amount of digits after comma` | 字符串长度、数值显示精度 |
| 数值边界 | `min`、`max` | 数值合法区间 |
| 正则校验 | `regex`（字符串类型场景） | 按模式校验格式（编码、特殊值等） |
| 索引 | `databaseIndex` + `indexes` | 字段级或实体级索引能力 |
| 只读/保护 | `readOnly`、`protected` | 控制 UI/API 可写性 |
| 继承控制 | `uninherited` | 层级实体中是否参与父子继承 |
| 变更追踪 | `createNoRecordActivity`、`no recording as modification` | 控制活动流与修改时间更新 |
| 引用关系 | `link`、`linkMultiple` + 关系配置 | 声明外键关系与双向导航 |

### 2.1 引用关系管理细化
AtroCore 关系建模覆盖三类：

- `Many-to-One`：当前实体通过 `link` 引用外部实体；反向自动生成 `linkMultiple`
- `One-to-Many`：当前实体通过 `linkMultiple` 关联多个目标；反向自动生成 `link`
- `Many-to-Many`：通过 `linkMultiple` + 关系类型创建；系统自动生成 `Relation` 实体管理中间关系

关系配置关注项：

- `Foreign Entity`：目标实体
- `Foreign Code`：目标实体反向字段编码
- `Relation Entity Code`：多对多时中间关系实体编码

### 2.2 数据类型说明
下表给出 AtroCore 常见字段类型及管理重点，作为业务建模时的标准参考（不同版本可扩展）：

| 类型分类 | 典型类型 | 常见业务字段示例 | 常见约束/配置项 | 物理落库方式 |
| --- | --- | --- | --- | --- |
| 字符串 | `varchar`、`text` | 商品名称、备注、编码 | `required`、`maxLength`、`regex`、`unique` | 主表字符列 |
| 数值 | `int`、`float` | 数量、价格、重量 | `min`、`max`、小数位精度、`default` | 主表数值列 |
| 布尔 | `bool` | 是否启用、是否默认 | `default`、`readOnly` | 主表布尔列 |
| 日期时间 | `date`、`datetime` | 生效日期、创建时间 | `required`、区间校验 | 主表日期/时间列 |
| 枚举 | `enum`、`multiEnum` | 商品状态、标签集合 | 候选值集合、默认值、是否多选 | 枚举列或关联存储（视实现） |
| 结构化 | `array`、`json`（若版本支持） | 扩展属性、动态配置 | 长度限制、结构校验 | JSON/文本列 |
| 单引用 | `link` | 品牌、供应商、组织 | `required`、引用目标、反向字段 | 主表引用列（外键语义） |
| 多引用 | `linkMultiple` | 商品-分类、商品-渠道 | 关系类型、关系实体编码 | 关系表/中间实体 |

补充说明：

1. 类型决定 UI 控件、查询能力与校验策略，不只是数据库列类型。
2. `link` 与 `linkMultiple` 属于关系类型，重点在关联管理而非单列数据存储。
3. 建议先确定业务语义（金额、状态、引用、多值）再选类型，避免后期迁移成本。

## 3. 业务模型到数据表/列的管理方式

### 3.1 实体到表的映射

- `Base` 实体：通常映射为 1 张主表
- `Hierarchy` 实体：主表 + 自动生成的 `{Entity}Hierarchy` 关系实体
- `Many-to-Many`：自动生成 `Relation` 实体作为中间关系表
- `Reference` 实体：数据存放于参考数据文件（非主业务库表）

### 3.2 字段到列的映射

- 标量字段（string/int/float/date/bool 等）映射为表列
- `link` 字段映射为引用列（外键语义，具体列名按系统规则生成）
- `linkMultiple` 一般通过关系实体（中间表）保存关联，不直接在主表落单列
- 系统字段（如 `id`、`createdAt`、`modifiedAt`、`createdBy`、`modifiedBy`）由平台统一管理

### 3.3 索引与约束落库

- 字段级 `databaseIndex` 与实体级 `indexes` 用于生成数据库索引
- `unique`、非空、范围等约束通过字段配置驱动校验与数据库层约束协同
- 元数据在系统初始化阶段被加载与合并，驱动应用层渲染和数据库结构管理

## 4. 示例（Entity 元数据片段）
```json
{
  "fields": {
    "name": {
      "type": "varchar",
      "required": true,
      "maxLength": 255,
      "databaseIndex": true
    },
    "brand": {
      "type": "link",
      "required": false
    },
    "classifications": {
      "type": "linkMultiple"
    },
    "price": {
      "type": "float",
      "min": 0,
      "unique": false
    }
  },
  "indexes": {
    "idx_product_name": {
      "columns": ["name"]
    }
  }
}
```

## 5. 落地建议

1. 先在业务层确定实体边界与关系类型，再定义字段
2. 将“字段语义约束”放在元数据，不在前端重复硬编码
3. 对高频查询字段优先配置索引，减少后期迁移成本
4. 对`Hierarchy`与`Many-to-Many`关系，提前规划关系实体命名规范
5. 通过模块化元数据与 Git 版本管理，落实模型演进审计
