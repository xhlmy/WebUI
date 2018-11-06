*** Settings ***
Suite Teardown
Test Teardown
Resource          Resources/common.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}购物车${/}cart_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}订单${/}order_web.robot

*** Test Cases ***
Buyer Closed An Order Contains Coupon
    [Documentation]    优惠券使用的订单流程含关闭
    ...    流程：供应商登录->发优惠券->采购商登录->搜索商品->将商品加入购物车->购物车页面领取优惠券->提交订单使用优惠券->关闭订单
    ...    规则：1.领券后验证券的数量
    ...    \ \ \ \ \ 2.使用优惠券后验证金额正确
    ...    \ \ \ \ 3.关闭订单后优惠券退回
    [Tags]    prod    stage
    Given Saler Publishes A Coupon
    When Buyer Gets The Coupon From Cart
    And Buyer Creates An Order Using Coupon
    And Buyer Closes Order
    Then The Used Coupon Was Back
    [Teardown]    Close Browsers

*** Keywords ***
Buyer Gets The Coupon From Cart
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Ensure The Cart Is Empty
    从商品详情页将商品加入购物车
    Get Coupon From Cart

Buyer Searched Goods
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}

The Used Coupon Was Back
    Go To    ${PUR_URL}/Main/Home
    Wait Until Element Is Visible    //div[@class="right-module"]/p[2]
    ${text}    Get Text    //div[@class="right-module"]/p[2]
    @{number}    Get Regexp Matches    ${text}    优惠券：(.*) 查看我的优惠券 >>    1
    ${couponNumberNew}    Convert To String    @{number}[0]
    ${differce}    Evaluate    ${couponNumberNew}-${COUPON_NUMBER_USED}
    Should Be Equal As Strings    ${differce}    1

Buyer Creates An Order Using Coupon
    Use Coupon In Confirm Order Page
    提交订单并验证优惠券的使用情况

Use Coupon In Confirm Order Page
    Buyer Confirm Order
    Buyer Used A Coupon

提交订单并验证优惠券的使用情况
    Buyer Submits Order
    Check Coupon Number After Used    #使用优惠券后验证券数量变化
