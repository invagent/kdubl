## 四、Hungary (HU) 专用扩展

对应 Pagero PUF RTIR 格式，测试文件位于 `hu/`。

### 4.1 公共扩展（所有 HU 文件必填）

#### 4.1.1 `kdubl:InvoiceAppearance` — 发票呈现方式

```xml
<kdubl:InvoiceAppearance>ELECTRONIC</kdubl:InvoiceAppearance>
```

| 属性 | 说明 |
|------|------|
| **含义** | 发票在开票方与受票方之间的分发方式，RTIR 强制要求 |
| **可选值** | `ELECTRONIC`（电子）、`PAPER`（纸质） |
| **PUF 对应** | `puf:RestrictedInformation[Key=invoiceAppearance]/Value` |

#### 4.1.2 `kdubl:CustomerVatStatus` — 买方增值税状态

```xml
<kdubl:CustomerVatStatus>DOMESTIC</kdubl:CustomerVatStatus>
```

| 属性 | 说明                                                      |
|------|---------------------------------------------------------|
| **含义** | 买方的增值税纳税人身份，决定买方信息允许内容与校验规则                             |
| **可选值** | `DOMESTIC`（境内纳税人）、`OTHER`（境外买方等）、 `PRIVATE_PERSON`（个人）  |
| **PUF 对应** | `puf:RestrictedInformation[Key=customerVatStatus]/Value` |

#### 4.1.3 发票类型名称 — 使用文档级 `SubInvoiceTypeCode` ADR

HU 发票类型名称通过与 SA 相同的文档级 InvoiceTag ADR 机制携带，**不再使用** `kdubl:InvoiceTypeName` 扩展标签：

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">NORMAL</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 可选值 | 含义 |
|--------|------|
| `NORMAL` | 普通发票 |
| `SIMPLIFIED` | 简化发票 |
| `AGGREGATE` | 汇总发票 |

**PUF 对应**：`cbc:InvoiceTypeCode @name="NORMAL"`（详见第一章 §1.2）

#### 4.1.4 `kdubl:LineExpressionIndicator` — 计量单位自然表达指示器

放在每行的 `kdubl:LineExtension` 内，**每行必填**：

```xml
<kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
```

| 值 | 适用行类型 |
|----|-----------|
| `true` | 普通商品行（可用整数自然单位，如 EA、PCS） |
| `false` | 预付款抵扣行（无计量单位概念） |

**PUF 对应**：`puf:RestrictedInformation[Key=lineExpressionIndicator]/Value`

---

### 4.2 红票（改票）专用扩展 — `HU_CREDITNOTE_381.xml`

#### 4.2.1 `kdubl:ModificationIndex` — 改票序号

```xml
<kdubl:ModificationIndex>1</kdubl:ModificationIndex>
```

| 属性 | 说明 |
|------|------|
| **含义** | 针对同一张原始发票的第几次修改，从 1 开始递增。匈牙利允许对同一原始发票多次出具改票 |
| **必填** | 是（所有改票/红票） |
| **PUF 对应** | `puf:RestrictedInformation[Key=modificationIndex]/Value` |

#### 4.2.2 `kdubl:ModifyWithoutMaster` — 原始发票是否已上报 RTIR

```xml
<kdubl:ModifyWithoutMaster>false</kdubl:ModifyWithoutMaster>
```

| 值 | 含义 |
|----|------|
| `false` | 原始发票已向 RTIR 上报，本改票基于已知记录修改 |
| `true` | 原始发票未上报（主记录缺失） |

**PUF 对应**：`puf:RestrictedInformation[Key=modifyWithoutMaster]/Value`

#### 4.2.3 `kdubl:LineModification` — 行级修改信息

放在改票行对应的 `kdubl:LineExtension` 内：

```xml
<kdubl:LineModification>
    <kdubl:LineOperation>CREATE</kdubl:LineOperation>
    <kdubl:LineNumberReference>2</kdubl:LineNumberReference>
</kdubl:LineModification>
```

| 子标签 | 可选值 | 说明 |
|--------|--------|------|
| `kdubl:LineOperation` | `CREATE` / `MODIFY` / `DELETE` | 该行相对于原始发票的操作类型 |
| `kdubl:LineNumberReference` | 正整数 | 延续原始发票行号的连续编号。原始发票有行 1，则改票新增行的引用号为 2 |

**PUF 对应**：`lineModificationReferenceLineOperation` / `lineModificationReferenceLineNumberReference`

**完整红票行扩展示例：**

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
        <kdubl:LineModification>
            <kdubl:LineOperation>CREATE</kdubl:LineOperation>
            <kdubl:LineNumberReference>2</kdubl:LineNumberReference>
        </kdubl:LineModification>
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

---

### 4.3 预付款抵扣行专用扩展 — `HU_INVOICE_ADVANCE_380.xml`

#### 4.3.1 `kdubl:AdvancePayment` — 预付款信息块

放在预付款抵扣行（`LineExpressionIndicator=false`）的 `kdubl:LineExtension` 内：

