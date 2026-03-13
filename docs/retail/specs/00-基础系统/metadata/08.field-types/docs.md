---
title: Built-in Field Types
taxonomy:
    category: docs
---

# 内置字段类型说明

本文描述内置字段类型元数据（`metadata/fields/*.json`）的业务建模方式与使用场景。

## 通用模型

每个字段类型文件通常包含：

1. `params`：允许在字段实例中配置的参数。
2. `fieldDefs`：应用到字段实例的默认定义。
3. `filter/textFilter/qbFilterType`：筛选能力。
4. `auditable/personalData/notCreatable/notSortable`：治理能力。
5. `actualFields/notActualFields/fields`：复合字段或派生字段行为。

## 类型详解（40）

### `array`
- 用途：字符串数组，适合标签、多值文本集合。
- 关键参数：`translation`, `isMultilang`, `noEmptyString`, `readOnly`, `protected`。
- 场景：多值标签、关键词集合。

### `arrayInt`
- 用途：整数数组，适合 ID 列表或数值集合。
- 关键参数：`options`, `translation`, `noEmptyString`。
- 场景：预定义整型选项多选结果。

### `autoincrement`
- 用途：系统自增编号。
- 关键参数：无（类型固定行为）。
- 场景：流水号、内部编号。

### `base`
- 用途：基础抽象类型模板（不用于直接业务建模）。
- 关键参数：`required`, `duplicateIgnore`, `inheritanceDisabled`。
- 场景：作为其他类型的公共能力基线。

### `bool`
- 用途：布尔值。
- 关键参数：`default`, `notNull`, `isMultilang`。
- 场景：开关类状态字段。

### `color`
- 用途：颜色值。
- 关键参数：`default`, `unique`, `index`。
- 场景：颜色标识、样式配置。

### `colorpicker`
- 用途：颜色选择专用类型（管理端辅助）。
- 关键参数：`default`。
- 场景：配置界面的颜色参数。

### `date`
- 用途：日期。
- 关键参数：`defaultDate`, `after`, `before`, `useNumericFormat`。
- 场景：生效日期、截止日期。

### `datetime`
- 用途：日期时间。
- 关键参数：`defaultDate`, `after`, `before`, `showUser`。
- 场景：创建时间、计划时间点。

### `datetimeOptional`
- 用途：可空日期时间（带附加 `date` 子字段）。
- 关键参数：`default`, `after`, `before`。
- 场景：可选预约时间、可选提醒时间。

### `duration`
- 用途：时长。
- 关键参数：`default`, `options`。
- 场景：会议时长、处理时长。

### `email`
- 用途：邮箱地址。
- 关键参数：`maxLength`, `pattern`, `trim`, `unique`。
- 场景：联系人邮箱、通知邮箱。

### `enum`
- 用途：单选枚举。
- 关键参数：`options`, `default`, `isSorted`, `translation`。
- 场景：状态、类型、级别。

### `enumFloat`
- 用途：浮点枚举。
- 关键参数：`options`, `default`。
- 场景：离散浮点档位。

### `enumInt`
- 用途：整数枚举。
- 关键参数：`options`, `default`。
- 场景：离散整数档位。

### `extensibleEnum`
- 用途：可扩展单选枚举（引用外部枚举字典）。
- 关键参数：`extensibleEnum`, `allowedOptions`, `extensibleEnumOptions`。
- 场景：主数据驱动的选项字段。

### `extensibleMultiEnum`
- 用途：可扩展多选枚举。
- 关键参数：同 `extensibleEnum`。
- 场景：主数据驱动的多选标签。

### `file`
- 用途：文件引用。
- 关键参数：`fileType`, `previewSize`, `default`。
- 场景：附件、图片、文档。

### `float`
- 用途：浮点数。
- 关键参数：`min`, `max`, `amountOfDigitsAfterComma`, `measure`。
- 场景：价格、比率、重量。

### `foreign`
- 用途：引用关联实体字段的只读投影。
- 关键参数：`link`, `field`。
- 场景：展示关联对象的某个属性。

