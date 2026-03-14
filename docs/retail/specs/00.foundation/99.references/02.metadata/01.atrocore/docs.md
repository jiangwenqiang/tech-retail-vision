# AtroCore 元数据模型细节（业务层规格）

## 1. 目标

本文聚焦 AtroCore 元数据模型本身，回答三个问题：

1. 元数据对象有哪些，分别管什么。
2. 每类对象的关键字段与约束是什么。
3. 多对象如何组合成一套可运行的业务模型。

## 2. 元数据对象总图

AtroCore 的业务元数据可抽象为 6 个核心对象：

1. `Scope`：实体级能力定义。
2. `Entity Definition`：实体结构定义。
3. `Field Type Definition`：字段类型契约。
4. `Attribute Definition`：属性扩展定义。
5. `Client Definition`：前端展示与交互定义。
6. `Layout`：布局与面板编排定义。

关系主线：

1. `Scope` 决定实体模板行为。
2. `Entity Definition.fields[*].type` 必须落在 `Field Type Definition`。
3. `Attribute` 通过属性体系挂载到实体。
4. `Client Definition/Layout` 引用结构层对象实现页面呈现。

## 3. Scope 模型（实体能力层）

### 3.1 作用

`Scope` 定义一个实体“具备哪些平台能力”，例如：

1. 是否显示在导航。
2. 是否支持 ACL。
3. 是否可导入导出。
4. 是否为层级实体。

### 3.2 完整字段（按 AtroCore 定义分组）

以下为 `scope` 中可出现的字段全集口径（包含模板默认字段、业务实体配置字段、以及运行时注入字段）。

#### A. 基础标识与存储可见性

1. `type`：实体类型（如 `Base/Hierarchy/Relation/ReferenceData/Archive`）。
2. `module`：所属模块。
3. `entity`：是否作为实体暴露。
4. `object`：是否纳入对象域能力。
5. `disabled`：是否禁用该实体。
6. `description`：实体描述信息（常用于管理端实体配置）。
7. `isCustom`：是否为衍生/自定义实体（运行时会注入）。
8. `primaryEntityId`：主实体标识（衍生实体场景）。
9. `attributeValueFor`：属性值承载实体对应的主实体（运行时注入）。
10. `notStorable`：是否为非持久化实体。
11. `emHidden`：是否在实体管理器中隐藏。
12. `openApiHidden`：是否从 OpenAPI 隐藏。
13. `mergeDisabled`：是否禁止 metadata merge 编辑。

#### B. 展示与导航控制

1. `tab`：是否显示在主导航。
2. `layouts`：是否启用布局管理。
3. `leftSidebarDisabled`：是否禁用左侧栏。
4. `showInAdminPanel`：是否显示在管理面板。
5. `quickCreateListDisabled`：是否禁用快速创建入口。
6. `overviewFilters`：概览筛选器配置。
7. `hideFieldTypeFilters`：是否隐藏字段类型筛选器。

#### C. ACL 与动作级权限

1. `acl`：是否启用 ACL。
2. `aclActionList`：动作清单（如 `create/read/edit/delete`）。
3. `aclLevelList`：可用权限级别清单。
4. `aclActionLevelListMap`：动作到权限级别映射。
5. `read/edit/delete/stream`：通常作为 `aclActionLevelListMap` 的动作键出现。

#### D. 操作能力开关

1. `customizable`：是否允许自定义结构与配置。
2. `importable`：是否支持导入。
3. `notifications`：是否启用通知能力。
4. `notificationDisabled`：是否禁用通知能力。
5. `stream`：是否启用动态流。
6. `streamDisabled`：是否禁用动态流。
7. `bookmarkDisabled`：是否禁用收藏。
8. `selectionDisabled`：是否禁用选择集能力。
9. `actionDisabled`：是否禁用动作能力。
10. `matchingDisabled`：是否禁用匹配能力。
11. `disableActionHistory`：是否禁用动作历史。

#### E. 协作与主数据基础能力

1. `hasOwner`：是否启用 owner 机制。
2. `hasAssignedUser`：是否启用 assigned user。
3. `hasTeam`：是否启用 team 机制。
4. `hasPersonalData`：是否声明含个人数据。
5. `hasActive`：是否启用 `isActive` 能力。
6. `isActiveUnavailable`：是否关闭 active 状态切换。
7. `nameField`：名称字段定义。

#### F. 关系与继承能力

1. `multiParents`：层级是否允许多父节点。
2. `multiParentsDisabled`：是否禁用多父能力配置。
3. `dragAndDrop`：是否启用树拖拽。
4. `fieldValueInheritance`：是否启用字段值继承。
5. `relationInheritance`：是否启用关系继承。
6. `mandatoryUnInheritedFields`：强制不继承字段集合（运行时可注入）。
7. `inheritedRelations`：允许继承的关系集合。
8. `duplicatableRelations`：允许复制的关系集合。
9. `defaultRelationAudited`：关系审计默认策略。
10. `modifiedExtendedRelations`：扩展关系变更联动配置。
11. `isHierarchyEntity`：标记为层级中间关系实体（运行时注入）。

#### G. 生命周期与清理策略

1. `clearDeletedAfterDays`：软删记录清理周期。
2. `autoDeleteAfterDays`：自动删除周期。
3. `hideLastViewed`：是否隐藏最近查看能力。

#### H. 实体管理器（Entity）扩展字段

1. `hasAttribute`：是否启用属性体系。
2. `hasAssociate`：是否启用关联实体（associate）能力。
3. `sortBy`：默认排序字段。
4. `sortDirection`：默认排序方向。
5. `role`：实体角色标签。
6. `matchDuplicates`：是否启用重复匹配。
7. `matchMasterRecords`：是否启用主记录匹配。
8. `enableVersioning`：是否启用版本管理。
9. `defaultVersionName`：默认版本名。
10. `enableFieldValueLock`：是否启用字段值锁定。
11. `createdAt/modifiedAt/createdById/modifiedById`：实体定义元信息时间与用户字段（管理端实体层属性）。

#### I. 运行时推导字段

1. `attributesDisabled`：非 `Base/Hierarchy` 或隐藏实体时，运行时可自动置为 `true`。

说明：

1. 并非每个实体都会配置全部字段；字段是否生效取决于 `type`、模板默认值与监听器运行时注入。
2. 同名字段可能在“静态 metadata”与“运行时 metadata”中都出现，最终以合并结果为准。

### 3.3 `type` 的业务含义

#### `Base`

定义：标准业务实体模板，适用于“一个业务对象对应一套稳定主结构”的场景。  
结构特点：
1. 以主表字段为核心，字段语义清晰。
2. 可配常规关系（`belongsTo/hasMany`）与索引。
3. 最适合承载核心主数据对象。
典型场景：
1. 商品主档（Product）。
2. 供应商（Supplier/Account）。
3. 品牌、组织、门店等稳定对象。
使用边界：
1. 当对象需要强树结构继承时，不建议继续用 `Base`，应升级为 `Hierarchy`。
2. 当对象主要用于承载“关系本身属性”时，优先考虑 `Relation`。

