*** Settings ***
Resource          ../../../Resources/order.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}price_web.robot

*** Keywords ***
买家登录并清空购物车
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Ensure The Cart Is Empty

提交订单并冻结库存
    Saler Logined Successfully
    从商品编辑页获取商品库存信息
    Buyer Submits Order
    Check The Inventory Blocked    #验证提交订单后库存的变化