### `int`
- 用途：整数。
- 关键参数：`min`, `max`, `disableFormatting`, `measure`。
- 场景：数量、计数、序号。

### `jsonArray`
- 用途：通用 JSON 数组。
- 关键参数：无。
- 场景：复杂结构扩展值（不建议用于强约束业务字段）。

### `jsonObject`
- 用途：通用 JSON 对象。
- 关键参数：无。
- 场景：扩展配置、临时结构化数据。

### `language`
- 用途：语言选择。
- 关键参数：`isSorted`。
- 场景：语言偏好、内容语种。

### `link`
- 用途：单值实体关联。
- 关键参数：`foreignName`, `default`, `currentUserAsDefault`, `extensibleEnum`。
- 场景：负责人、所属组织、关联对象。

### `linkMultiple`
- 用途：多值实体关联。
- 关键参数：`foreignName`, `sortable`, `fileTypes`, `recordRelatedChangesInStream`, `extensibleEnum`。
- 场景：成员列表、关联集合。

### `linkParent`
- 用途：多态父级关联（`id+type`）。
- 关键参数：`entityList`。
- 场景：活动流父对象、通用挂载对象。

### `map`
- 用途：地图展示类型。
- 关键参数：`provider`, `height`。
- 场景：地理位置展示。

### `markdown`
- 用途：Markdown 富文本。
- 关键参数：`minHeight`, `maxHeight`, `lengthOfCut`, `defaultValueType`, `isMultilang`。
- 场景：说明文档、备注。

### `measure`
- 用途：计量单位关联。
- 关键参数：`measure`, `default`。
- 场景：单位选择（kg、cm 等）。

### `multiEnum`
- 用途：多选枚举。
- 关键参数：`options`, `isSorted`, `translation`。
- 场景：多标签分类。

### `multiLanguage`
- 用途：语言集合选择。
- 关键参数：`isSorted`。
- 场景：支持语种列表。

### `password`
- 用途：密码字段（数据库类型强制为 `varchar`）。
- 关键参数：`required`。
- 场景：账号密码输入。

### `rangeFloat`
- 用途：浮点区间（派生 `from/to`）。
- 关键参数：`defaultFrom/defaultTo`, `minFrom/maxFrom`, `minTo/maxTo`, `amountOfDigitsAfterComma`。
- 场景：价格区间、温度区间。

### `rangeInt`
- 用途：整型区间（派生 `from/to`）。
- 关键参数：`defaultFrom/defaultTo`, `minFrom/maxFrom`, `minTo/maxTo`。
- 场景：数量范围、年龄范围。

### `script`
- 用途：脚本计算字段。
- 关键参数：`script`, `outputType`, `preview`, `isMultilang`。
- 场景：公式字段、动态渲染内容。

### `text`
- 用途：长文本。
- 关键参数：`maxLength`, `rowsMin/rowsMax`, `lengthOfCut`, `defaultValueType`, `isMultilang`。
- 场景：描述、备注、正文。

### `url`
- 用途：URL 链接。
- 关键参数：`maxLength`, `strip`, `urlLabel`, `unique`。
- 场景：官网链接、外部资源地址。

### `varchar`
- 用途：短文本。
- 关键参数：`maxLength`, `trim`, `pattern`, `defaultValueType`, `isMultilang`, `measure`。
- 场景：名称、编码、简短标识。

### `wysiwyg`
- 用途：富文本编辑器内容。
- 关键参数：`height`, `minHeight`, `maxLength`, `useIframe`, `htmlSanitizer`, `defaultValueType`, `isMultilang`。
- 场景：公告、富文本详情页内容。

## 使用建议

1. 优先使用强类型字段（`varchar/int/enum/link/...`），谨慎使用 `jsonObject/jsonArray`。
2. 先选类型，再配置参数；避免在实例层配置类型未声明的参数。
3. 变更字段类型模板前，先检查被引用范围并做回归验证。