#### `Hierarchy`

定义：层级实体模板，支持父子节点组织与继承能力。  
结构特点：
1. 支持节点间父子关系（树形/多层级）。
2. 可启用字段值继承、关系继承。
3. 可按字段配置继承豁免（如 `inheritanceDisabled`）。
4. 同一关系通常会以双向视图声明（如 `children/parents`），两者通过 `foreign` 互为反向定义。
5. 多对多/中间关系的方向由 `midKeys` 顺序决定：
- 第一个键为当前侧（near key），第二个键为对端（distant key）。
- 运行时按“当前记录 ID 匹配 near key，再通过 distant key 取结果集合”执行。
典型场景：
1. 商品父子款（SPU/SKU 或主款/变体）。
2. 分类树（Category）。
3. 组织树、区域树、目录树。
4. `ProductHierarchy` 场景中：
- 查询 `children`：当前 `Product.id` 作为 `parent_id` 匹配，返回 `entity_id`。
- 查询 `parents`：当前 `Product.id` 作为 `entity_id` 匹配，返回 `parent_id`。
使用边界：
1. 层级越深，查询与维护复杂度越高，需要提前规划索引与加载策略。
2. 不应把非层级业务对象“硬建成树”，否则会引入不必要的继承规则。
3. 需明确中间表结构口径（以 `product_hierarchy` 为例）：
- 核心字段：`id, entity_id, parent_id, hierarchy_sort_order, deleted, created_at, modified_at, created_by_id, modified_by_id`。
- 核心唯一约束：`deleted + entity_id + parent_id`（防止重复关系行）。

#### `Relation`

定义：关系实体模板，用于承载对象与对象之间的连接关系，尤其是多对多关系。  
结构特点：
1. 关系记录本身是实体，可附加业务字段。
2. 通常作为中间实体承载双向关联键。
3. 适合需要“关系附加属性”的场景。
4. 关系建模建议同时声明双向 link，并通过 `foreign` 显式绑定反向关系，避免把同一关系拆成两套无关定义。
5. `relationName` 决定中间关系实体；`midKeys` 决定中间表两侧键与执行方向：
- 第一个键为当前侧（near key），第二个键为对端（distant key）。
- 运行时按“当前记录 ID 匹配 near key，再通过 distant key 关联结果”执行。
6. 关系实体通常包含统一约束口径：`deleted + left_key + right_key` 唯一约束，防止重复关系行。
典型场景：
1. 商品与渠道关系，并记录上架状态、优先级。
2. 商品与分类关系，并记录排序权重。
3. 客户与标签关系，并记录生效时间。
4. 同实体自关联关系（如 `ProductHierarchy`、`FolderHierarchy`）：
- 通常以 `children/parents` 两个 `hasMany` 暴露双向集合视图。
- `foreign` 用于声明两者互为反向关系。
使用边界：
1. 如果关系仅是简单引用、无附加属性，优先普通 `link/linkMultiple`。
2. 关系实体过多会增加治理成本，需统一命名与生命周期策略。
3. 若关系方向、唯一约束和生命周期未定义清楚，不应直接落地，否则后续容易出现重复关系、方向混乱和清理困难。

#### `Reference`（代码类型：`ReferenceData`）

定义：参考数据模板，适用于低频变更、标准枚举化、字典化的数据对象。文档中的 `Reference` 对应代码里的 `ReferenceData`。  
结构特点：
1. 数据语义以“被引用”而非“独立业务流程” 为主。
2. 通常变化频率低、稳定性高。
3. 更强调标准化、可复用、跨模块一致。
4. 结构生成上不走常规 DB schema 自动建表，默认由 `data/reference-data/<Entity>.json` 承载。
5. 系统启动时会把该目录内容装配到配置上下文（`referenceData`）供运行时消费。
典型场景：
1. 国家/地区代码、币种、计量单位。
2. 行业标准字典、分类标准码表。
3. 业务公共枚举主数据。
使用边界：
1. 若对象已进入高频运营流程（审批、复杂权限、高并发更新），不建议继续作为 `Reference`。
2. 参考数据应建立统一主数据口径，避免多处复制导致编码漂移。
3. 修改策略建议：
- 优先通过系统接口/后台修改（复用校验与钩子）。
- 运维场景可直接改 `data/reference-data/*.json`。
- 直接改文件后建议 `php console.php clear cache` 以避免旧缓存。

#### `Archive`

定义：归档/历史记录模板，用于审计留痕与历史追溯对象，不用于主档运营。  
结构特点：
1. 语义上偏“日志与历史”，通常读多写少。
2. 存储仍走数据库实体路径（非文件存储）。
3. 平台落地时通常会在具体 scope 上进一步收敛能力（如只读 ACL、关闭通知/书签/动作等）。
典型场景：
1. 操作历史记录（如 `ActionHistoryRecord`）。
2. 执行日志（如 `ActionExecutionLog`）。
3. 认证日志（如 `AuthLogRecord`）。
使用边界：
1. 若对象是持续运营主数据（需要完整协作、审批、频繁编辑），应使用 `Base/Hierarchy`。
2. `Archive` 与 `ReferenceData` 不同：前者是 DB 实体，后者是文件字典数据。

## 4. Entity Definition 模型（结构层）

### 4.1 作用

定义一个实体的“数据结构契约”。

### 4.2 结构块

1. `fields`：字段定义集合。
2. `links`：关系定义集合。
3. `indexes/uniqueIndexes`：索引与唯一约束。
4. `collection`：集合行为（排序等）。

### 4.3 `fields` 子模型（字段实例）

#### 4.3.1 字段参数总表（按工程统计）

统计口径：
1. 扫描路径：`app/Atro/Resources/metadata/fields/*.json`。
2. 统计对象：各 type 的 `params[].name`。
3. 关系标注：
`common` 表示该属性属于公共参数（在 `fields/base.json` 定义），否则列出实际关联的 field type。

