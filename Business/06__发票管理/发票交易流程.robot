*** Settings ***
Resource          Resources/common.robot
Resource          ${RESOURCE_PATH}${/}Combine_service${/}交易域${/}物流${/}logistics_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}Combine_service${/}交易域${/}支付${/}支付工具${/}pay_web.robot
Resource          ${RESOURCE_PATH}${/}Combine_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}订单${/}order_web.robot

*** Test Cases ***
发票交易流程
    [Tags]    invoice
    Given 采购商已设置默认发票类型
    And 采购商创建有发票的订单
    When 供应商出库并开票
    Then 采购商确认收票
    And 供应商查看到采购商确认收票
    [Teardown]    Close Browsers

*** Keywords ***
采购商创建有发票的订单
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}
    Buyer Joined Cart From Search Reasult Page    ${SEARCH_GOOD_ID}
    Buyer Confirm Order
    Buyer Submits Order
    Buyer Pay Order
    Comment    采购商订单详情查看发票类型    增值税专用发票

供应商出库并开票
    Saler Logined Successfully
    Saler Confirm Order
    Out Cargo
    Registration Logistics Information
    供应商为采购商开票

采购商确认收票
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${PUR_URL}/Order/Tax
    Wait Until Element Is Visible    //input[@type="text"]    ${WAIT_TIMEOUT}
    Search Text    ${ORDERCODE}
    Wait Until Element Contains    //span[@class="label label-success"]    已开票    #确认发票状态为已开票
    Wait Until Element Is Visible    //a[text()='确认收票']    ${WAIT_TIMEOUT}
    Click Element    //a[text()='确认收票']
    Wait Until Element Contains    //span[@name="TaxCode"]    1234567890    #验证发票代码一致
    Wait Until Element Contains    //span[@name="TaxNumber"]    87654321    #验证发票号码一致
    Click Element    J_confirmBtn
    发票状态为已确认收票

采购商订单详情查看发票类型
    [Arguments]    ${invoice}
    Click Element    //a[@class="oper"]
    Wait Until Element Is Visible    //div[@id="taxInfo"]
    Wait Until Element Contains    //div[@id="taxInfo"]/p[1]/span    ${invoice}

供应商为采购商开票
    Go To    ${SALES_URL}/Order/Tax/Index
    Wait Until Element Is Visible    //input[@type="text"]    ${WAIT_TIMEOUT}
    Search Text    ${CUSTOMER_NAME}
    Wait Until Element Is Visible    //a[@class="oper c-blue"]
    Click Element    //a[@class="oper c-blue"]
    Search Text    ${ORDERCODE}
    Wait Until Element Is Visible    //a[@class="oper c-blue detailBtn"]    ${WAIT_TIMEOUT}
    Click Element    //a[@class="oper c-blue detailBtn"]
    Wait Until Element Is Visible    //input[@class="form-control dillCodeInp"]    ${WAIT_TIMEOUT}
    Input Text    //input[@class="form-control dillCodeInp"]    1234567890
    Input Text    //input[@class="form-control dillNoInp"]    87654321
    Click Element    submitBtn

供应商查看到采购商确认收票
    Switch Browser    ${SALER_BROWSER}
    Wait Until Element Is Visible    //select[@name="status"]    ${WAIT_TIMEOUT}    特价活动界面未显示
    Select From List By Value    //select[@name="status"]    0    #选择特价活动状态
    Search Text    ${ORDERCODE}
    发票状态为已确认收票

发票状态为已确认收票
    Wait Until Keyword Succeeds    20s    1s    Wait Until Element Contains    //span[@class="label label-success"]    已确认收票
