---
title: Capability Model - Entity
taxonomy:
    category: docs
---

# Entity

实体（Entity）定义业务对象的元信息，是字段、关系、索引和集合行为的承载根节点。

## 核心能力

1. 模型承载：通过 `fields`、`links` 描述实体结构与关系。
2. 集合行为控制：通过 `collection` 控制默认排序与文本检索字段。
3. 存储与约束：通过 `indexes`、`uniqueIndexes` 定义索引与唯一约束。
4. 显示语义扩展：通过 `statusStyles` 为状态值提供展示样式。
5. 运行时驱动：系统按 `entityDefs` 动态解释实体行为。

## 详细说明

### 0) 实体基础属性

| 属性 | 能力说明 | 使用场景 |
|---|---|---|
| `code` | 实体的技术标识，用于元数据引用、配置绑定与跨模块关联| 在字段定义、关系定义、权限配置、API 路由等场景中作为实体唯一引用键|
| `name` | 实体的业务名称，用于管理端和业务侧识别| 在实体列表、配置页、业务选择器中展示，帮助用户快速识别实体含义|
| `description` | 实体说明信息，用于补充业务语义、边界和使用约束| 在文档化、交接说明、配置评审时解释实体用途，降低误配置风险|
| `visibility_scope` | 可见范围，支持 `GLOBAL`（全商家）和 `TENANT`（单商家）| 控制实体模型是面向全局基线发布，还是仅在指定商家内可见与可用|
| `visibility_tenants` | 可见商家列表，存储允许访问该实体模型的商家集合| 在 `TENANT` 范围下精确控制哪些商家可见，支持多商家灰度启用|

### 1) 实体业务属性

| 属性 | 能力说明 | 使用场景 |
|---|---|---|
| `fields` | 定义实体字段集合与字段级能力| 新增业务字段、控制字段可见性/校验/存储策略|
| `attributes` | 定义实体可挂载的属性集合，支持基线属性与商家可见范围控制| 在统一属性模型下，为不同商家按需启用属性能力并保持语义一致|
| `links` | 定义实体关系集合（belongsTo/hasMany 等）| 建模主从关系、关联查询、联动删除与关系操作|
| `collection` | 定义集合查询默认行为| 列表页默认排序、默认文本搜索字段|
| `indexes` | 定义普通索引| 提升常见筛选与排序字段查询性能|
| `uniqueIndexes` | 定义复合唯一约束| 防止同一业务维度重复数据（如 `deleted + entity_id + code`）|
| `statusStyles` | 定义状态值到样式的映射| 状态字段在列表/详情中按业务状态高亮显示|

#### 1.1) `collection` 子属性

| 属性 | 能力说明 | 使用场景 |
|---|---|---|
| `sortBy` | 默认排序字段| 未传排序参数时按业务主字段排序|
| `asc` | 默认排序方向（true=升序，false=降序）| 控制列表初始显示顺序|
| `keywordSearchFields` | 默认文本检索字段集合| 全局搜索或快速筛选时限定命中字段|

#### 1.2) `links.*` 子属性

| 属性 | 能力说明 | 使用场景 |
|---|---|---|
| `type` | 关系类型（如 `belongsTo`、`hasMany`）| 服务层据此选择 link/unlink 处理策略|
| `entity` | 关系目标实体| 生成关联查询、反向调用目标实体服务|
| `foreign` | 对端关系名/外键语义| 建立双向关系映射和反向联动|
| `foreignName` | 对端显示字段名| 关系字段展示时使用目标实体指定名称|
| `relationName` | 中间关系名（多对多/层级关系）| 关联表建模与关系查询路由|
| `midKeys` | 中间表键位配置| 层级/多对多关系中映射双键列|
| `disableMassRelation` | 禁用批量关系操作| 避免高风险批量关联造成数据污染|
| `layoutRelationshipsDisabled` | 禁止关系在 Relationships 布局中暴露| 后台隐藏不对业务开放的内部关系|
| `cascadeDelete` | 级联删除控制| 删除主记录时自动清理关联数据|
| `noJoin` | 禁止自动 Join| 大表关联场景下降低查询复杂度|
| `skipOrmDefs` | 跳过部分 ORM 关系定义生成| 特殊关系手工处理，避免默认 ORM 行为冲突|

#### 1.3) `indexes` / `uniqueIndexes` / `statusStyles` 子属性

| 属性 | 能力说明 | 使用场景 |
|---|---|---|
| `indexes.*.columns` | 普通索引列集合| 为高频 where/order by 字段建索引|
| `indexes.*.type` | 索引类型扩展位| 特定数据库场景下声明索引类型|
| `uniqueIndexes.*` | 唯一索引列集合| 多列联合唯一约束|
| `statusStyles.*` | 状态值样式配置| 状态值按颜色/样式区分流程阶段|

