## 葡萄牙 (PT) 专用扩展

葡萄牙电子发票的 KDUBL 扩展设计。测试文件位于 `examples/country/PT/`。

葡萄牙由税务及海关总署（AT，Autoridade Tributária e Aduaneira）监管，采用认证软件模式：
发票由 AT 认证的开票软件生成 ATCUD（单据唯一编码）、RSA 签名与 QR 码。KDUBL 侧只需携带
业务数据与**外币折算金额**，ATCUD/QR/签名由认证软件生成，不在 KDUBL 中传递。

---

### 1. 扩展字段总览

| # | 字段 | 承载机制 | 必填性 | 状态 |
|---|------|---------|--------|------|
| 1 | 计税货币不含税总额 | `cac:AdditionalDocumentReference`（`DocumentType=TaxCurrency-ExclusiveAmount`） | CM（外币必填） | 复用 SG/ES 既有 ADR |
| 2 | 计税货币含税总额 | `cac:AdditionalDocumentReference`（`DocumentType=TaxCurrency-TaxInclusiveAmount`） | CM（外币必填） | 复用 SG/ES 既有 ADR |
| 3 | 计税货币行不含税金额 | `kdubl:LineExtension/kdubl:TaxCurrencyLineExtensionAmount` | CM（外币必填） | 复用 HU 双币种扩展 |
| 4 | 计税货币行含税金额 | `kdubl:LineExtension/kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount` | CM（外币必填） | 复用 HU 双币种扩展 |
| 5 | **计税货币行单价** | `kdubl:LineExtension/kdubl:TaxCurrencyPriceAmount` | CM（外币必填） | **新增** |
| 6 | 计税货币代码 | `cbc:TaxCurrencyCode` | CM（外币必填） | 标准字段 |
| 7 | 汇率 | `cac:TaxExchangeRate/cbc:CalculationRate` | CM（外币必填） | 标准字段 |
| 8 | 业务场景码 | `cac:AdditionalDocumentReference`（`DocumentType=InvoiceContext`） | O | 复用通用 ADR |
| 9 | 商品编码 | `cac:Item/cac:SellersItemIdentification/cbc:ID` | M | 标准字段（PT 必填） |

> **M** = 必填；**CM** = 条件必填；**O** = 可选

---

### 2. 外币发票：AT 要求以 EUR 申报

AT 规定**法定单据必须以 EUR 申报**。发票以外币计价时会被拒收：

```
SDOC0398  For legal documents, the currency code must be EUR. Value specified USD.
```

此时发票同时存在两个货币口径：

```xml
<cbc:DocumentCurrencyCode>USD</cbc:DocumentCurrencyCode>   <!-- 发票计价货币 -->
<cbc:TaxCurrencyCode>EUR</cbc:TaxCurrencyCode>             <!-- AT 申报货币 -->
```

**折算后的 EUR 金额必须由业务侧提供**，通道侧不做换算。原因：通道内的舍入口径无法保证与
业务账一致，算错会开出一张金额有偏差的合规发票，比开不出来更糟。缺字段时通道显式失败。

#### 2.1 文档级：ADR 承载总额

沿用新加坡（BIS/PINT）、西班牙（SII）已在生产使用的约定，金额放在 `cbc:ID` 中：

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID>276.00</cbc:ID>
    <cbc:DocumentType>TaxCurrency-ExclusiveAmount</cbc:DocumentType>
</cac:AdditionalDocumentReference>
<cac:AdditionalDocumentReference>
    <cbc:ID>339.48</cbc:ID>
    <cbc:DocumentType>TaxCurrency-TaxInclusiveAmount</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

#### 2.2 行级：PiaozoneExtension 承载金额与单价

`kdubl:LineExtension` 通过 `kdubl:LineID` 与 `cac:InvoiceLine/cbc:ID` 关联：