| 属性 | 关联 field type | 用途 |
|---|---|---|
| `after` | date, datetime, datetimeOptional | 日期/时间快捷过滤上界（如未来 N 单位）。 |
| `allowedOptions` | extensibleEnum, extensibleMultiEnum | 可选项白名单（限制可选枚举值）。 |
| `amountOfDigitsAfterComma` | float, rangeFloat | 小数位精度控制。 |
| `before` | date, datetime, datetimeOptional | 日期/时间快捷过滤下界（如过去 N 单位）。 |
| `countBytesInsteadOfCharacters` | email, markdown, text, url, varchar, wysiwyg | 长度校验按字节而非字符计数。 |
| `currentUserAsDefault` | link | 默认值使用当前登录用户。 |
| `default` | bool, color, colorpicker, datetimeOptional, duration, email, enum, enumFloat, enumInt, extensibleEnum, extensibleMultiEnum, file, float, int, link, linkMultiple, markdown, measure, rangeFloat, rangeInt, text, url, varchar, wysiwyg | 字段默认值（新建记录时生效）。 |
| `defaultDate` | date, datetime | 日期类默认值基准（如 today/now）。 |
| `defaultFrom` | rangeFloat, rangeInt | 区间字段默认下界。 |
| `defaultTo` | rangeFloat, rangeInt | 区间字段默认上界。 |
| `defaultUnit` | float, int, rangeFloat, rangeInt, varchar | 度量单位默认值。 |
| `defaultValueType` | markdown, text, varchar, wysiwyg | 默认值解释方式（固定值/系统值/表达式等）。 |
| `disableFormatting` | int | 关闭数值格式化，按原始值显示/编辑。 |
| `dropdown` | extensibleEnum, extensibleMultiEnum, link, linkMultiple, measure | 在 UI 中使用下拉样式选择器。 |
| `duplicateIgnore` | common | 去重时忽略该字段。 |
| `entityList` | linkParent | `linkParent` 可关联的实体范围。 |
| `extensibleEnum` | extensibleEnum, extensibleMultiEnum, link, linkMultiple | 绑定的可扩展枚举定义。 |
| `extensibleEnumOptions` | extensibleEnum, extensibleMultiEnum | 可扩展枚举的候选/预置选项数据。 |
| `field` | foreign | 外键/派生字段映射到的源字段名。 |
| `fileType` | file | 单文件字段允许的文件类型配置。 |
| `fileTypes` | linkMultiple | 多文件/多链接字段允许的文件类型集合。 |
| `foreignName` | link, linkMultiple | 关联记录显示名称所用的目标字段。 |
| `height` | map, wysiwyg | 输入组件高度。 |
| `htmlSanitizer` | wysiwyg | WYSIWYG HTML 清洗器配置。 |
| `index` | color, date, datetime, email, float, int, rangeFloat, rangeInt, url, varchar | 创建数据库索引以提升检索/排序性能。 |
| `inheritanceDisabled` | common | 在层级/派生场景下禁用值继承。 |
| `isMultilang` | array, bool, markdown, script, text, url, varchar, wysiwyg | 按多语言存储字段值。 |
| `isSorted` | enum, language, multiEnum, multiLanguage | 多值选项是否保持排序。 |
| `lengthOfCut` | markdown, text, wysiwyg | 内容截断长度（配合 see more）。 |
| `link` | foreign | 外键/派生字段依赖的关联关系名。 |
| `max` | float, int | 数值最大值校验。 |
| `maxFrom` | rangeFloat, rangeInt | 区间下界允许的最大值。 |
| `maxHeight` | markdown | 编辑器最大高度。 |
| `maxLength` | email, text, url, varchar, wysiwyg | 文本最大长度。 |
| `maxTo` | rangeFloat, rangeInt | 区间上界允许的最大值。 |
| `measure` | float, int, measure, rangeFloat, rangeInt, varchar | 绑定度量体系（Measure）。 |
| `min` | float, int | 数值最小值校验。 |
| `minFrom` | rangeFloat, rangeInt | 区间下界允许的最小值。 |
| `minHeight` | markdown, wysiwyg | 编辑器最小高度。 |
| `minTo` | rangeFloat, rangeInt | 区间上界允许的最小值。 |
| `noEmptyString` | array, arrayInt | 数组类字段不允许空字符串元素。 |
| `notNull` | bool, float, int, markdown, text, url, varchar, wysiwyg | 持久化层不允许 `NULL`。 |
| `options` | arrayInt, duration, enum, enumFloat, enumInt, multiEnum | 静态选项列表（枚举/多选等）。 |
| `outputType` | script | 脚本字段输出类型声明。 |
| `pattern` | email, varchar | 正则校验规则。 |
| `preview` | script | 预览能力开关/配置。 |
| `previewSize` | file | 文件/图片预览尺寸。 |
| `protected` | array, arrayInt, bool, color, colorpicker, date, datetime, email, enum, extensibleEnum, extensibleMultiEnum, file, float, int, language, link, linkMultiple, markdown, measure, multiEnum, multiLanguage, rangeFloat, rangeInt, text, url, varchar, wysiwyg | 用户不可指定该字段值（前端与 API 均不可直接写入）。 |
| `provider` | map | 地图字段使用的 provider。 |
| `readOnly` | array, arrayInt, bool, color, colorpicker, date, datetime, datetimeOptional, email, enum, enumFloat, enumInt, extensibleEnum, extensibleMultiEnum, file, float, int, language, link, linkMultiple, linkParent, markdown, measure, multiEnum, multiLanguage, rangeFloat, rangeInt, text, url, varchar, wysiwyg | 用户在前端不可指定该字段值，但仍可通过 API 修改。 |
| `recordRelatedChangesInStream` | linkMultiple | 关系变更写入 Stream/活动日志。 |
| `required` | common | 必填校验。 |
| `rowsMax` | text | 文本框最大行数。 |
| `rowsMin` | text | 文本框最小行数。 |
| `script` | script | 脚本字段表达式/脚本体。 |
| `seeMoreDisabled` | markdown, text, wysiwyg | 禁用“查看更多”折叠行为。 |
| `showUser` | datetime | 日期时间处理是否带用户上下文（时区等）。 |
| `sortable` | linkMultiple | 允许按该关系字段排序。 |
| `strip` | url | URL 值保存前去除协议/格式部分。 |
| `translation` | array, arrayInt, enum, multiEnum | 选项文案翻译键/翻译路径。 |
| `trim` | email, varchar | 保存前去除首尾空白。 |
| `unique` | color, date, datetime, email, float, int, url, varchar | 创建唯一约束/唯一索引。 |
| `urlLabel` | url | URL 显示标签。 |
| `useDisabledTextareaInViewMode` | text | 详情态使用禁用 textarea 展示。 |
| `useIframe` | wysiwyg | 以 iframe 方式渲染内容。 |
| `useNumericFormat` | date, datetime, datetimeOptional | 日期/时间按数字格式展示。 |

### 4.4 `links` 子模型（关系定义）

#### 4.4.1 作用

`links` 是实体关系契约层，定义“当前实体如何引用或被其他实体引用”。  
它决定以下行为：

1. 关系查询与加载方式（ORM 映射）。
2. 关联面板与关系操作入口（前端关系面板）。
3. 关系表结构与中间键约定（尤其层级/多对多）。
4. 删除级联与连接策略（如 `cascadeDelete`、`noJoin`）。

#### 4.4.2 AtroCore 工程中的关系类型（实测）

按 `app/Atro/Resources/metadata/entityDefs/*.json` 统计，当前 links `type` 只有三类：

1. `belongsTo`（194）：标准单向外键关系。
2. `hasMany`（67）：一对多或经关系实体的多对多入口。
3. `belongsToParent`（3）：多态父对象关系（典型 `parentId + parentType`）。

#### 4.4.3 `links` 属性模型（业务语义）