#### 1.4) `fields.*` 子属性

说明：按字段来源拆分为两类：`Field Type Params`（Field 的 type）与 `Field Runtime Params`（实体字段运行时与展示控制属性）

##### 1.4.1) Field Type Params（字段类型参数）

| 属性 | 归属 field type | 值类型（原始json） | 能力说明 | 使用场景 |
|---|---|---|---|---|
| `default` | `bool,color,colorpicker,datetimeOptional,duration,email,enum,enumFloat,enumInt,extensibleEnum,extensibleMultiEnum,file,float,int,link,linkMultiple,markdown,measure,rangeFloat,rangeInt,text,url,varchar,wysiwyg` | `array, boolean, null, number, string` | 默认值 | 创建记录时自动填充初始值 |
| `defaultValueType` | `markdown,text,varchar,wysiwyg` | `string` | 默认值来源类型 | 通过 API 获取“当前时间/用户”等动态默认值 |
| `disableFormatting` | `int` | `boolean` | 禁用格式化输出 | 原样输出文本用于二次处理 |
| `dropdown` | `extensibleEnum,extensibleMultiEnum,link,linkMultiple,measure` | `boolean` | 下拉模式显示标记 | 枚举/关联字段以下拉方式渲染 |
| `field` | `foreign` | `string` | 关联字段名引用 | 复合/派生字段回指主字段 |
| `foreignName` | `link,linkMultiple` | `string` | 外部显示字段名 | 关联值展示采用指定目标字段 |
| `index` | `color,date,datetime,email,float,int,rangeFloat,rangeInt,url,varchar` | `boolean` | 字段级索引标记 | 单字段检索性能优化 |
| `inheritanceDisabled` | `array,arrayInt,base,bool,color,colorpicker,date,datetime,datetimeOptional,duration,email,enum,enumFloat,enumInt,extensibleEnum,extensibleMultiEnum,file,float,int,language,link,linkMultiple,markdown,measure,multiEnum,multiLanguage,password,rangeFloat,rangeInt,text,url,varchar,wysiwyg` | `boolean` | 禁用继承 | 层级实体中该字段不继承父值 |
| `isMultilang` | `array,bool,markdown,script,text,url,varchar,wysiwyg` | `boolean` | 多语言字段标记 | 名称/描述按语言存储多份值 |
| `isSorted` | `enum,language,multiEnum,multiLanguage` | `boolean` | 选项已排序标记 | 枚举选项保持既定排序规则 |
| `lengthOfCut` | `markdown,text,wysiwyg` | `number` | 截断长度 | 列表中长文本按长度裁剪显示 |
| `link` | `foreign` | `string` | 关联名引用 | 查询转换时根据 link 解析列映射 |
| `max` | `float,int` | `number` | 最大值 | 数值输入上限校验 |
| `maxHeight` | `markdown` | `number` | 最大高度 | 文本区域 UI 高度限制 |
| `maxLength` | `email,text,url,varchar,wysiwyg` | `number, string` | 最大长度 | 文本输入长度校验 |
| `min` | `float,int` | `number` | 最小值 | 数值输入下限校验 |
| `minHeight` | `markdown,wysiwyg` | `number` | 最小高度 | 文本区域基础展示高度 |
| `notNull` | `bool,float,int,markdown,text,url,varchar,wysiwyg` | `boolean` | 非空约束 | 数据库存储层禁止空值 |
| `options` | `arrayInt,duration,enum,enumFloat,enumInt,multiEnum` | `array` | 静态选项集合 | 枚举字段定义可选值 |
| `previewSize` | `file` | `string` | 预览尺寸 | 图片字段控制预览大小 |
| `protected` | `array,arrayInt,bool,color,colorpicker,date,datetime,email,enum,extensibleEnum,extensibleMultiEnum,file,float,int,language,link,linkMultiple,markdown,measure,multiEnum,multiLanguage,rangeFloat,rangeInt,text,url,varchar,wysiwyg` | `boolean` | 受保护字段 | 创建后不允许普通编辑修改 |
| `readOnly` | `array,arrayInt,bool,color,colorpicker,date,datetime,datetimeOptional,email,enum,enumFloat,enumInt,extensibleEnum,extensibleMultiEnum,file,float,int,language,link,linkMultiple,linkParent,markdown,measure,multiEnum,multiLanguage,rangeFloat,rangeInt,text,url,varchar,wysiwyg` | `boolean` | 只读字段 | 系统生成字段禁止手工改写 |
| `required` | `array,arrayInt,base,bool,color,colorpicker,date,datetime,datetimeOptional,email,enum,extensibleEnum,extensibleMultiEnum,file,float,int,language,link,linkMultiple,linkParent,markdown,measure,multiEnum,multiLanguage,password,rangeFloat,rangeInt,text,url,varchar,wysiwyg` | `boolean` | 必填约束 | 保存前必须提供值 |
| `rowsMax` | `text` | `number` | 最大行数 | 详情/列表中控制文本渲染高度 |
| `seeMoreDisabled` | `markdown,text,wysiwyg` | `boolean` | 禁用“查看更多” | 短文本场景不显示展开入口 |
| `translation` | `array,arrayInt,enum,multiEnum` | `string` | 翻译键映射 | 字段文案走多语言字典 |
| `trim` | `email,varchar` | `boolean` | 自动去首尾空格 | 文本清洗，避免脏数据 |
| `unique` | `color,date,datetime,email,float,int,url,varchar` | `boolean` | 唯一约束 | 单字段不允许重复 |
| `useDisabledTextareaInViewMode` | `text` | `boolean` | 视图模式使用禁用文本域 | 详情页以不可编辑文本域显示长文本 |


