*** Settings ***
Suite Teardown
Resource          ../../Resources/coupon.robot
Resource          ../../Resources/money.robot
Resource          ../../Resources/inventory.robot
Resource          Resources/common.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}支付${/}交易风控${/}支付跟踪${/}money_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}inventory_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}购物车${/}cart_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}支付${/}支付工具${/}pay_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot

*** Test Cases ***
Saler Closed An Order
    [Documentation]    供应商关闭订单：
    ...    流程：采购商下单并支付->供应商关闭订单
    ...    规则：1.下单后商品实际库存减少,冻结库存增加；
    ...    \ \ \ \ 2.关闭订单后商品实际库存增加,冻结库存减少；
    ...    \ \ \ \ 3.关闭订单后交易金额退还至账户余额。
    [Tags]
    Given 买家登录并清空购物车
    When Buyer Created An Order And Payed
    And Saler Closes The Order
    Then The Order Has Been Closed
    [Teardown]    Close Browsers

Manager Closed A payed Order
    [Documentation]    后台关闭订单：
    ...    流程：采购商下单并支付->后台关闭订单
    ...    规则：1.下单后商品实际库存减少,冻结库存增加；
    ...    \ \ \ \ 2.关闭订单后商品实际库存增加,冻结库存减少；
    ...    \ \ \ \ 3.关闭订单后交易金额退还至账户余额。
    Given 买家登录并清空购物车
    When Buyer Created An Order And Payed
    And Manager Closes The Order
    Then The Order Has Been Closed
    [Teardown]    Close Browsers

*** Keywords ***
The Order Has Been Closed
    Check Order Status    已关闭
    Check Inventory After closed Order    #关闭订单之后验证库存变化
    Check Account Balance After Closed    #验证关闭订单后账户余额的变化

Buyer Searched Good
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}
    从搜索结果页面获取商品价格    ${SEARCH_GOOD_ID}

Buyer Confirmed Messages From Confirm Order Page
    Buyer Confirm Order
    Do Not Use The Coupon
    Get The Discount Money
    Get The Postage

Buyer Created An Order Successfully
    Get The Inventory Messages
    Buyer Submits Order
    Check The Inventory Blocked    #验证提交订单后库存的变化

Buyer Payed The Order
    Get Account Balance From Pur Page    #支付订单前获取账户余额
    Buyer Pay Order
    Check Account Balance After Payed    #验证支付后账户余额的变化

Saler Closes The Order
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Order/Order/Index
    Search Text    ${ORDERCODE}
    Wait Until Element Contains    //table/tbody/tr/td/a    ${ORDERCODE}
    Click Element    //a[@onclick="order.close('${ORDERCODE}')"]
    Wait Until Element Is Visible    //input[@value="买家要求关闭订单"]
    Click Element    //input[@value="买家要求关闭订单"]
    Click Element    //button[@name="submit"]
    Wait Until Element Is Visible    //span[text()="已关闭"]    ${WAIT_TIMEOUT}    供应商关闭订单失败

Manager Closes The Order
    Manager Logined Successfully
    Manager Closes An Order

Buyer Created An Order And Payed
    Buyer Searched Good
    Buyer Joined Cart From Search Reasult Page    ${SEARCH_GOOD_ID}
    Buyer Confirmed Messages From Confirm Order Page
    Buyer Created An Order Successfully
    Buyer Payed The Order
