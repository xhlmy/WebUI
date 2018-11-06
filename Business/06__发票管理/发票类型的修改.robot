*** Settings ***
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          Resources/common.robot
Library           Selenium2Library

*** Test Cases ***
发票信息处修改发票默认类型
    [Tags]    invoice
    Given 采购商已设置并确认发票类型为专票
    When 采购商在发票信息处修改发票类型为普票
    Then 采购商在提交订单可看到修改后的发票类型
    [Teardown]    Close Browsers

*** Keywords ***
采购商在发票信息处修改发票类型为普票
    Execute Javascript    window.open("${PUR_URL}/Member/Tax")
    Select Window    url=${PUR_URL}/Member/Tax
    采购商进入发票信息界面
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    //div[@class="y_oneTaxContent"]/dl[5]/dt/span[2]    10s    不在增值税专用发票界面
    Run Keyword If    '${status}'=='True'    普票和专票的切换
    Wait Until Element Is Not Visible    //div[@class="y_oneTaxContent"]/dl[5]/dt/span[2]    ${WAIT_TIMEOUT}    未切换到普票页面
    ${status1}=    Execute Javascript    return $('#y_taxTypeDefault').is(':checked')
    Run Keyword If    '${status1}'=='False'    设置默认开票类型
    Reload Page
    Wait Until Element Is Not Visible    //span[text()='纳税人识别码:']    ${WAIT_TIMEOUT}    设置发票为普票，设置失败

采购商在提交订单可看到修改后的发票类型
    Select Window    title=核对订单-药品终端网
    Reload Page
    检查提交订单页面发票类型    增值税普通发票

检查提交订单页面发票类型
    [Arguments]    ${invoice}
    Wait Until Element Contains    //span[@name="taxType"]    ${invoice}

采购商已设置并确认发票类型为专票
    采购商已设置默认发票类型
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}
    Buyer Joined Cart From Search Reasult Page    ${SEARCH_GOOD_ID}
    Buyer Confirm Order
    检查提交订单页面发票类型    增值税专用发票
