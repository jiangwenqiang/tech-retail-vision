---
title: Grouping Model
taxonomy:
    category: docs
---

# 显示分组能力（统一归属 metadata_client）

## 统一结论

显示分组（field 和 attribute 在页面上的分组）统一归属 `metadata_client`，不作为独立业务主数据强制建模。

## 推荐设计

1. 每个实体在 `metadata_client` 的 `client_json` 中维护显示分组配置
2. 分组仅用于 UI 渲染编排，不承载业务语义
3. 分组规则支持字段排序、折叠、面板分区、分组标题

## 推荐 JSON 结构

```json
{
  "displayGrouping": {
    "fieldGroups": [
      {"code": "basic", "label": "基础信息", "sortOrder": 10, "items": ["name", "code"]},
      {"code": "business", "label": "业务信息", "sortOrder": 20, "items": ["status", "ownerUser"]}
    ],
    "attributeGroups": [
      {"code": "spec", "label": "规格参数", "sortOrder": 10, "items": ["length", "width", "height"]}
    ],
    "panelGroups": [
      {"code": "main", "label": "主面板", "sortOrder": 10, "groupCodes": ["basic", "spec"]}
    ]
  }
}
```

## 可选扩展

若后续需要“业务语义分组（非仅显示）”，可追加 `metadata_group` 作为可选扩展，不影响当前显示分组方案。
