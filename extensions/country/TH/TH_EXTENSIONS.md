## 五、Thailand (TH) 专用扩展

对应泰国电子发票格式，测试文件位于 `th/`（或 Max 示例）。

### 5.1 `kdubl:SupplierAddressInfo` — 卖方地址扩展

补充泰国行政区划中 UBL 标准字段无法覆盖的次级行政单位，放在 `kdubl:PiaozoneExtension` 下：

```xml
<kdubl:SupplierAddressInfo>
    <!-- 次区划代码（Subdistrict / Tambon 级别） -->
    <kdubl:SubdistrictCode>10360400</kdubl:SubdistrictCode>
    <!-- 次区划名称 -->
    <kdubl:SubdistrictName>Donmeung</kdubl:SubdistrictName>
    <!-- 区划代码（District / Amphoe 级别，补充 UBL CitySubdivisionName） -->
    <kdubl:CitySubdivisionCode>1033</kdubl:CitySubdivisionCode>
</kdubl:SupplierAddressInfo>
```

| 子标签 | 含义 | 对应泰国行政级别 |
|--------|------|----------------|
| `SubdistrictCode` | 次区划（街道/村落级）代码 | Subdistrict（Tambon），UBL 无对应字段 |
| `SubdistrictName` | 次区划名称 | Subdistrict（Tambon） |
| `CitySubdivisionCode` | 区划（区/县级）代码 | District（Amphoe），补充 `cbc:CitySubdivisionName` |

> **对应 UBL 路径**：`AccountingSupplierParty/Party/PostalAddress`

---

### 5.2 `kdubl:CustomerAddressInfo` — 买方地址扩展

与 `kdubl:SupplierAddressInfo` 结构完全相同，用于补充买方泰国行政区划信息：

```xml
<kdubl:CustomerAddressInfo>
    <kdubl:SubdistrictCode>10360400</kdubl:SubdistrictCode>
    <kdubl:SubdistrictName>Donmeung</kdubl:SubdistrictName>
    <kdubl:CitySubdivisionCode>1033</kdubl:CitySubdivisionCode>
</kdubl:CustomerAddressInfo>
```

| 子标签 | 含义 |
|--------|------|
| `SubdistrictCode` | 次区划代码（同 SupplierAddressInfo） |
| `SubdistrictName` | 次区划名称（同 SupplierAddressInfo） |
| `CitySubdivisionCode` | 区划代码（同 SupplierAddressInfo） |

> **对应 UBL 路径**：`AccountingCustomerParty/Party/PostalAddress`