| 属性 | 适用 type | 业务用途 |
|---|---|---|
| `type` | 全部 | 关系类型标识，决定 ORM 与 API 行为。 |
| `entity` | `belongsTo`, `hasMany` | 目标实体类型。 |
| `foreign` | 全部（按场景） | 反向关系名；`belongsToParent` 下常用于父对象反向集合名。 |
| `relationName` | `hasMany` | 关系实体/中间关系名（如 `ProductHierarchy`、`EntityTeam`）。 |
| `midKeys` | `hasMany` | 中间关系键顺序定义，控制当前端与对端的连接键映射。 |
| `foreignName` | `belongsTo` | 指定关联对象显示名字段（非默认 `name` 时使用）。 |
| `cascadeDelete` | `belongsTo` | 开启外键级联删除策略（Schema 层生成约束时使用）。 |
| `disableMassRelation` | `hasMany` | 禁用批量关联/解绑操作，避免高风险批处理。 |
| `layoutRelationshipsDisabled` | `hasMany` | 隐藏/禁用该关系在标准 Relationships 布局中的入口。 |
| `noJoin` | `belongsTo` | 查询层不走常规 JOIN，降低复杂连接开销。 |
| `skipOrmDefs` | `belongsTo` | 跳过 ORM 关系定义生成，通常用于技术字段或特殊存储。 |

#### 4.4.4 典型业务建模模式

1. 标准引用关系（`belongsTo`）  
如 `Product -> productGroup/countryOfOrigin/defaultSupplier`，用于主数据归属、责任人、创建人等稳定引用。

2. 层级关系（`hasMany + relationName + midKeys`）  
如 `Product.children/parents`，通过同一 `relationName` 与不同 `midKeys` 方向表达父子路径。

3. 多态父对象关系（`belongsToParent`）  
如 `Note.parent`、`Notification.related`，用于“挂载到任意业务对象”的通用事件/消息模型。

4. 受控关系入口  
通过 `layoutRelationshipsDisabled`、`disableMassRelation` 控制关系是否暴露在通用关系面板、是否允许批量操作。

#### 4.4.5 运行时关系实体生成（关键差异）

AtroCore 在 metadata listener 中会基于 links 进一步生成关系实体与反向关系补丁（不仅仅读静态 JSON）：

1. `prepareRelationEntities` 会扫描 links 并转换关系定义。
2. 对 `manyMany` 关系按 `relationName/midKeys` 生成或补齐关系实体字段与 links。
3. 当存在附加关系字段时，会为主实体注入到关系实体的 `linkMultiple` 入口。

这意味着业务上“写 links”不仅定义关系，还会触发运行时元数据扩展链路。

#### 4.4.6 业务治理边界

1. `fields` 决定值结构，`links` 决定关系结构，二者不要混用职责。
2. `relationName` 与 `midKeys` 必须成对治理，否则会导致查询、继承、关系同步行为不一致。
3. 对高频大数据关系优先评估 `noJoin`、`disableMassRelation`，避免关系查询和批量操作放大成本。

### 4.5 `indexes/uniqueIndexes` 子模型（索引约束层）

#### 4.5.1 作用

用于定义数据库查询性能与唯一性约束，是结构层落库能力的一部分。

#### 4.5.2 `indexes` 模型

`indexes` 是命名索引集合，工程中单个索引对象主要包含：

1. `columns`：索引字段列表（最常见）。
2. `type`：索引类型（可选，常见值如 `index`）。

样例（工程）：
1. `name -> columns: [name, deleted]`（分类等实体）。
2. `user -> columns: [userId, createdAt]`（通知类实体）。

业务意义：
1. 列表筛选、排序、高频查询字段应建索引。
2. `deleted` 常与业务字段组成复合索引，适配软删除数据模型。

#### 4.5.3 `uniqueIndexes` 模型

`uniqueIndexes` 是命名唯一约束集合，工程里主要采用：

1. `unique_name: [col1, col2, ...]` 的数组写法。

样例（工程）：
1. `unique_classification: [deleted, release, code]`。
2. 其他常见命名：`unique_code`、`unique_relationship`、`unique_notification_rules`。

业务意义：
1. 保证业务主键（如 `code`）在目标维度内唯一。
2. 常将 `deleted` 纳入唯一键，允许软删除后重建同编码记录。

#### 4.5.4 建模建议

1. 先按查询路径设计 `indexes`，再按业务键设计 `uniqueIndexes`。
2. 复合索引字段顺序应与高频过滤条件顺序一致。
3. 唯一约束需与导入、同步、合并策略协同评估，避免批量写入冲突。

### 4.6 `collection` 子模型（集合行为层）

#### 4.6.1 作用

`collection` 定义实体默认列表行为，不改变数据结构本身。

#### 4.6.2 字段模型（工程实测）

按 `entityDefs/*.json` 统计，AtroCore 当前主要字段为：

1. `sortBy`：默认排序字段。
2. `asc`：默认升降序（`true` 升序，`false` 降序）。
3. `textFilterFields`：全文本检索/快速搜索字段列表。

样例（工程）：
1. `sortBy: createdAt, asc: false`（常见审计型列表）。
2. `textFilterFields: [name, code]`（主数据对象）。

#### 4.6.3 业务边界

1. `collection` 仅定义“默认集合行为”，不承担字段合法性校验。
2. 若字段不可排序或不适合文本检索，应在 `fields` 能力层做约束。
3. 大表场景下，`sortBy` 必须与索引策略（4.5）联动设计。

## 5. Field Type Definition

### 5.1 作用

Field type 是字段模型的“类型契约层”，用于统一以下内容：

1. 参数白名单（哪些参数可配置）。
2. 默认行为（默认 `fieldDefs`、派生字段等）。
3. 查询能力（`filter/textFilter/qbFilterType`）。
4. 治理能力（`auditable/personalData/notSortable/notMergeable`）。

统计口径：`Espo Core(application/Espo/Resources/metadata/fields/*.json) + Atro(app/Atro/Resources/metadata/fields/*.json)` 合并（Atro 同名覆盖 Core），当前 54 种。

### 5.2 Field Type 一级属性全集


