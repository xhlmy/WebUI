*** Settings ***
Suite Teardown    Close Browsers
Resource          Resources/common.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}goods_web.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}商品${/}goods_web.robot

*** Test Cases ***
商品上下架
    [Tags]
    Given 商品为上架状态且采购商可以购买
    When 供应商下架该商品后采购商无法购买
    Then 供应商上架该商品后可采购商可以购买
    [Teardown]    确认商品已上架

*** Keywords ***
供应商下架该商品后采购商无法购买
    供应商修改商品上下架状态    下架
    采购商无法购买该商品

供应商上架该商品后可采购商可以购买
    供应商修改商品上下架状态    上架
    采购商可以购买商品
    [Teardown]

商品为上架状态且采购商可以购买
    买家登录并清空购物车
    确认商品已上架
    采购商可以购买商品

采购商可以购买商品
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${GOOD_DETAIL_URL}
    Wait Until Element Is Visible    //a[@name='addCart'][1]    ${WAIT_TIMEOUT}    加入购物车按钮未显示
    Click Element    //a[@name='addCart'][1]    #点击加入购物车
    Sleep    1
    Wait Until Element Is Visible    jquery=div.addcart_up    ${WAIT_TIMEOUT}    加入购物车未成功

采购商无法购买该商品
    Switch Browser    ${BUYER_BROWSER}
    Reload Page
    Wait Until Element Contains    //div[@class="prod-off"]    对不起，此品种不在此区域销售或者已经下架！    ${WAIT_TIMEOUT}