```xml
<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:LineExtensions>
                    <kdubl:LineExtension>
                        <kdubl:LineID>1</kdubl:LineID>
                        <kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount currencyID="EUR">339.48</kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount>
                        <kdubl:TaxCurrencyLineExtensionAmount currencyID="EUR">276.00</kdubl:TaxCurrencyLineExtensionAmount>
                        <kdubl:TaxCurrencyPriceAmount currencyID="EUR">92.00</kdubl:TaxCurrencyPriceAmount>
                    </kdubl:LineExtension>
                </kdubl:LineExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

`kdubl:TaxCurrencyPriceAmount` 是 PT 新增字段，对应 `cac:Price/cbc:PriceAmount` 的计税货币版本。
此前 KDUBL 行级只定义了 net/gross **金额**，没有**单价**——而目标协议（如 eezi）行项目要求单价，
若由金额除数量得出，等于把计算放回通道，故新增此字段由业务侧直接给定。

**元素顺序**（计税货币金额归为一组，单价置于组末）：

```
kdubl:LineID
kdubl:TaxInclusiveLineExtensionAmount
kdubl:LineExpressionIndicator
[kdubl:AdvancePayment…]
kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount
kdubl:TaxCurrencyLineExtensionAmount
kdubl:TaxCurrencyPriceAmount            ← PT 新增
```

`ext:ExtensionContent` 在 UBL 中为 `xs:any`，**XSD 不强制扩展内部顺序**，上述次序为约定，
目的是让各国样例便于比对。

#### 2.3 两套计税货币机制并存

| | ADR 方式 | PiaozoneExtension 方式 |
|---|---|---|
| 载体 | `cac:AdditionalDocumentReference` | `kdubl:PiaozoneExtension` |
| 粒度 | 仅文档级总额 | 文档级 + 行级 |
| 使用国家 | SG、ES、**PT（文档级）** | HU、AE、**PT（行级）** |

PT 两套都用：文档级总额走 ADR（与 ES 同构），行级金额与单价走 PiaozoneExtension（与 HU 同构）。

---

### 3. VAT 税种码映射

KDUBL 使用 UNCL 5305 税类别码，葡萄牙侧映射：

| KDUBL `cbc:ID` | 税率 | PT 税种码 | 说明 |
|---|---|---|---|
| `S` | 23% | `PRT-NOR` | 标准税率（大陆） |
| `AA` | 13% | `PRT-INT` | 中间税率 |
| `AA` | 6% | `PRT-RED` | 低税率 |
| `E` / `Z` | 0% | `PRT-ISE` | 免税/零税率，须附 `cbc:TaxExemptionReason` 与 `cbc:TaxExemptionReasonCode` |
| `O` / `AE` | — | `PRT-NS` | 范围外 / 逆向征收 |

免税代码（`cbc:TaxExemptionReasonCode`）取 AT 的 `M01`–`M99` 值集，如 `M01`（CIVA 第 16 条第 6 款 a 项）、
`M04`（CIVA 第 13 条免税）、`M40`（IVA 自行清缴）。

---

### 4. 其他 PT 约定

| 项 | 要求 |
|---|---|
| NIF/NIPC | 9 位纯数字，`PartyTaxScheme/cbc:CompanyID`。不带 `PT` 前缀 |
| 消费者（consumidor final） | 无税号时 NIF 填 `999999990` |
| 商品编码 | `cac:SellersItemIdentification/cbc:ID` 必填 |
| 计量单位 | `cbc:InvoicedQuantity/@unitCode` 必填，UN/ECE Rec 20（如 `C62` 件、`KGM` 千克） |
| 邮编 | `cbc:PostalZone` 格式 `XXXX-YYY`；`cbc:CountrySubentity` 填邮政区域名（AT 侧的 ZipArea） |
| 单据日期顺序 | AT 要求同一序列内单据日期递增，不得回退，且不能是未来日期 |
| 简化发票 | 金额 < 1000 EUR 由认证软件自动按简化发票处理，KDUBL 无需标记 |

---

### 5. ATCUD / QR 码 / 签名 —— 不在 KDUBL 中传递

AT 要求发票携带 ATCUD、RSA-SHA1 签名与 QR 码，这三项由 **AT 认证软件生成**，KDUBL 不承载：

| 项 | 生成方 | 可得性 |
|---|---|---|
| ATCUD（如 `JJCJPPH4-000017`） | 认证软件 | 渲染在合规 PDF 上，API 不返回结构化值 |
| QR 码 | 认证软件 | PDF 上为图像，原文字符串不可得 |
| 签名哈希 | 认证软件 | PDF 页脚仅显示前 4 字符（QR 的 Q 字段） |
| 软件认证号 | 认证软件 | PDF 页脚，如 `Processado por programa certificado nº1835/AT` |

合规 PDF 为纯渲染件，**不内嵌 XML**（非 PDF/A-3 混合发票）。若业务需要结构化 ATCUD，
需向认证软件供应商确认是否提供对应接口——从 PDF 文本层反向解析不可靠，排版变更即失效。

---

### 6. 示例文件

`examples/country/PT/` 下 8 个样例：

| 文件 | 场景 |
|---|---|
| `KDUBL_Invoice_PT.xml` | 标准发票（S 23%） |
| `KDUBL_Invoice_PT_B2C.xml` | B2C 简化发票（消费者占位 NIF `999999990`） |
| `KDUBL_Invoice_PT_Exempt.xml` | 免税（E 0% + 免税理由码） |
| `KDUBL_Invoice_PT_ReducedRate.xml` | 低税率（AA 6% → `PRT-RED`） |
| `KDUBL_Invoice_PT_IntermediateRate.xml` | 中间税率（AA 13% → `PRT-INT`） |
| `KDUBL_Invoice_PT_MultiLine.xml` | 多行多税率 |
| `KDUBL_Invoice_PT_ForeignCurrency.xml` | **外币**（USD 计价 / EUR 申报，含本文第 2 节全部扩展） |
| `KDUBL_CreditNote_PT.xml` | 贷项票据（381，引用原发票） |