| 顶层键 | field type | 使用场景 |
|---|---|---|
| `actualFields` | `address`, `attachmentMultiple`, `currency`, `datetimeOptional`, `email`, `file`, `image`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `personName`, `phone`, `rangeCurrency`, `rangeFloat`, `rangeInt` | 复合字段声明“真实落库列”，如 `range*` 的 from/to、`personName` 的 `first/last`、`link` 的 `id`。 |
| `attributeExtractorClassName` | `address`, `currency`, `date`, `datetime`, `datetimeOptional`, `email`, `link`, `linkMultiple`, `linkParent`, `phone` | 绑定字段值对象的属性提取器（`Espo\\Core\\Field\\*AttributeExtractor`），用于字段值与属性映射。 |
| `converterClassName` | `attachmentMultiple`, `currency`, `decimal`, `email`, `file`, `image`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `personName`, `phone` | 指定 ORM 层字段转换器（`FieldConverters\\*`），处理 DB 值与领域值转换。 |
| `default` | `array`, `autoincrement`, `barcode`, `bool`, `checklist`, `date`, `datetime`, `datetimeOptional`, `email`, `multiEnum`, `number`, `phone`, `text`, `url`, `urlMultiple`, `varchar`, `wysiwyg` | 定义字段默认初始值（如 `[]`、`null`、`false`），用于新建记录初始化。 |
| `duplicatorClassName` | `attachmentMultiple`, `file`, `image`, `linkMultiple`, `wysiwyg` | 记录复制时使用专用复制器（`FieldDuplicators\\*`），保证附件/关系/富文本复制策略正确。 |
| `dynamicLogicOptions` | `array`, `checklist`, `enum`, `multiEnum`, `varchar` | 开启该类型在动态逻辑中的可用性（实值均为 `true`）。 |
| `fieldDefs` | `array`, `arrayInt`, `autoincrement`, `barcode`, `base`, `bool`, `checklist`, `colorpicker`, `date`, `datetime`, `datetimeOptional`, `duration`, `email`, `enum`, `enumFloat`, `enumInt`, `float`, `foreign`, `map`, `multiEnum`, `number`, `phone`, `url`, `urlMultiple`, `wysiwyg` | 定义底层字段实现（`type/len/autoincrement/storeArrayValues` 等），是类型到存储实现的核心映射。 |
| `fieldTypeList` | `foreign` | `foreign` 类型声明允许映射的目标字段类型集合。 |
| `fieldTypeViewMap` | `foreign` | `foreign` 类型为不同目标类型指定前端视图（如 `foreign-varchar/foreign-int`）。 |
| `fields` | `address`, `currency`, `datetimeOptional`, `email`, `personName`, `phone`, `rangeCurrency`, `rangeFloat`, `rangeInt` | 复合类型的派生子字段定义（如地址组件、姓名组件、区间 from/to）。 |
| `filter` | `address`, `array`, `arrayInt`, `attachmentMultiple`, `autoincrement`, `barcode`, `base`, `bool`, `checklist`, `colorpicker`, `currency`, `currencyConverted`, `date`, `datetime`, `datetimeOptional`, `decimal`, `email`, `enum`, `enumFloat`, `enumInt`, `file`, `float`, `foreign`, `image`, `int`, `jsonArray`, `jsonObject`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `map`, `multiEnum`, `number`, `password`, `personName`, `phone`, `rangeCurrency`, `rangeFloat`, `rangeInt`, `text`, `url`, `urlMultiple`, `varchar`, `wysiwyg` | 控制字段是否出现在标准过滤能力中（实值 `true/false`）。 |
| `fullTextSearch` | `personName`, `text`, `varchar`, `wysiwyg` | 声明字段参与全文检索。 |
| `fullTextSearchColumnList` | `personName` | 为复合全文字段指定具体索引列（`personName` 为 `first/last`）。 |
| `hookClassName` | `autoincrement`, `number` | Field Manager 建字段时挂接类型钩子（`Hooks\\AutoincrementType/NumberType`）。 |
| `linkDefs` | `attachmentMultiple`, `file`, `image` | 定义附件关系元数据（如 `hasChildren/belongsTo`、`entity=Attachment`、`foreign=parent`）。 |
| `mandatoryValidationList` | `array`, `arrayInt`, `attachmentMultiple`, `barcode`, `checklist`, `currency`, `date`, `datetime`, `datetimeOptional`, `decimal`, `email`, `enum`, `file`, `float`, `image`, `int`, `jsonArray`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `multiEnum`, `password`, `phone`, `url`, `urlMultiple`, `varchar` | 声明必执行校验链（如 `required/maxLength/pattern`），不随场景可选。 |
| `massUpdateActionList` | `array`, `attachmentMultiple`, `linkMultiple`, `multiEnum`, `urlMultiple` | 限定批量更新动作集合（如 `update/add/remove`）。 |
| `naming` | `personName`, `rangeCurrency`, `rangeFloat`, `rangeInt` | 约束派生子字段命名策略（当前实值为 `prefix`）。 |
| `notActualFields` | `attachmentMultiple`, `email`, `file`, `image`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `personName`, `phone` | 标记非落库辅助字段（如展示名 `name/names/types`）。 |
| `notCreatable` | `address`, `array`, `arrayInt`, `autoincrement`, `base`, `checklist`, `colorpicker`, `currencyConverted`, `datetimeOptional`, `duration`, `email`, `enumFloat`, `enumInt`, `foreign`, `jsonArray`, `jsonObject`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `map`, `multiEnum`, `password`, `personName`, `phone`, `rangeCurrency`, `rangeFloat`, `rangeInt`, `urlMultiple` | 控制类型是否可在 Field Manager 直接创建（技术型字段常为 `true`）。 |
| `notMergeable` | `address`, `duration`, `jsonArray`, `jsonObject`, `personName`, `rangeCurrency`, `rangeFloat`, `rangeInt` | 禁止记录合并时自动处理该字段，避免复合/结构化值语义冲突。 |
| `notSortable` | `array`, `attachmentMultiple`, `checklist`, `jsonArray`, `linkMultiple`, `map`, `multiEnum`, `password`, `urlMultiple` | 禁止列表排序，常见于多值或结构化字段。 |
| `params` | `address`, `array`, `arrayInt`, `attachmentMultiple`, `autoincrement`, `barcode`, `base`, `bool`, `checklist`, `colorpicker`, `currency`, `currencyConverted`, `date`, `datetime`, `datetimeOptional`, `decimal`, `duration`, `email`, `enum`, `enumFloat`, `enumInt`, `file`, `float`, `foreign`, `image`, `int`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `map`, `multiEnum`, `number`, `password`, `personName`, `phone`, `rangeInt`, `text`, `url`, `urlMultiple`, `varchar`, `wysiwyg` | 声明该类型可配置参数白名单（`required/maxLength/options/...`），是字段建模入口。 |
| `personalData` | `address`, `array`, `attachmentMultiple`, `checklist`, `currency`, `date`, `datetime`, `datetimeOptional`, `email`, `enum`, `file`, `image`, `int`, `multiEnum`, `personName`, `phone`, `text`, `url`, `urlMultiple`, `varchar`, `wysiwyg` | 标识字段涉及个人数据（实值为 `true`），用于隐私治理。 |
| `readOnly` | `autoincrement`, `number` | 系统生成字段设为只读，阻止手工修改。 |
| `sanitizerClassName` | `phone` | 单个清洗器配置（`FieldSanitizers\\Phone`）。 |
| `sanitizerClassNameList` | `array`, `barcode`, `checklist`, `colorpicker`, `date`, `datetime`, `datetimeOptional`, `decimal`, `email`, `multiEnum`, `phone`, `text`, `url`, `urlMultiple`, `varchar`, `wysiwyg` | 清洗器链（如 `StringTrim/Date/Datetime/ArrayFromNull`），保存前规范化输入。 |
| `skipOrmDefs` | `address`, `currencyConverted`, `personName`, `rangeCurrency`, `rangeFloat`, `rangeInt` | 跳过自动 ORM 定义，适用于复合/虚拟承接字段。 |
| `textFilter` | `autoincrement`, `barcode`, `email`, `int`, `number`, `personName`, `phone`, `text`, `varchar`, `wysiwyg` | 控制字段是否参与关键字文本过滤。 |
| `textFilterForeign` | `barcode`, `int`, `text`, `varchar` | 启用外键场景下的文本过滤策略（实值为 `true`）。 |
| `translatedOptions` | `array`, `checklist`, `enum`, `multiEnum`, `phone` | 选项值通过 i18n 翻译键展示。 |
| `validationList` | `array`, `arrayInt`, `attachmentMultiple`, `barcode`, `checklist`, `currency`, `date`, `datetime`, `datetimeOptional`, `decimal`, `email`, `enum`, `file`, `float`, `image`, `int`, `jsonArray`, `link`, `linkMultiple`, `linkOne`, `linkParent`, `multiEnum`, `password`, `personName`, `phone`, `text`, `url`, `urlMultiple`, `varchar`, `wysiwyg` | 声明字段校验链（如 `required/maxCount/maxLength/pattern`）。 |
| `validatorClassName` | `attachmentMultiple`, `barcode`, `linkOne`, `password`, `wysiwyg` | 指定类型专用验证器类（`FieldValidators\\*`）。 |
| `validatorClassNameMap` | `link`, `linkMultiple`, `linkOne` | 按子场景映射验证器（如 `cascadingSelect` 对应专用 validator）。 |
| `valueFactoryClassName` | `address`, `currency`, `date`, `datetime`, `datetimeOptional`, `email`, `link`, `linkMultiple`, `linkParent`, `phone` | 指定值对象工厂（`Field\\*Factory`），统一构造字段值。 |
| `view` | `datetimeOptional` | 指定该类型默认前端视图（`views/fields/datetime-optional`）。 |

