## 三、Saudi Arabia (SA) 专用扩展

对应 Pagero PUF KSA Phase2 格式，测试文件位于 `sa/`。

### 3.1 `kdubl:InvoiceDocumentReference` — 发票文档引用（调整/冲销原因）

用于红票（381）、借记票等需要关联原始发票的场景，放在 `kdubl:PiaozoneExtension` 下。适用国家：SA、TH 等。

```xml
<kdubl:InvoiceDocumentReference>
    <!-- 子发票类型码，细分发票类型（如借记票据、信用票据等） -->
    <kdubl:SubInvoiceTypeCode>T03</kdubl:SubInvoiceTypeCode>
    <!-- 开具原因代码，由各国税务规范定义 -->
    <kdubl:DocumentIssuanceReasonCode>DBNS01</kdubl:DocumentIssuanceReasonCode>
    <!-- 开具原因描述文本 -->
    <kdubl:DocumentIssuanceReason>Price calculation error - additional charge</kdubl:DocumentIssuanceReason>
    <!-- 原始发票金额（被冲销/调整的原始票据金额） -->
    <kdubl:OriginalAmount currencyID="THB">4357.04</kdubl:OriginalAmount>
    <!-- 差额金额（本次调整金额，正数为补收，负数为退款） -->
    <kdubl:DifferenceAmount currencyID="THB">100.00</kdubl:DifferenceAmount>
</kdubl:InvoiceDocumentReference>
```

| 子标签 | 必填 | 含义 | 备注 |
|--------|------|------|------|
| `SubInvoiceTypeCode` | 否 | 子发票类型码，细分发票业务类型 | 出现时不能为空（KDUBL-EXT-009）|
| `DocumentIssuanceReasonCode` | 条件 | 开具原因代码，由各国税务规范定义 | 存在 `OriginalAmount`/`DifferenceAmount` 时必填（KDUBL-EXT-007），不能为空字符串（KDUBL-EXT-008）|
| `DocumentIssuanceReason` | 否 | 原因描述文本 | SA KSA-10 对应 `BillingReferenceExtension/Note` |
| `OriginalAmount` | 否 | 原始发票金额（被冲销/调整的原始票据金额），需携带 `@currencyID` | 出现时必须同时有 `DocumentIssuanceReasonCode`（KDUBL-EXT-007）|
| `DifferenceAmount` | 否 | 差额金额（本次调整金额），需携带 `@currencyID` | 出现时必须同时有 `DocumentIssuanceReasonCode`（KDUBL-EXT-007）|

---

### 3.2 SA 行级扩展字段

放在 `kdubl:LineExtension` 内：

#### 3.2.1 `kdubl:TaxInclusiveLineExtensionAmount` — 行含税金额（KSA-12）

```xml
<kdubl:TaxInclusiveLineExtensionAmount currencyID="SAR">115.00</kdubl:TaxInclusiveLineExtensionAmount>
```

| 属性 | 说明 |
|------|------|
| **含义** | 该行含税总金额 = `LineExtensionAmount` + `TaxTotal/TaxAmount`，KSA 要求在 PUF 中上报 |
| **计算公式** | `LineExtensionAmount + TaxTotal/TaxAmount` |
| **PUF 对应** | `puf:LineExtension/TaxInclusiveLineExtensionAmount`（KSA-12） |

#### 3.2.2 `kdubl:TaxExtensions` / `kdubl:TaxExtension` — 行税种扩展

```xml
<kdubl:TaxExtensions>
    <kdubl:TaxExtension>
        <kdubl:TaxIndex>1</kdubl:TaxIndex>
        <kdubl:InternalTaxCode>SA_VAT_S</kdubl:InternalTaxCode>
    </kdubl:TaxExtension>
</kdubl:TaxExtensions>
```

| 子标签 | 含义 |
|--------|------|
| `kdubl:TaxIndex` | 税种序号，与行内 `TaxTotal` 顺序对应 |
| `kdubl:InternalTaxCode` | 内部税种代码，用于通道转换时识别税率档。`SA_VAT_S`=标准税率、`SA_VAT_E`=免税 |

**完整 SA 行级扩展示例：**

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <!-- KSA-12: LineExtensionAmount(100) + TaxAmount(15) = 115 -->
        <kdubl:TaxInclusiveLineExtensionAmount currencyID="SAR">115.00</kdubl:TaxInclusiveLineExtensionAmount>
        <kdubl:TaxExtensions>
            <kdubl:TaxExtension>
                <kdubl:TaxIndex>1</kdubl:TaxIndex>
                <kdubl:InternalTaxCode>SA_VAT_S</kdubl:InternalTaxCode>
            </kdubl:TaxExtension>
        </kdubl:TaxExtensions>
    </kdubl:LineExtension>
    <kdubl:LineExtension>
        <kdubl:LineID>2</kdubl:LineID>
        <kdubl:TaxInclusiveLineExtensionAmount currencyID="SAR">100.00</kdubl:TaxInclusiveLineExtensionAmount>
        <kdubl:TaxExtensions>
            <kdubl:TaxExtension>
                <kdubl:TaxIndex>1</kdubl:TaxIndex>
                <kdubl:InternalTaxCode>SA_VAT_E</kdubl:InternalTaxCode>
            </kdubl:TaxExtension>
        </kdubl:TaxExtensions>
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

---

### 3.3 `kdubl:PrepaidPaymentExtension` — 预付款发票 VAT 信息（KSA-26~34）

用于 **386 预付款发票**，放在 `kdubl:PiaozoneExtension` 下：

```xml
<kdubl:PrepaidPaymentExtension>
    <cac:TaxTotal>
        <cbc:TaxAmount currencyID="SAR">1.50</cbc:TaxAmount>
        <cac:TaxSubtotal>
            <cbc:TaxableAmount currencyID="SAR">10.00</cbc:TaxableAmount>
            <cbc:TaxAmount currencyID="SAR">1.50</cbc:TaxAmount>
            <cac:TaxCategory>
                <cbc:ID>S</cbc:ID>
                <cbc:Percent>15.00</cbc:Percent>
                <cac:TaxScheme>
                    <cbc:ID>VAT</cbc:ID>
                </cac:TaxScheme>
            </cac:TaxCategory>
        </cac:TaxSubtotal>
    </cac:TaxTotal>
</kdubl:PrepaidPaymentExtension>
```

| 属性 | 说明 | PUF 对应（KSA） |
|------|------|----------------|
| 整块 | 预付款发票关联的 VAT 明细，在 KDUBL 中以结构化 `cac:TaxTotal` 存储 | `puf:PrepaidPaymentExtension` |
| `TaxableAmount` | 预付款对应的不含税金额（KSA-31） | KSA-31 |
| `TaxAmount`（子计）| 预付款对应的 VAT 税额（KSA-32） | KSA-32 |
| `TaxCategory/ID` | VAT 税种代码（KSA-33） | KSA-33 |
| `TaxCategory/Percent` | VAT 税率（KSA-34） | KSA-34 |

> **说明**：标准 KDUBL 中 `cac:PrepaidPayment` 存放预付款基本信息（金额、日期、ID），VAT 明细过于复杂无法直接放入，因此单独用 `kdubl:PrepaidPaymentExtension` 携带。

---

## 四、国家扩展
参考/country/目录下，国家的特有扩展