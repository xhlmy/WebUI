*** Settings ***
Suite Teardown
Test Teardown
Force Tags
Resource          Resources/common.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}支付${/}交易风控${/}支付跟踪${/}money_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}物流${/}logistics_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}购物车${/}cart_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}支付${/}支付工具${/}pay_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot

*** Variables ***

*** Test Cases ***
Complet An Order Flow Contains Coupon
    [Documentation]    优惠券使用的订单流程:
    ...    流程：供应商登录->发优惠券->采购商登录->搜索商品->将商品加入购物车->购物车页面领取优惠券->提交订单使用优惠券->供应商改价->完成支付->供应商出库发起退差->采购商确认收货发起冲红->供应商确认冲红->交易完成->双方评价
    ...    规则：1.领券后验证券的数量；
    ...    \ \ \ \ \ 2.使用优惠券后验证金额正确；
    ...    \ \ \ \ 3.使用优惠券的订单不能进行改价，仅可修改邮费；
    ...    \ \ \ 4.产生退差冲红后，金额变化;
    [Tags]    stage
    Given Buyer And Saler Are Already Logined Certified User
    When Saler Publishes A Coupon
    And Buyer Gets The Coupon From Cart
    And Buyer Creates An Order Using Coupon And Payed
    And Saler Sents Out Partial Goods
    And Buyer Receipts Partial Goods
    And Saler Confirms The Unreceipted Goods
    Then The Order Was Completed
    [Teardown]    Close Browsers

ToDo Check Coupons Conditions Of Use
    Comment    金额不满足时不可用优惠券
    Comment    优惠券不包含的商品不可使用

ToDo Publish A Coupon To A Special User
    Comment    定向发放

*** Keywords ***
Buyer Searched Goods
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}
    从搜索结果页面获取商品价格    ${SEARCH_GOOD_ID}    #获取单价以供后面金额验证

Buyer Payed The Order
    Get Account Balance From Pur Page    #支付订单前获取账户余额
    Buyer Pay Order
    Check Account Balance After Payed    #验证支付后账户余额的变化

Buyer Creates An Order Using Coupon And Payed
    Use Coupon In Confirm Order Page
    提交订单并冻结库存
    Saler Can Not Sale Off
    Buyer Payed The Order

Buyer Gets The Coupon From Cart
    Buyer Searched Goods
    Buyer Joined Cart From Search Reasult Page    ${SEARCH_GOOD_ID}
    Get Coupon From Cart

Buyer And Saler Are Already Logined Certified User
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Ensure The Cart Is Empty
    Saler Logined Successfully

Use Coupon In Confirm Order Page
    Buyer Confirm Order
    Buyer Used A Coupon
    Get The Discount Money
    Get The Postage

Saler Sents Out Partial Goods
    Saler Confirm Order
    Out Cargo
    Comment    Registration Logistics Information
