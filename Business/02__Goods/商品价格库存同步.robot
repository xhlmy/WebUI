*** Settings ***
Suite Teardown
Force Tags        stage    prod
Resource          Resources/common.robot
Resource          ../../Resources/goods.robot
Resource          ../../Resources/money.robot
Resource          ../../Resources/inventory.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}商品${/}goods_web.robot

*** Test Cases ***
商家药销宝修改价格库存后商品价格库存同步
    [Documentation]    价格库存同步
    ...    流程：修改商品对应区域的价格及库存-->采购商搜索验证-->采购商商品详情验证
    [Tags]
    Given Saler Logined Successfully
    When 商业修改价格和库存
    Then 验证商品详情页的价格和库存是否同步
    When Buyer Search Goods
    Then Buyer Can See The Last Price And Inventory In Search Page
    Given 商品的库存小于最小采购量时
    When 采购商搜索此商品且搜索的筛选条件为仅显示有货
    Then 采购商无法搜索到此商品
    [Teardown]    恢复正常库存

*** Keywords ***
验证商品详情页的价格和库存是否同步
    进入商品详情页查看商品价格
    ${number}    Get Text    //div[@class="sx_list"][8]    #获取商品实际库存
    Should Be Equal As Strings    ${number}    当前库存：${INVENTORY_NEW}盒    商品详情页库存同步失败