```xml
<kdubl:AdvancePayment>
    <kdubl:AdvanceIndicator>true</kdubl:AdvanceIndicator>
    <kdubl:AdvanceOriginalInvoice>HU20260121001</kdubl:AdvanceOriginalInvoice>
    <kdubl:AdvancePaymentDate>2026-01-15</kdubl:AdvancePaymentDate>
    <kdubl:AdvanceExchangeRate>1.00</kdubl:AdvanceExchangeRate>
</kdubl:AdvancePayment>
```

| 子标签 | 含义 | PUF 对应 |
|--------|------|---------|
| `AdvanceIndicator` | 标识本行是预付款抵扣行，固定 `true` | `advanceIndicator` |
| `AdvanceOriginalInvoice` | 原始预付款发票的发票号 | `advanceOriginalInvoice` |
| `AdvancePaymentDate` | 买方实际支付预付款的日期（`YYYY-MM-DD`） | `advancePaymentDate` |
| `AdvanceExchangeRate` | 预付款支付时的汇率，同货币填 `1.00` | `advanceExchangeRate` |

**完整预付款抵扣行示例：**

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
    </kdubl:LineExtension>
    <kdubl:LineExtension>
        <kdubl:LineID>2</kdubl:LineID>
        <kdubl:LineExpressionIndicator>false</kdubl:LineExpressionIndicator>
        <kdubl:AdvancePayment>
            <kdubl:AdvanceIndicator>true</kdubl:AdvanceIndicator>
            <kdubl:AdvanceOriginalInvoice>HU20260121001</kdubl:AdvanceOriginalInvoice>
            <kdubl:AdvancePaymentDate>2026-01-15</kdubl:AdvancePaymentDate>
            <kdubl:AdvanceExchangeRate>1.00</kdubl:AdvanceExchangeRate>
        </kdubl:AdvancePayment>
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

---

### 4.4 外币发票专用扩展 — `HU_INVOICE_TAXCURRENCY_380.xml`

适用于开票货币（`DocumentCurrencyCode`）与计税货币（`TaxCurrencyCode`）不同的场景，如 EUR 开票 / HUF 计税。

#### 4.4.1 `kdubl:TaxCurrencyLegalMonetaryTotal` — 计税货币发票合计

```xml
<kdubl:TaxCurrencyLegalMonetaryTotal>
    <cbc:LineExtensionAmount currencyID="HUF">90417.50</cbc:LineExtensionAmount>
    <cbc:TaxExclusiveAmount currencyID="HUF">90417.50</cbc:TaxExclusiveAmount>
    <cbc:TaxInclusiveAmount currencyID="HUF">114830.23</cbc:TaxInclusiveAmount>
    <cbc:AllowanceTotalAmount currencyID="HUF">0.00</cbc:AllowanceTotalAmount>
    <cbc:ChargeTotalAmount currencyID="HUF">0.00</cbc:ChargeTotalAmount>
    <cbc:PayableRoundingAmount currencyID="HUF">0.00</cbc:PayableRoundingAmount>
    <cbc:PayableAmount currencyID="HUF">114830.23</cbc:PayableAmount>
</kdubl:TaxCurrencyLegalMonetaryTotal>
```

| 子标签（cbc:） | 含义 | PUF 对应 |
|--------------|------|---------|
| `LineExtensionAmount` | 所有行不含税金额之和（计税货币） | `puf:TaxCurrencyLineExtensionAmount` |
| `TaxExclusiveAmount` | 不含税总金额（计税货币） | `puf:TaxCurrencyTaxExclusiveAmount` |
| `TaxInclusiveAmount` | 含税总金额（计税货币） | `puf:TaxCurrencyTaxInclusiveAmount` |
| `AllowanceTotalAmount` | 表头折扣合计（计税货币） | — |
| `ChargeTotalAmount` | 表头收费合计（计税货币） | — |
| `PayableRoundingAmount` | 舍入金额（计税货币） | — |
| `PayableAmount` | 应付总金额（计税货币） | `puf:TaxCurrencyPayableAmount` |

> **说明**：子元素使用标准 UBL `cbc:` 命名空间，与 `cac:LegalMonetaryTotal` 的子元素结构相同，以计税货币（如 HUF）表示对应金额。

#### 4.4.2 `kdubl:TaxTotalExtensions` — 各 TaxTotal 的税率档含税总额

与 UBL body 中的双 `TaxTotal` 一一对应，每个 `kdubl:TaxTotalExtension` 对应一个 `cac:TaxTotal`，在其中为每个税率档补充含税总额。

```xml
<kdubl:TaxTotalExtensions>
    <!-- 第一个 TaxTotal 的扩展（开票货币 EUR） -->
    <kdubl:TaxTotalExtension>
        <kdubl:TaxSubtotalExtensions>
            <kdubl:TaxSubtotalExtension>
                <!-- 该税率档含税总额（开票货币 EUR） -->
                <kdubl:TaxInclusiveAmount currencyID="EUR">317.50</kdubl:TaxInclusiveAmount>
            </kdubl:TaxSubtotalExtension>
        </kdubl:TaxSubtotalExtensions>
    </kdubl:TaxTotalExtension>
    <!-- 第二个 TaxTotal 的扩展（计税货币 HUF） -->
    <kdubl:TaxTotalExtension>
        <kdubl:TaxSubtotalExtensions>
            <kdubl:TaxSubtotalExtension>
                <!-- 该税率档含税总额（计税货币 HUF） -->
                <kdubl:TaxInclusiveAmount currencyID="HUF">114830.23</kdubl:TaxInclusiveAmount>
            </kdubl:TaxSubtotalExtension>
        </kdubl:TaxSubtotalExtensions>
    </kdubl:TaxTotalExtension>
</kdubl:TaxTotalExtensions>
```

