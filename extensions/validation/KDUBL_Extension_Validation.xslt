<?xml version="1.0" encoding="UTF-8"?>
<!--
    ============================================================
    KDUBL PiaozoneExtension 业务规则校验样式表
    版本    : 1.0
    适用    : 包含 kdubl:PiaozoneExtension 扩展的 UBL 2.1 Invoice
    输出    : XML 格式的校验报告（包含通过/错误/警告）
    用法    :
        java -jar saxon.jar -s:your_invoice.xml \
             -xsl:KDUBL_Extension_Validation.xslt \
             -o:validation_report.xml
    规则列表 :
        KDUBL-EXT-001  LineID 不能为空
        KDUBL-EXT-002  LineID 在 LineExtensions 内必须唯一
        KDUBL-EXT-003  TaxIndex 在同一 TaxExtensions 内必须唯一
        KDUBL-EXT-004  InternalTaxCode 不能为空
        KDUBL-EXT-005  金额字段必须携带 @currencyID 属性
                       （涵盖 OriginalAmount / DifferenceAmount /
                        TaxInclusiveLineExtensionAmount /
                        TaxCurrencyTaxInclusiveLineExtensionAmount /
                        TaxCurrencyLineExtensionAmount /
                        TaxInclusiveAmount）
        KDUBL-EXT-006  TaxInclusiveLineExtensionAmount 必须 >= 0
        KDUBL-EXT-007  OriginalAmount/DifferenceAmount 出现时
                       DocumentIssuanceReasonCode 必须同时存在
        KDUBL-EXT-008  DocumentIssuanceReasonCode 不能为空字符串
        KDUBL-EXT-009  SubInvoiceTypeCode 不能为空字符串（出现时）
        KDUBL-EXT-010  InvoiceAppearance 不能为空字符串（出现时）
        KDUBL-EXT-011  CustomerVatStatus 不能为空字符串（出现时）
        KDUBL-EXT-012  ModificationIndex 出现时必须为正整数（> 0）
        KDUBL-EXT-013  AdvanceOriginalInvoice 不能为空字符串（出现时）
    ============================================================