### 5.3 AtroCore 支持的全部 Field Type（工程实测）

| field type | 应用场景 |
|---|---|
| `address` | 存储结构化地址（街道、城市、省州、国家、邮编）。 |
| `array` | 存储字符串数组，如标签、关键字、多值编码。 |
| `arrayInt` | 存储整数数组，用于内部多值 ID 或序号集合。 |
| `attachmentMultiple` | 关联多附件，用于图片集、文档包、素材集合。 |
| `autoincrement` | 生成系统递增号，用于流水号或自动编号字段。 |
| `barcode` | 存储条码值，用于商品码、箱码、外部识别码。 |
| `base` | 作为基础承接类型，供其他字段类型复用。 |
| `bool` | 存储布尔开关，如是否启用、是否默认、是否有效。 |
| `checklist` | 存储多选清单并支持勾选场景。 |
| `colorpicker` | 存储颜色值，用于主题色、标记色、状态色。 |
| `currency` | 存储金额及币种，用于价格、成本、费用字段。 |
| `currencyConverted` | 存储换算金额，用于汇率换算后的金额展示/查询。 |
| `date` | 存储日期（无时分秒），用于生效日、截止日、账期日。 |
| `datetime` | 存储日期时间，用于发生时间、创建时间、完成时间。 |
| `datetimeOptional` | 存储可空日期时间，用于“可填可不填”的时间点字段。 |
| `decimal` | 存储高精度小数，用于计量值、税率、折扣率。 |
| `duration` | 存储时长类值，用于周期、持续时间、有效时段。 |
| `email` | 存储邮箱地址，用于通知邮箱、联系邮箱。 |
| `enum` | 存储单选枚举，用于状态、等级、分类。 |
| `enumFloat` | 存储浮点枚举，用于小数档位型枚举值。 |
| `enumInt` | 存储整数枚举，用于数字档位型枚举值。 |
| `file` | 关联单文件，用于主文档、证照、附件原件。 |
| `float` | 存储浮点数，用于重量、体积、系数。 |
| `foreign` | 映射外部字段值，用于引用对象的镜像字段。 |
| `image` | 关联单图片，用于主图、头像、封面图。 |
| `int` | 存储整数，用于数量、优先级、排序号。 |
| `jsonArray` | 存储 JSON 数组，用于可变结构列表数据。 |
| `jsonObject` | 存储 JSON 对象，用于可变结构配置数据。 |
| `link` | 关联单条记录，用于负责人、所属组织、主关系。 |
| `linkMultiple` | 关联多条记录，用于多对多关系。 |
| `linkOne` | 关联单条记录（单向/一对一）场景。 |
| `linkParent` | 关联多态父对象，用于“父类型+父ID”关系。 |
| `map` | 存储地图结构信息，用于坐标与地理位置数据。 |
| `multiEnum` | 存储多选枚举，用于多标签、多渠道、多属性。 |
| `number` | 存储编号型值，用于业务单号、凭证号、规则编号。 |
| `password` | 存储敏感口令类值，用于需受控输入的凭据字段。 |
| `personName` | 存储姓名结构（名/姓），用于联系人姓名字段。 |
| `phone` | 存储电话号码，用于联系人电话、通知电话。 |
| `rangeCurrency` | 存储金额区间（from/to + currency），用于预算区间、价格区间。 |
| `rangeFloat` | 存储浮点区间（from/to），用于数值范围筛选。 |
| `rangeInt` | 存储整数区间（from/to），用于整数范围筛选。 |
| `text` | 存储长文本，用于备注、说明、描述。 |
| `url` | 存储单链接，用于官网、详情页、资源地址。 |
| `urlMultiple` | 存储多链接，用于参考链接、资源列表。 |
| `varchar` | 存储短文本，用于名称、编码、标题。 |
| `wysiwyg` | 存储富文本 HTML，用于图文说明、模板内容。 |


## 6. Attribute Definition

### 6.1 业务模型总览

AtroCore 的属性模型是三层：
1. `Attribute`（定义层）：定义属性模板，声明类型、规则、分组与展示归属。
2. `ClassificationAttribute`（绑定层）：把属性模板绑定到某个分类，并附加分类级覆盖规则。
3. `*_attribute_value`（值层）：记录级真实值，按记录维度存储。

核心结论：
1. `Attribute` 定义在 Entity 下，不等于该 Entity 全量记录自动拥有该属性值。
2. 记录是否显示/可编辑某属性，取决于该记录是否已有对应 attribute value。
3. `ClassificationAttribute` 不是给 Classification 自身加字段，而是“分类上下文的属性应用配置”。

### 6.2 核心对象与关系

