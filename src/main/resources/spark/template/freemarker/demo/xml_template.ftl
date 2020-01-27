    <Inputs>
<#list io as var>
<#if var.iotype?? && var.iotype != "O" && var.iotype != "">
        <Input name="${var.name!}" description="${var.description!}" datatype="${var.datatype!}" <#if var.len?? && var.len != "">len="${var.len}" </#if><#if var.min?? && var.min != "">min="${var.min}" </#if><#if var.max?? && var.max != "">max="${var.max}" </#if><#if var.default?? && var.default != "">default="${var.default}" </#if> unit="${var.unit!}" inputtype="${var.inputtype!}" <#if var.variablecategory?? && var.variablecategory != "">variablecategory="${var.variablecategory}" </#if><#if var.parametercategory?? && var.parametercategory != "">parametercategory="${var.parametercategory}" </#if><#if var.uri?? && var.uri != "">uri="${var.uri}" </#if>/>
</#if>
</#list>
    </Inputs>
    <Outputs>
<#list io as var>
<#if var.iotype?? && var.iotype != "I" && var.iotype != "">
        <Output name="${var.name!}" description="${var.description!}" datatype="${var.datatype!}" <#if var.len?? && var.len != "">len="${var.len}" </#if> <#if var.min?? && var.min != "">min="${var.min}" </#if><#if var.max?? && var.max != "">max="${var.max}" </#if> unit="${var.unit!}" <#if var.variablecategory?? && var.variablecategory != "">variablecategory="${var.variablecategory}" </#if><#if var.uri??>uri="${var.uri}" </#if>/>
</#if>
</#list>
    </Outputs>
            <Test name ="test1">
<#list io as var>
<#if var.iotype?? && var.iotype != "O" && var.iotype != "">
                <InputValue name="${var.name!}"><#if var.default?? && var.default != "">${var.default!}<#elseif var.datatype?? && (var.datatype?contains("ARRAY") || var.datatype?contains("LIST"))>[]<#else>0</#if></InputValue>
</#if>
</#list>
<#list io as var>
<#if var.iotype?? && var.iotype != "I" && var.iotype != "">
                <OutputValue name="${var.name!}" precision ="3"><#if var.default?? && var.default != "">${var.default!}<#elseif var.datatype?? && (var.datatype?contains("ARRAY") || var.datatype?contains("LIST"))>[]<#else>0</#if></OutputValue>
</#if>
</#list>
            </Test>