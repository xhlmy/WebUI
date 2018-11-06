*** Settings ***
Documentation     仅显示有货是指在搜索界面中默认显示有货的商品：
...               1、当库存为0时，会不显示出来；
...               2、当库存小于最小采购量时，也会不显示出来
Suite Teardown    恢复正常库存
Force Tags        search
Resource          Resources/search.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}inventory_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}goods_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ../../Resources/library.robot
Resource          ../../Resources/goods.robot

*** Test Cases ***
无库存时无法搜索到
    [Documentation]    writer:yyy
    [Tags]
    Given 商品的库存为零时
    When 采购商搜索此商品且搜索的筛选条件为仅显示有货
    Then 采购商无法搜索到此商品
    [Teardown]

库存小于最小采购量时无法搜索到
    [Documentation]    writer:yyy
    [Tags]
    Given 商品的库存小于最小采购量时
    When 采购商搜索此商品且搜索的筛选条件为仅显示有货
    Then 采购商无法搜索到此商品
    [Teardown]

*** Keywords ***
商品的库存为零时
    Saler Logined Successfully
    Go To    ${SALES_URL}/Goods/GoodsManage/Index
    Search Text    ${SEARCH_GOOD_GYZZ}
    供应商进入商品编辑界面
    修改库存    0    1