| 标签 | 含义 |
|------|------|
| `kdubl:TaxTotalExtensions` | 所有 TaxTotal 扩展的容器 |
| `kdubl:TaxTotalExtension` | 单个 TaxTotal 的扩展，与 UBL body 中的 `cac:TaxTotal` 顺序对应 |
| `kdubl:TaxSubtotalExtensions` | 该 TaxTotal 内各税率档扩展的容器 |
| `kdubl:TaxSubtotalExtension` | 单税率档扩展，与 `cac:TaxSubtotal` 顺序对应 |
| `kdubl:TaxInclusiveAmount` | 该税率档含税总额，`currencyID` 随所属 TaxTotal 货币变化（EUR/HUF） |

> **说明**：外币发票 UBL body 中包含两个 `TaxTotal`（第一个用开票货币含完整 `TaxSubtotal`，第二个用计税货币仅含总税额）。`TaxTotalExtensions` 为每个 TaxTotal 下的每个税率档补充含税总额，供 PUF 格式输出使用。

#### 4.4.3 外币发票行级扩展字段

放在对应行的 `kdubl:LineExtension` 内：

```xml
<kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount currencyID="HUF">114830.23</kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount>
<kdubl:TaxCurrencyLineExtensionAmount currencyID="HUF">90417.50</kdubl:TaxCurrencyLineExtensionAmount>
<kdubl:TaxInclusiveLineExtensionAmount currencyID="EUR">317.50</kdubl:TaxInclusiveLineExtensionAmount>
```

| 标签 | 含义 | PUF 对应 |
|------|------|---------|
| `TaxCurrencyTaxInclusiveLineExtensionAmount` | 行含税金额（计税货币） | `puf:TaxCurrencyTaxInclusiveLineExtensionAmount` |
| `TaxCurrencyLineExtensionAmount` | 行不含税净额（计税货币） | `puf:TaxCurrencyLineExtensionAmount` |
| `TaxInclusiveLineExtensionAmount` | 行含税金额（开票货币） | `puf:TaxInclusiveLineExtensionAmount` |

#### 4.4.4 外币发票配套的 UBL 标准字段（非扩展）

外币发票除扩展标签外，还需在 UBL body 中添加：

```xml
<!-- ① 计税货币代码 -->
<cbc:TaxCurrencyCode>HUF</cbc:TaxCurrencyCode>

<!-- ② 汇率 -->
<cac:TaxExchangeRate>
    <cbc:SourceCurrencyCode>EUR</cbc:SourceCurrencyCode>
    <cbc:TargetCurrencyCode>HUF</cbc:TargetCurrencyCode>
    <cbc:CalculationRate>361.67</cbc:CalculationRate>
    <cbc:MathematicOperatorCode>Multiply</cbc:MathematicOperatorCode>
    <cbc:Date>2026-01-21</cbc:Date>
</cac:TaxExchangeRate>

<!-- ③ 双 TaxTotal：第一个用开票货币（含 TaxSubtotal），第二个用计税货币（仅总额） -->
<cac:TaxTotal>
    <cbc:TaxAmount currencyID="EUR">67.50</cbc:TaxAmount>
    <cac:TaxSubtotal>...</cac:TaxSubtotal>
</cac:TaxTotal>
<cac:TaxTotal>
    <cbc:TaxAmount currencyID="HUF">24412.73</cbc:TaxAmount>
</cac:TaxTotal>
```

---

### 4.5 HU 买方 Party 字段规范（所有 HU 文件）

匈牙利买方使用两个特殊 `schemeID`，与其他国家不同：

```xml
<cac:AccountingCustomerParty>
    <cac:Party>
        <cac:PartyIdentification>
            <!-- 集团成员税号 -->
            <cbc:ID schemeID="HU:GroupMemberTaxpayerId">23545565414</cbc:ID>
        </cac:PartyIdentification>
        <cac:PartyLegalEntity>
            <cbc:RegistrationName>Buyer name</cbc:RegistrationName>
            <!-- 主纳税人号 -->
            <cbc:CompanyID schemeID="HU:TaxpayerId">23544565214</cbc:CompanyID>
        </cac:PartyLegalEntity>
    </cac:Party>
</cac:AccountingCustomerParty>
```

| 字段路径 | schemeID | 含义 |
|---------|----------|------|
| `PartyIdentification/ID` | `HU:GroupMemberTaxpayerId` | 集团成员税号，识别买方所属集团中的具体成员 |
| `PartyLegalEntity/CompanyID` | `HU:TaxpayerId` | 主纳税人号，买方在匈牙利税务局的主税号 |