###### 1.4.1.a) 多类型拆分说明

1. `default` 支持 `array / boolean / null / number / string`
2. `default` 拆分：布尔类字段常为 `boolean`，数值类字段常为 `number`，文本与引用类字段常为 `string`，多值类字段可为 `array`，部分可空场景为 `null`
3. `maxLength` 支持 `number / string`
4. `maxLength` 拆分：常规长度约束使用 `number`，少数字段在原始配置中可出现 `string` 形式

##### 1.4.2) Field Runtime Params（字段运行时元属性）

| 属性 | 归属 field type | 值类型（原始json） | 能力说明 | 使用场景 |
|---|---|---|---|---|
| `aclFieldDisabled` | `runtime/common` | `boolean` | 禁用 ACL 字段级控制 | 对公开字段跳过细粒度 ACL 判断 |
| `auditableEnabled` | `runtime/common` | `boolean` | 显式开启字段审计 | 关键业务字段需要记录变更轨迹 |
| `conditionalProperties` | `runtime/common` | `object` | 条件化属性规则容器 | 按数据状态动态控制必填/可见/只读 |
| `customizable` | `runtime/common` | `boolean` | 标记字段是否可配置 | 控制字段是否允许在管理端调整 |
| `dataField` | `runtime/common` | `boolean` | 底层数据字段映射 | 复杂字段映射到实际存储列 |
| `directAccessDisabled` | `runtime/common` | `boolean` | 禁止直接访问 | 防止敏感字段被通用接口直接操作 |
| `disabled` | `runtime/common` | `boolean` | 禁用字段 | 阶段性下线字段但保留历史结构 |
| `editorActions` | `runtime/common` | `object` | 编辑器动作配置 | 富文本或代码编辑器启用特定操作按钮 |
| `emHidden` | `runtime/common` | `boolean` | 在实体管理器隐藏 | 内部技术字段不对配置人员展示 |
| `entity` | `runtime/common` | `string` | 关联目标实体 | link/file 等字段指定目标 scope |
| `entityField` | `runtime/common` | `string` | 目标实体字段 | link 类字段限定可选字段来源 |
| `entityNameField` | `runtime/common` | `string` | 目标实体名称字段 | 控制关联显示文本来源字段 |
| `exportDisabled` | `runtime/common` | `boolean` | 禁止导出 | 敏感/大字段不进入导出文件 |
| `extensibleEnumId` | `runtime/common` | `string` | 绑定可扩展枚举 | 字段选项来自 ExtensibleEnum 动态字典 |
| `fieldProperty` | `runtime/common` | `boolean` | 字段属性取值路径 | 动态从字段定义读取某属性值 |
| `fileTypeId` | `runtime/common` | `string` | 限制文件类型 | 上传字段仅允许指定文件类型 |
| `filterable` | `runtime/common` | `boolean` | 字段是否允许作为 where 查询条件 | 对支持过滤的字段类型按需开启查询能力，并触发索引校验流程 |
| `fontSize` | `runtime/common` | `number` | 字体大小参数 | 文本输入组件按业务需要调整字号 |
| `hideMultilang` | `runtime/common` | `boolean` | 隐藏多语言开关 | 不允许业务用户切换多语编辑 |
| `importDisabled` | `runtime/common` | `boolean` | 禁止导入 | 避免导入覆盖系统维护字段 |
| `inlineEditDisabled` | `runtime/common` | `boolean` | 禁止行内编辑 | 高风险字段仅允许详情页编辑 |
| `internal` | `runtime/common` | `boolean` | 内部字段标记 | 内部流程字段不暴露给外部接口 |
| `isValue` | `runtime/common` | `boolean` | 值字段标记 | 选项实体中区分“值”与“显示名” |
| `language` | `runtime/common` | `string` | 语言上下文 | 多语言字段绑定具体语言版本 |
| `layoutDetailDisabled` | `runtime/common` | `boolean` | 从详情布局禁用 | 详情页隐藏技术字段 |
| `layoutDetailSmallDisabled` | `runtime/common` | `boolean` | 从小详情布局禁用 | 弹窗详情中隐藏低优先级字段 |
| `layoutListDisabled` | `runtime/common` | `boolean` | 从列表布局禁用 | 列表页不展示低价值字段 |
| `layoutListSmallDisabled` | `runtime/common` | `boolean` | 从小列表布局禁用 | 精简列表中移除次要字段 |
| `layoutMassUpdateDisabled` | `runtime/common` | `boolean` | 禁用批量更新布局 | 防止批改关键字段引发脏数据 |
| `layoutNavigationDisabled` | `runtime/common` | `boolean` | 从导航布局禁用 | 导航/面包屑区域不展示此字段 |
| `layoutRemoveDisabled` | `runtime/common` | `boolean` | 禁止从布局移除 | 关键字段始终保留在布局中 |
| `layoutUploadDisabled` | `runtime/common` | `boolean` | 从上传布局禁用 | 导入上传页面不展示该字段 |
| `len` | `runtime/common` | `number` | 字段长度 | 控制 varchar 存储长度 |
| `logType` | `runtime/common` | `string` | 日志类型标记 | 审计/日志系统按类型分类字段变更 |
| `massUpdateDisabled` | `runtime/common` | `boolean` | 禁止批量更新 | 审计字段或系统字段防止批量写入 |
| `measureId` | `runtime/common` | `string` | 计量单位组标识 | 数值字段绑定单位（如货币、长度） |
| `noLoad` | `runtime/common` | `boolean` | 默认不加载 | 大字段/关系字段按需懒加载 |
| `notStorable` | `runtime/common` | `boolean` | 非持久化字段 | 虚拟字段仅用于展示或计算 |
| `openApiDisabled` | `runtime/common` | `boolean` | 从 OpenAPI 隐藏 | 内部字段不暴露给外部 API 文档 |
| `openApiEnabled` | `runtime/common` | `boolean` | 显式暴露到 OpenAPI | 默认隐藏字段按需公开给集成方 |
| `optionColors` | `runtime/common` | `array` | 选项颜色映射 | 枚举值在 UI 中按颜色区分 |
| `optionsType` | `runtime/common` | `string` | 选项来源类型 | 区分静态选项与动态来源 |
| `rows` | `runtime/common` | `number` | 行数 | 文本输入默认行数 |
| `storeArrayValues` | `runtime/common` | `boolean` | 存储数组原始值 | 多选字段保留原始数组结构 |
| `textFilterDisabled` | `runtime/common` | `boolean` | 禁用文本检索 | 该字段不参与全文/模糊搜索 |
| `tooltip` | `runtime/common` | `boolean` | 提示信息开关或内容 | 表单字段展示操作提示 |
| `twigVariables` | `runtime/common` | `array` | Twig 变量白名单 | 模板字段允许注入指定变量 |
| `type` | `runtime/common` | `string` | 字段类型 | ORM、校验器、渲染器的核心分派依据 |
| `view` | `runtime/common` | `string` | 前端视图组件 | 指定字段使用的 UI 组件实现 |
| `virtualField` | `runtime/common` | `boolean` | 虚拟字段标记 | 运行时计算字段，不落库存储 |