-->
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:kdubl="urn:piaozone:ExtensionComponent:1.0"
    xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
    exclude-result-prefixes="kdubl cac cbc ext">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- ============================================================
         入口：生成校验报告根节点
         ============================================================ -->
    <xsl:template match="/">
        <ValidationReport
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            timestamp="{current-dateTime()}">

            <!-- 被校验文档的基本信息 -->
            <Document>
                <InvoiceID>
                    <xsl:value-of select="//*[local-name()='ID'][1]"/>
                </InvoiceID>
                <ExtensionAgencyName>
                    <xsl:value-of select="//ext:UBLExtension/ext:ExtensionAgencyName"/>
                </ExtensionAgencyName>
            </Document>

            <!-- 执行所有校验规则，收集结果 -->
            <Rules>
                <xsl:call-template name="rule-EXT-001"/>
                <xsl:call-template name="rule-EXT-002"/>
                <xsl:call-template name="rule-EXT-003"/>
                <xsl:call-template name="rule-EXT-004"/>
                <xsl:call-template name="rule-EXT-005"/>
                <xsl:call-template name="rule-EXT-006"/>
                <xsl:call-template name="rule-EXT-007"/>
                <xsl:call-template name="rule-EXT-008"/>
                <xsl:call-template name="rule-EXT-009"/>
                <xsl:call-template name="rule-EXT-010"/>
                <xsl:call-template name="rule-EXT-011"/>
                <xsl:call-template name="rule-EXT-012"/>
                <xsl:call-template name="rule-EXT-013"/>
            </Rules>

            <!-- 汇总统计 -->
            <xsl:variable name="errors"
                select="count(//RuleResult[@status='ERROR'])"/>
            <xsl:variable name="warnings"
                select="count(//RuleResult[@status='WARNING'])"/>
            <Summary>
                <TotalRules>13</TotalRules>
                <Errors><xsl:value-of select="$errors"/></Errors>
                <Warnings><xsl:value-of select="$warnings"/></Warnings>
                <xsl:choose>
                    <xsl:when test="$errors > 0">
                        <OverallResult>FAILED</OverallResult>
                    </xsl:when>
                    <xsl:otherwise>
                        <OverallResult>PASSED</OverallResult>
                    </xsl:otherwise>
                </xsl:choose>
            </Summary>
        </ValidationReport>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-001
         规则  : LineExtension/LineID 必须存在且不为空
         级别  : ERROR
         说明  : LineID 是行扩展与 InvoiceLine 关联的唯一依据，
                 缺失将导致行级扩展数据无法定位到对应发票行。
         ============================================================ -->
    <xsl:template name="rule-EXT-001">
        <xsl:variable name="violations"
            select="//kdubl:LineExtension[not(kdubl:LineID) or normalize-space(kdubl:LineID) = '']"/>
        <RuleResult id="KDUBL-EXT-001" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>LineExtension/LineID 必须存在且不为空</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:LineExtensions/kdubl:LineExtension[<xsl:value-of select="position()"/>]</Location>
                            <Message>LineID 缺失或为空，无法关联到对应的 UBL InvoiceLine</Message>
                            <Fix>补充 &lt;kdubl:LineID&gt; 值，确保与对应 InvoiceLine/ID 一致</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-002
         规则  : 同一 LineExtensions 内，LineID 必须唯一
         级别  : ERROR
         说明  : 重复的 LineID 会造成行扩展与发票行的映射歧义，
                 导致税务计算结果不可预期。
         ============================================================ -->
    <xsl:template name="rule-EXT-002">
        <xsl:variable name="duplicates"
            select="//kdubl:LineExtensions/kdubl:LineExtension
                    [kdubl:LineID = preceding-sibling::kdubl:LineExtension/kdubl:LineID]"/>
        <RuleResult id="KDUBL-EXT-002" status="{if (count($duplicates) = 0) then 'PASSED' else 'ERROR'}">
            <Description>同一 LineExtensions 内 LineID 必须唯一</Description>
            <xsl:if test="count($duplicates) > 0">
                <Failures>
                    <xsl:for-each select="$duplicates">
                        <Failure>
                            <Location>kdubl:LineExtensions/kdubl:LineExtension/kdubl:LineID</Location>
                            <Message>重复的 LineID 值：<xsl:value-of select="kdubl:LineID"/></Message>
                            <Fix>确保每个 LineExtension 的 LineID 在文档内唯一</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-003
         规则  : 同一 TaxExtensions 内，TaxIndex 必须唯一
         级别  : ERROR
         说明  : TaxIndex 标识该税务扩展对应行内 TaxSubtotal 的位置，
                 重复会导致税码映射冲突。
         ============================================================ -->
    <xsl:template name="rule-EXT-003">
        <xsl:variable name="duplicates"
            select="//kdubl:TaxExtensions/kdubl:TaxExtension
                    [kdubl:TaxIndex = preceding-sibling::kdubl:TaxExtension/kdubl:TaxIndex]"/>
        <RuleResult id="KDUBL-EXT-003" status="{if (count($duplicates) = 0) then 'PASSED' else 'ERROR'}">
            <Description>同一 TaxExtensions 内 TaxIndex 必须唯一</Description>
            <xsl:if test="count($duplicates) > 0">
                <Failures>
                    <xsl:for-each select="$duplicates">
                        <Failure>
                            <Location>kdubl:TaxExtensions/kdubl:TaxExtension/kdubl:TaxIndex</Location>
                            <Message>重复的 TaxIndex 值：<xsl:value-of select="kdubl:TaxIndex"/>（所属行 LineID: <xsl:value-of select="ancestor::kdubl:LineExtension/kdubl:LineID"/>）</Message>
                            <Fix>确保同一行内每个 TaxExtension 的 TaxIndex 不重复，从 1 连续递增</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-004
         规则  : TaxExtension/InternalTaxCode 不能为空
         级别  : ERROR
         说明  : InternalTaxCode 是税务引擎识别适用税率的关键字段，
                 空值会导致税额计算失败。
         ============================================================ -->
    <xsl:template name="rule-EXT-004">
        <xsl:variable name="violations"
            select="//kdubl:TaxExtension[normalize-space(kdubl:InternalTaxCode) = '']"/>
        <RuleResult id="KDUBL-EXT-004" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>TaxExtension/InternalTaxCode 不能为空</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:TaxExtension（所属行 LineID: <xsl:value-of select="ancestor::kdubl:LineExtension/kdubl:LineID"/>，TaxIndex: <xsl:value-of select="kdubl:TaxIndex"/>）</Location>
                            <Message>InternalTaxCode 为空，无法识别税率类型</Message>
                            <Fix>填写有效的内部税码，例如：SA_VAT_S（标准税率）、SA_VAT_E（豁免）</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-005
         规则  : 所有金额字段必须携带 @currencyID 属性：
                 OriginalAmount、DifferenceAmount、
                 TaxInclusiveLineExtensionAmount、
                 TaxCurrencyTaxInclusiveLineExtensionAmount、
                 TaxCurrencyLineExtensionAmount、TaxInclusiveAmount
         级别  : ERROR
         说明  : 缺少货币代码的金额在多币种场景下无法正确换算。
         ============================================================ -->
    <xsl:template name="rule-EXT-005">
        <xsl:variable name="violations" select="
            //kdubl:OriginalAmount[not(@currencyID) or normalize-space(@currencyID) = ''] |
            //kdubl:DifferenceAmount[not(@currencyID) or normalize-space(@currencyID) = ''] |
            //kdubl:TaxInclusiveLineExtensionAmount[not(@currencyID) or normalize-space(@currencyID) = ''] |
            //kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount[not(@currencyID) or normalize-space(@currencyID) = ''] |
            //kdubl:TaxCurrencyLineExtensionAmount[not(@currencyID) or normalize-space(@currencyID) = ''] |
            //kdubl:TaxInclusiveAmount[not(@currencyID) or normalize-space(@currencyID) = '']
        "/>
        <RuleResult id="KDUBL-EXT-005" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>金额字段必须携带 @currencyID（ISO 4217 货币代码）</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location><xsl:value-of select="local-name()"/>（值：<xsl:value-of select="."/>）</Location>
                            <Message>缺少 currencyID 属性</Message>
                            <Fix>添加 currencyID 属性，例如：currencyID="CNY"</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-006
         规则  : TaxInclusiveLineExtensionAmount 的值必须 >= 0
         级别  : ERROR
         说明  : 含税行金额为负数在业务逻辑上无意义，
                 如需表达负向调整应使用 Credit Note 文档类型。
         ============================================================ -->
    <xsl:template name="rule-EXT-006">
        <xsl:variable name="violations"
            select="//kdubl:TaxInclusiveLineExtensionAmount[number(.) &lt; 0]"/>
        <RuleResult id="KDUBL-EXT-006" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>TaxInclusiveLineExtensionAmount 必须 >= 0</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:LineExtension（LineID: <xsl:value-of select="../kdubl:LineID"/>）/TaxInclusiveLineExtensionAmount</Location>
                            <Message>含税行金额为负数：<xsl:value-of select="."/></Message>
                            <Fix>含税行金额不能为负，负向调整应使用独立的 Credit Note 文档</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-007
         规则  : OriginalAmount 或 DifferenceAmount 出现时，
                 DocumentIssuanceReasonCode 必须同时存在且不为空
         级别  : ERROR
         说明  : 金额调整必须有对应的原因码，否则税务机关无法审核。
         ============================================================ -->
    <xsl:template name="rule-EXT-007">
        <xsl:variable name="violations"
            select="//kdubl:InvoiceDocumentReference
                    [(kdubl:OriginalAmount or kdubl:DifferenceAmount)
                     and (not(kdubl:DocumentIssuanceReasonCode)
                          or normalize-space(kdubl:DocumentIssuanceReasonCode) = '')]"/>
        <RuleResult id="KDUBL-EXT-007" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>存在 OriginalAmount 或 DifferenceAmount 时，DocumentIssuanceReasonCode 必须填写</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:InvoiceDocumentReference</Location>
                            <Message>包含金额调整字段（OriginalAmount/DifferenceAmount）但缺少 DocumentIssuanceReasonCode</Message>
                            <Fix>补充 &lt;kdubl:DocumentIssuanceReasonCode&gt;，填写符合税务规范的原因码</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-008
         规则  : DocumentIssuanceReasonCode 出现时不能为空字符串
         级别  : ERROR
         说明  : 空的原因码等同于未填写，不符合税务申报要求。
         ============================================================ -->
    <xsl:template name="rule-EXT-008">
        <xsl:variable name="violations"
            select="//kdubl:DocumentIssuanceReasonCode[normalize-space(.) = '']"/>
        <RuleResult id="KDUBL-EXT-008" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>DocumentIssuanceReasonCode 不能为空字符串</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:InvoiceDocumentReference/kdubl:DocumentIssuanceReasonCode</Location>
                            <Message>DocumentIssuanceReasonCode 标签存在但值为空</Message>
                            <Fix>填写有效的原因码，或删除空标签</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-009
         规则  : SubInvoiceTypeCode 出现时不能为空字符串
         级别  : WARNING
         说明  : 空的子发票类型码会造成接收方系统无法识别具体凭证类型，
                 建议检查是否为数据录入问题。
         ============================================================ -->
    <xsl:template name="rule-EXT-009">
        <xsl:variable name="violations"
            select="//kdubl:SubInvoiceTypeCode[normalize-space(.) = '']"/>
        <RuleResult id="KDUBL-EXT-009" status="{if (count($violations) = 0) then 'PASSED' else 'WARNING'}">
            <Description>SubInvoiceTypeCode 出现时不应为空字符串</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:InvoiceDocumentReference/kdubl:SubInvoiceTypeCode</Location>
                            <Message>SubInvoiceTypeCode 标签存在但值为空</Message>
                            <Fix>填写有效的子发票类型码，或删除空标签</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-010
         规则  : InvoiceAppearance 出现时不能为空字符串
         级别  : ERROR
         说明  : 空的呈现方式码等同于未填写，HU RTIR 无法识别分发方式。
         ============================================================ -->
    <xsl:template name="rule-EXT-010">
        <xsl:variable name="violations"
            select="//kdubl:InvoiceAppearance[normalize-space(.) = '']"/>
        <RuleResult id="KDUBL-EXT-010" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>InvoiceAppearance 出现时不能为空字符串</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:PiaozoneExtension/kdubl:InvoiceAppearance</Location>
                            <Message>InvoiceAppearance 标签存在但值为空</Message>
                            <Fix>填写有效值，例如：ELECTRONIC 或 PAPER</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-011
         规则  : CustomerVatStatus 出现时不能为空字符串
         级别  : ERROR
         说明  : 空的买方增值税状态码会导致 HU RTIR 校验规则无法匹配。
         ============================================================ -->
    <xsl:template name="rule-EXT-011">
        <xsl:variable name="violations"
            select="//kdubl:CustomerVatStatus[normalize-space(.) = '']"/>
        <RuleResult id="KDUBL-EXT-011" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>CustomerVatStatus 出现时不能为空字符串</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:PiaozoneExtension/kdubl:CustomerVatStatus</Location>
                            <Message>CustomerVatStatus 标签存在但值为空</Message>
                            <Fix>填写有效值，例如：DOMESTIC 或 OTHER</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-012
         规则  : ModificationIndex 出现时必须为正整数（>= 1）
         级别  : ERROR
         说明  : 改票序号为 0 或负数在 HU RTIR 中无意义，
                 且与"从 1 开始递增"的规则冲突。
         ============================================================ -->
    <xsl:template name="rule-EXT-012">
        <xsl:variable name="violations"
            select="//kdubl:ModificationIndex[not(string(.) castable as xs:integer) or xs:integer(.) &lt; 1]"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
        <RuleResult id="KDUBL-EXT-012" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>ModificationIndex 出现时必须为正整数（>= 1）</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:PiaozoneExtension/kdubl:ModificationIndex</Location>
                            <Message>ModificationIndex 值无效：<xsl:value-of select="."/>（应为 >= 1 的整数）</Message>
                            <Fix>填写从 1 开始的正整数，同一原始发票每次改票递增</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

    <!-- ============================================================
         KDUBL-EXT-013
         规则  : AdvanceOriginalInvoice 出现时不能为空字符串
         级别  : ERROR
         说明  : 空的原始预付款发票号无法追溯预付款来源，
                 HU RTIR 系统将无法匹配原始预付款记录。
         ============================================================ -->
    <xsl:template name="rule-EXT-013">
        <xsl:variable name="violations"
            select="//kdubl:AdvanceOriginalInvoice[normalize-space(.) = '']"/>
        <RuleResult id="KDUBL-EXT-013" status="{if (count($violations) = 0) then 'PASSED' else 'ERROR'}">
            <Description>AdvanceOriginalInvoice 出现时不能为空字符串</Description>
            <xsl:if test="count($violations) > 0">
                <Failures>
                    <xsl:for-each select="$violations">
                        <Failure>
                            <Location>kdubl:AdvancePayment/kdubl:AdvanceOriginalInvoice（所属行 LineID: <xsl:value-of select="ancestor::kdubl:LineExtension/kdubl:LineID"/>）</Location>
                            <Message>AdvanceOriginalInvoice 标签存在但值为空</Message>
                            <Fix>填写原始预付款发票的发票号，确保可追溯预付款来源</Fix>
                        </Failure>
                    </xsl:for-each>
                </Failures>
            </xsl:if>
        </RuleResult>
    </xsl:template>

</xsl:stylesheet>
