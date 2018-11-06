*** Settings ***
Suite Teardown
Resource          Resources/common.robot
Resource          ../../Resources/coupon.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}物流${/}logistics_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}订单${/}order_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}支付${/}交易风控${/}支付跟踪${/}money_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}inventory_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}商品${/}inventory_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}购物车${/}cart_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}下单${/}create_order_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}支付${/}支付工具${/}pay_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot

*** Test Cases ***
Complete An Order Flow
    [Documentation]    订单流程（含退差和冲红）
    ...    流程：采购商登录->搜索商品->将商品加入购物车->提交订单->供应商改价->完成支付->供应商出库发起退差->采购商确认收货发起冲红->供应商确认冲红->交易完成->双方评价
    ...    规则：1.提交订单后商品库存减少，冻结库存增加；
    ...    \ \ \ \ \ 2.使用余额完成支付后余额减少；
    ...    \ \ \ \ 3.出库后冻结库存清零；
    ...    \ \ \ 4.产生退差冲红后，金额变化;
    [Tags]    stage
    Given 买家登录并清空购物车
    When 买家创建订单并支付
    And Saler Sents Out Partial Goods
    And Buyer Receipts Partial Goods
    And Saler Confirms The Unreceipted Goods
    Then The Order Was Completed
    评价管理
    [Teardown]    Close Browsers

订单流程不验证金额
    [Tags]
    Given 采购商下单并支付
    When 供应商出库
    Then 采购商收货
    [Teardown]    Close Browsers

*** Keywords ***
买家创建订单并支付
    从商品详情页将商品加入购物车
    进购物车提交订单
    提交订单并冻结库存
    Buyer Payed The Order

Buyer Searched Good
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}

Buyer Confirmed Messages From Confirm Order Page
    Buyer Confirm Order
    Do Not Use The Coupon
    Get The Discount Money
    Get The Postage

Buyer Payed The Order
    Get Account Balance From Pur Page    #支付订单前获取账户余额
    Buyer Pay Order
    Check Account Balance After Payed    #验证支付后账户余额的变化

Saler Sents Out Partial Goods
    Saler Confirm Order
    Out Cargo
    Registration Logistics Information
    Check The Blocked Inventory Released

采购商下单并支付
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Ensure The Cart Is Empty
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}
    Buyer Joined Cart From Search Reasult Page    ${SEARCH_GOOD_ID}
    Buyer Confirm Order
    Buyer Submits Order
    Buyer Pay Order

供应商出库
    Saler Logined Successfully
    Saler Confirm Order
    出库全部商品

采购商收货
    全部收货
    Check Order Status    交易完成

进购物车提交订单
    Go To    ${CART_URL}/cart/index
    从购物车获取商品价格
    Buyer Confirm Order
    Do Not Use The Coupon
    Get The Discount Money
    Get The Postage

评价管理
    Go To    ${PUR_URL}/Order/Comment/Create?orderCode=${ORDERCODE}
    Wait Until Element Is Visible    //p[@id="goodsQuality"]    ${WAIT_TIMEOUT}    订单评价页面未打开