### 2) 实体业务规则

#### 2.1) 查询治理规则（`filterable`）

1. 字段增加 `filterable` 开关，默认关闭
2. 仅当字段类型支持过滤能力时，才允许开启 `filterable`
3. 开启 `filterable` 后，实体保存或发布时必须执行索引评估
4. 索引评估要求：对应字段必须存在可利用索引（单列索引或可利用的复合索引前缀）
5. 索引评估未通过时阻止保存，并返回缺失索引明细
6. 查询界面仅暴露 `filterable=true` 的字段，避免高成本无索引过滤
7. `keywordSearchFields` 仅用于关键字搜索范围白名单，不参与结构化 `where` 条件定义
8. `keywordSearchFields` 中的字段必须满足：字段存在、未禁用、未设置 `textFilterDisabled`、且字段类型支持关键字搜索
9. `filterable=true` 表示允许作为结构化查询字段，`keywordSearchFields` 表示允许参与关键字搜索，两者可独立配置
10. 结构化查询字段由 `filterable` 控制并受索引评估约束；关键字搜索字段由 `keywordSearchFields` 控制并受搜索性能阈值约束
11. 当字段被设置为 `textFilterDisabled=true` 时，必须同时从 `keywordSearchFields` 中移除，避免规则冲突
12. 发布校验必须输出查询治理报告，至少包含：可结构化查询字段清单、关键字搜索字段清单、缺失索引项、冲突项