| 对象 | 职责 | 关键关系 |
|---|---|---|
| `Attribute` | 属性模板 | `belongsTo AttributePanel`、`belongsTo AttributeGroup`、`belongsTo compositeAttribute`、`hasMany nestedAttributes`、`hasMany classificationAttributes` |
| `ClassificationAttribute` | 分类与属性的绑定 + 覆盖规则 | `belongsTo Classification`、`belongsTo Attribute`，唯一键 `(classification_id, attribute_id, deleted)` |
| `AttributePanel` | 页面分区容器 | `hasMany attributes`（按 `sortOrder`） |
| `AttributeGroup` | 业务语义分组 | `hasMany attributes`（按 `attributeGroupSortOrder`） |

### 6.3 Attribute（定义层）

#### 6.3.1 基本定义

1. `name` 必填，多语言。
2. `entity` 必填，创建后不可修改。
3. `type` 必填，且必须来自 `metadata/attributes/*.json`。
4. `code` 若填写，需满足代码规则，且不能与目标实体现有固定字段重名。

#### 6.3.2 展示与组织

1. `attributePanel` 必填，用于确定属性属于哪个页面分区。
2. `attributeGroup` 可选，用于语义归类。
3. `sortOrder`、`attributeGroupSortOrder` 控制排序。
4. `attributePanel/entity`、`attributeGroup/entity` 必须与 Attribute 自身 `entity` 一致。

#### 6.3.3 复合属性（结构关系）

1. `compositeAttribute` 是子属性指向父属性的物理父指针（列 `composite_attribute_id`）。
2. `nestedAttributes` 是父到子集合的反向关系视图，不单独落库。
3. 父属性必须 `type=composite`，且禁止自引用/环引用。
4. 在记录值层（`<entity>_attribute_value`）中，`composite` 父属性通常也会有一条记录，用于表达“该结构已挂载”。

#### 6.3.4 类型参数与条件规则

1. 参数按 `type` 动态显示（如 `pattern/min/max/maxLength/entityType/fileType`）。
2. 内置条件规则：`conditionalRequired/ReadOnly/Protected/Visible/DisableOptions`。
3. 多语言能力由属性类型元数据决定；非多语言类型保存时会强制 `isMultilang=false`。

### 6.4 ClassificationAttribute（绑定层）

#### 6.4.1 解决的业务问题

在同一实体下，不同分类通常需要不同属性集合与规则。  
`ClassificationAttribute` 用于表达“某分类使用哪些属性，以及这些属性在该分类中的约束与默认值”。

#### 6.4.2 承载内容

1. 绑定关系：`classificationId + attributeId`。
2. 分类级覆盖：`isRequired/isReadOnly/isProtected/min/max/maxLength/...`。
3. 分类级默认值：统一落在 `data.default`，输出时展开到 `value/valueFrom/valueTo/...`。
4. 分类级条件规则：`enableConditional* + conditional*`。

#### 6.4.3 一致性口径（实现现状）

1. 前端选择属性时按 `classification.entityId` 过滤（`onlyForEntity`）。
2. 后端未做“`classification.entityId == attribute.entityId`”的显式硬校验。
3. 因此一致性主要依赖前端过滤与后续值写入链路；跨实体硬写通常会形成无效或失败配置。

### 6.5 属性值（值层）与记录维护

1. 属性值写入 `<entity>_attribute_value`，不回写业务主表固定列。
2. record 可直接 add/remove attribute value（不依赖 Classification）。
3. record 也可通过新增/删除 `ClassificationAttribute` 触发批量联动。
4. 复合属性场景下，父子属性值会按规则递归联动处理。
5. 复合属性场景下，父属性行主要承担结构占位语义；实际业务值通常落在子属性行。

### 6.6 Panel / Group / Composite / Layout 的分工

1. `AttributePanel`：页面分区容器，回答“属性显示在哪个板块”。
2. `AttributeGroup`：语义分组，回答“属性在业务上属于哪一类”。
3. `composite`：结构关系，回答“属性之间的父子组成关系”。
4. `Layout`：页面框架编排，回答“整个页面如何布局”。

分层原则：
1. `Layout` 管页面框架和入口。
2. `Panel/Group` 管属性域内部组织。
3. `ClassificationAttribute` 管分类上下文下“哪些属性生效 + 规则是什么”。

### 6.7 与固定 Field 的边界

1. `Field`：稳定结构、固定列、强 schema 约束。
2. `Attribute`：高变化业务特征、运行时扩展。
3. 建模建议：核心主键/流程字段优先 Field；分类差异化特征优先 Attribute。

## 7. Client Definition

### 7.1 模型定位

`clientDefs` 是 AtroCore 的前端行为模型，定义“实体在 UI 层如何呈现与交互”。

它主要回答三件事：
1. 用哪个 controller、哪个 list/detail/edit/modal 视图。
2. 允许哪些筛选、关系操作、批量动作和拖拽排序。
3. 详情页需要挂哪些业务面板与附加查询字段。

### 7.2 配置构件（AtroCore 实测）

按 `app/Atro/Resources/metadata/clientDefs/*.json`（77 个文件）统计，常用构件为：
1. `controller`：入口控制器（69/77）。
2. `iconClass`：图标语义（45/77）。
3. `recordViews` / `views` / `modalViews`：多视图映射。
4. `boolFilterList` + `hiddenBoolFilterList`：显式/隐式筛选能力。
5. `relationshipPanels`：关系面板能力（选择、动作、拖拽、排序、专用 view）。
6. `bottomPanels`：详情页附加业务面板。
7. `additionalSelectAttributes`：为前端逻辑补齐额外字段。
8. `disabledMassActions`：禁用高风险批量动作（如 `merge`）。

### 7.3 运行机制（业务视角）

1. `boolFilterList` 只声明“可用筛选名”，具体逻辑在 `SelectManager` 中实现。
2. `relationshipPanels` 是业务协作核心：可定义自定义动作、选择过滤、拖拽排序和比较视图。
3. 同一实体可绑定多个视图模式（record/list/modal/compare），因此前端行为可按场景分层。

### 7.4 Attribute 领域案例

1. `Attribute` 使用专用 `recordViews`（detail/list/edit-small）。
2. `Attribute` 使用复合属性防环筛选（`notParentCompositeAttribute/notChildCompositeAttribute`）。
3. `Attribute` 通过 `additionalSelectAttributes` 拉取 `conditional*` 字段支撑动态规则编辑。
4. `Attribute` 在 `bottomPanels` 挂 `extensibleEnumOptions` 等业务面板。
5. `Classification` 的 `relationshipPanels.classificationAttributes` 使用专用面板 view。
6. `Classification` 同时提供 `unlinkRelatedAttribute` 与 `cascadeUnlinkRelatedAttribute` 两类动作。
7. `AttributePanel` / `AttributeGroup` 都通过 `relationshipPanels.attributes` 维护属性集合。
8. `AttributePanel` / `AttributeGroup` 都启用拖拽，但排序字段不同（`sortOrder` vs `attributeGroupSortOrder`）。
9. `AttributePanel` / `AttributeGroup` 都通过 `onlyForEntity` 约束可选属性范围。

