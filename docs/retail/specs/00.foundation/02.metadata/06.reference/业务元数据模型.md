# 业务元数据模型

## 目的
统一零售系统对业务对象、字段语义、约束规则与版本演进的建模方式，为页面元数据、接口契约与数据治理提供一致基础。

## 适用范围
- 主档、交易、库存、价格、供应链等业务域
- 领域实体、值对象、枚举、状态机定义
- 业务字段字典、校验规则、编码体系

## 设计原则
- 业务语义先于技术实现
- 模型可追溯、可版本化、可兼容演进
- 字段定义与校验口径前后端一致
- 领域模型与视图模型分层，避免页面直接耦合领域内部结构

## 元模型结构
业务元数据建议包含以下层级：
1. `domain`: 业务域标识与说明
2. `entities`: 实体定义集合
3. `valueObjects`: 值对象定义集合
4. `enums`: 枚举与编码定义集合
5. `relations`: 实体关系定义
6. `constraints`: 跨字段/跨实体约束
7. `stateMachines`: 状态流转定义
8. `version`: 模型版本信息

## 实体模型
| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | string | 是 | 实体唯一标识 |
| name | string | 是 | 实体名称 |
| aggregate | boolean | 否 | 是否聚合根 |
| fields | array | 是 | 字段定义列表 |
| indexes | array | 否 | 索引定义 |
| lifecycle | object | 否 | 生命周期约束 |

## 字段模型
| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | string | 是 | 字段唯一标识 |
| name | string | 是 | 字段名称 |
| dataType | string | 是 | 数据类型，如 `string/number/date/decimal/boolean/object/array` |
| required | boolean | 否 | 是否必填 |
| unique | boolean | 否 | 是否唯一 |
| defaultValue | any | 否 | 默认值 |
| precision | number | 否 | 数值精度 |
| scale | number | 否 | 小数位 |
| ref | object | 否 | 外部引用定义 |
| validators | array | 否 | 校验规则 |
| dictionary | object | 否 | 字典映射 |

## 约束模型
- 单字段约束：长度、范围、正则、非空、唯一
- 跨字段约束：JSON Logic 表达（如基础进价 < 基础售价）
- 跨实体约束：引用完整性、组织权限范围一致性

## 编码与字典
- 业务编码遵循“稳定、可读、不可复用”原则
- 枚举必须提供 `code` 与 `name`
- 字典应声明来源（静态配置/主数据服务）

## 与页面元数据的关系
- 页面字段通过 `binding` 绑定到业务视图模型字段
- 页面 `dataSources` 与业务实体查询接口建立映射
- 页面规则可引用业务字段语义，但不直接承载领域核心约束

## 版本与兼容
- 必须声明 `modelVersion`
- 破坏性变更需升级主版本并提供迁移说明
- 非破坏性变更可升级次版本
- 建议采用 `major.minor.patch` 版本格式

## 示例
```json
{
  "modelVersion": "1.0.0",
  "domain": { "id": "mdm", "name": "主档系统" },
  "entities": [
    {
      "id": "product",
      "name": "商品",
      "aggregate": true,
      "fields": [
        { "id": "id", "name": "商品ID", "dataType": "string", "required": true, "unique": true },
        { "id": "name", "name": "商品名称", "dataType": "string", "required": true },
        { "id": "categoryId", "name": "品类ID", "dataType": "string", "required": true },
        { "id": "basePurchasePrice", "name": "基础进价", "dataType": "decimal", "precision": 18, "scale": 2 },
        { "id": "baseSalePrice", "name": "基础售价", "dataType": "decimal", "precision": 18, "scale": 2 }
      ]
    }
  ],
  "constraints": [
    {
      "id": "price_compare",
      "type": "jsonLogic",
      "expr": {
        "<": [
          { "var": "product.basePurchasePrice" },
          { "var": "product.baseSalePrice" }
        ]
      },
      "message": "基础进价必须小于基础售价"
    }
  ]
}
```

## 变更记录
- 2026-03-05: 初始化版本
