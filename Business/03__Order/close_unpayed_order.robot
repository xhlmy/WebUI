*** Settings ***
Suite Teardown
Resource          ../../Resources/coupon.robot
Resource          Resources/common.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}inventory_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}购物车${/}cart_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}订单${/}order_web.robot

*** Test Cases ***
Buyer Closes Order
    [Documentation]    采购商关闭订单：
    ...    流程：采购商下单未支付->采购商关闭订单
    ...    规则：1.下单后商品实际库存减少,冻结库存增加；
    ...    \ \ \ \ \ 2.关闭订单后商品实际库存增加,冻结库存减少。
    [Tags]    prod
    Given 买家登录并清空购物车
    When Buyer Created An Order
    And Buyer Closes Order
    Then The Order Has Been Closed
    [Teardown]    Close Browsers

Manager Closed An Unpayed Order
    [Documentation]    运营平台关闭订单
    ...    流程：采购商下单未支付->运营平台关闭订单
    ...    规则：1.下单后商品实际库存减少,冻结库存增加；
    ...    \ \ \ \ \ 2.关闭订单后商品实际库存增加,冻结库存减少。
    [Tags]
    Given 买家登录并清空购物车
    When Buyer Created An Order
    And Manager Closes The Order
    Then The Order Has Been Closed
    [Teardown]    Close Browsers

*** Keywords ***
Buyer Created An Order
    从商品详情页将商品加入购物车
    Go To    ${CART_URL}/cart/index
    Buyer Confirm Order
    Do Not Use The Coupon
    提交订单并冻结库存

Buyer Searched Good
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}

Buyer Confirmed Messages From Confirm Order Page
    Buyer Confirm Order
    Do Not Use The Coupon

The Order Has Been Closed
    Check Order Status    已关闭订单
    Check Inventory After closed Order

Manager Closes The Order
    Manager Logined Successfully
    Manager Closes An Order