### 7.5 与第 6 章、Layout 的边界

1. 第 6 章定义的是属性业务与数据模型（定义层/绑定层/值层）。
2. 第 7 章定义的是这些模型在前端的交互行为与操作入口。
3. `Layout` 负责页面编排；`clientDefs` 负责行为能力，两者协同不替代。

### 7.6 落地建议

1. 新增实体时，优先明确 `recordViews + relationshipPanels`，再补筛选与动作。
2. 过滤能力必须双端对齐：`clientDefs.boolFilterList` 与 `SelectManager` 同步实现。
3. 级联删除/批量改动等高风险动作应单独命名，不复用普通 `unlink` 语义。

## 8. Layout 模型（页面编排层）

### 8.1 模型定位

`Layout` 在 AtroCore 中是“页面编排数据模型”，用于定义某实体在某视图类型下的布局内容。

它回答的是：
1. 哪些字段/关系/分区在页面出现。
2. 出现顺序、列位置、样式与可交互属性。
3. 不同视图类型（list/detail/relationships/...）各自使用哪套布局数据。

### 8.2 核心对象

| 对象 | 职责 | 关键字段/关系 |
|---|---|---|
| `Layout` | 布局头对象 | `entity`, `viewType`, `relatedEntity`, `relatedLink`, `layoutProfile`, `hash` |
| `LayoutListItem` | 列表/看板类条目 | `name`, `sortOrder`, `link`, `align`, `width`, `editable`, `attributeId` |
| `LayoutSection` | 详情/摘要分区 | `name`, `style`, `sortOrder` |
| `LayoutRowItem` | 分区内单元格条目 | `name`, `rowIndex`, `columnIndex`, `fullWidth` |
| `LayoutRelationshipItem` | 关系面板条目 | `name`, `sortOrder`, `style`, `hiddenPerDefault` |
| `LayoutSidePanelItem` | 侧边面板条目 | `name`, `sortOrder`, `style`, `sticked`, `disabled` |
| `LayoutProfile` | 布局方案（配置集） | `isActive`, `isDefault`, `navigation`, `dashboardLayout`, `layouts` |
| `UserEntityLayout` | 用户级布局偏好 | `user`, `entity`, `viewType`, `relatedEntity`, `relatedLink`, `layoutProfile` |

### 8.3 视图类型与落库模型映射

按 `Repositories/Layout::saveContent`，布局内容按 `viewType` 映射到不同子表：
1. `list/navigation/insights/selection/kanban` -> `LayoutListItem`。
2. `summary/detail` -> `LayoutSection + LayoutRowItem`。
3. `relationships/selectionRelations` -> `LayoutRelationshipItem`。

补充：
1. `Layout` 本体通过 `hash + deleted` 做唯一键，`hash` 由 `layoutProfileId/entity/relatedEntity/relatedLink/viewType` 计算。
2. 删除 `Layout` 时会按 `viewType` 级联清理对应子项集合。

### 8.4 运行流程（控制器口径）

`Controllers/Layout.php` 提供布局运行时接口：
1. `getContent`：按 `scope + viewType + relatedScope + layoutProfileId` 获取布局。
2. `updateContent`：更新布局内容（需 `layoutProfileId`），保存后清缓存。
3. `resetToDefault`：重置某一布局到默认。
4. `resetAllToDefault`：重置某布局方案全部布局。
5. `savePreference`：保存用户布局偏好（用户级生效）。

### 8.5 与第 6/7 章的分工

1. 第 6 章（Attribute）定义“数据语义和规则”。
2. 第 7 章（clientDefs）定义“前端行为能力和交互入口”。
3. 第 8 章（Layout）定义“最终页面编排结果”。

简化理解：
1. `Attribute/Field` 决定“有什么”。
2. `clientDefs` 决定“怎么操作”。
3. `Layout` 决定“怎么摆放”。

### 8.6 业务建模建议

1. 布局评审与数据模型评审分开进行，避免把业务规则写进布局层。
2. 先固化 `viewType` 目标，再设计对应子模型（ListItem / Section+RowItem / RelationshipItem）。
3. 多角色、多部门差异场景优先用 `LayoutProfile` 管理，不在同一布局里堆条件分支。
4. 使用 `relatedEntity.relatedLink` 维护关系列表布局时，保持 link 语义稳定，避免关系改名导致布局失配。

## 9. 继承与关系模型细节

### 9.1 层级实体继承

在 `Hierarchy` 类型中，常见能力包括：

1. 父子记录关系。
2. 字段值继承。
3. 关系继承。
4. 可按字段声明 `inheritanceDisabled` 进行豁免。

### 9.2 关系建模口径

1. `belongsTo`：当前实体持有引用。
2. `hasMany`：当前实体持有反向集合视图。
3. 多对多通常通过关系实体承载。

## 10. 运行时行为（业务视角）

### 10.1 元数据合并优先级

1. 平台核心定义。
2. 模块扩展定义。
3. 运营/实施 custom 定义（最高优先级）。

### 10.2 生效机制

1. 变更进入统一元数据上下文。
2. 结构与前端行为按同一上下文解释执行。
3. 缓存刷新后全局一致生效。

## 11. 端到端建模样例（业务）

目标：新增“保质期管理”能力。

1. 在 `Field Type` 复用 `int` 契约。
2. 在 `Entity Definition(Product)` 增加 `shelfLifeDays` 字段：
- `type=int`
- `min=0,max=3650`
3. 在 `Attribute` 增加 `storagePolicy`（复合）及子属性。
4. 在 `Client Definition/Layout` 把以上内容挂到“基础信息”区。
5. 发布后商品页面可录入保质期与储存策略。

## 12. 治理建议（面向业务落地）

1. 先定字段类型契约，再开实体字段。
2. 稳定结构优先字段，高变化语义优先属性。
3. 页面编排与结构定义分开评审。
4. 重大变更必须做影响评估与回滚预案。
5. 维护“对象字典 + 类型字典 + 属性字典”三份基线清单。

## 13. 对你当前方案的直接映射

AtroCore 业务元模型可直接映射到你当前章节结构：

1. `Scope/Entity/Field Type/Field/Attribute` -> `02.baseline-metadata`
2. custom 覆盖思路 -> `03.tenant-metadata`
3. 结构生效与存储 -> `04.runtime-storage`
4. 变更发布与回滚 -> `05.governance`

## 14. 总结

AtroCore 的元数据模型细节可以概括为：

1. `Scope` 定义对象能力与语义类型。
2. `Entity Definition` 定义字段、关系与索引契约。
3. `midKeys + foreign + relationName` 共同决定中间关系执行方向。
4. `ReferenceData` 采用文件存储，适合稳定字典数据。
5. `Archive` 采用数据库存储，语义上用于审计/历史对象。
6. `Client Definition/Layout` 承载展示与交互编排。

这是一套“结构、语义、展示分层 + 运行时合成”的业务元模型，而不是单一配置文件体系。
