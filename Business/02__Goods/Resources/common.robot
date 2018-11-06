*** Settings ***
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}goods_web.robot

*** Keywords ***
买家登录并清空购物车
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Saler Logined Successfully
