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

---

### 5.3 `kdubl:InvoiceDocumentReference` — 80/81 调整发票原单引用扩展

仅当发票为 **80（借项）** 或 **81（贷项）** 调整类型时使用，放在 `kdubl:PiaozoneExtension` 下。用于描述被调整的**原始发票**的附加信息：

```xml
<kdubl:InvoiceDocumentReference>
    <!-- 原始发票的发票子类型码（如 T03/T02/388），注意不是当前调整发票的类型 -->
    <kdubl:SubInvoiceTypeCode>T03</kdubl:SubInvoiceTypeCode>
    <!-- 开票原因码 -->
    <kdubl:DocumentIssuanceReasonCode>DBNS01</kdubl:DocumentIssuanceReasonCode>
    <!-- 开票原因描述 -->
    <kdubl:DocumentIssuanceReason>Price calculation error - additional charge</kdubl:DocumentIssuanceReason>
    <!-- 原始发票总金额 -->
    <kdubl:OriginalAmount currencyID="THB">4357.04</kdubl:OriginalAmount>
    <!-- 调整差额 -->
    <kdubl:DifferenceAmount currencyID="THB">100.00</kdubl:DifferenceAmount>
</kdubl:InvoiceDocumentReference>
```

| 子标签 | 含义 | 80/81 时必填 |
|--------|------|:---:|
| `SubInvoiceTypeCode` | **被引用原始发票**的发票子类型码。注意：ADR 中的 `SubInvoiceTypeCode` 存放当前调整发票的类型（80/81），此处存放原始发票的类型（如 T03/T02/388），两者值不同 | ✓ |
| `DocumentIssuanceReasonCode` | 开票原因码。借项格式 `DBNS01`~`DBNS99`，贷项格式 `CDNS01`~`CDNS99` | ✓ |
| `DocumentIssuanceReason` | 开票原因描述（自由文本） | ✓ |
| `OriginalAmount` | 原始发票总金额，`currencyID` 属性指定货币（如 `THB`） | ✓ |
| `DifferenceAmount` | 调整差额，借项（80）为正数，贷项（81）为负数 | 可选 |

> **与 ADR `SubInvoiceTypeCode` 的区别**：
> - `cac:AdditionalDocumentReference[DocumentType='SubInvoiceTypeCode']/cbc:ID` → 当前发票类型，如 `80`
> - `kdubl:InvoiceDocumentReference/kdubl:SubInvoiceTypeCode` → **被引用原始发票**的类型，如 `T03`
