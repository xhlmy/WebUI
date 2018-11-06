*** Settings ***
Resource          library.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}inventory_web.robot

*** Keywords ***
Buyer Search Goods
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}

Buyer Can See The Last Price And Inventory In Search Page
    Wait Until Keyword Succeeds    2 times    1s    验证价格同步
    Wait Until Keyword Succeeds    2 times    1s    验证库存同步

商品的库存小于最小采购量时
    Comment    Saler Logined Successfully
    Comment    Go To    ${SALES_URL}/Goods/GoodsManage/Index
    Comment    Search Text    ${SEARCH_GOOD_GYZZ}
    Comment    供应商进入商品编辑界面
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Goods/GoodsManage/Edit/${SEARCH_GOOD_ID}
    修改库存    5    10

采购商搜索此商品且搜索的筛选条件为仅显示有货
    Comment    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Switch Browser    ${BUYER_BROWSER}
    输入商品进行搜索    ${SEARCH_GOOD_GYZZ}

采购商无法搜索到此商品
    Wait Until Keyword Succeeds    2 times    1s    搜索不到
    [Teardown]

验证库存同步
    Reload Page
    Get Inventory From Search Result    ${SEARCH_GOOD_ID}
    Should Be Equal As Strings    ${INVENTORY_NEW}    ${INVENTORY}    搜索库存同步失败

验证价格同步
    Reload Page
    从搜索结果页面获取商品价格    ${SEARCH_GOOD_ID}
    Should Be Equal As Numbers    ${GOODS_NEW_PRICE}    ${GOOD_PRICE}    msg=搜索价格同步失败    precision=2

搜索不到
    Reload Page
    Wait Until Page Contains    对不起....我们没有找到

恢复正常库存
    Comment    Saler Logined Successfully
    Comment    Go To    ${SALES_URL}/Goods/GoodsManage/Index
    Comment    Search Text    ${SEARCH_GOOD_GYZZ}
    Comment    ${inventory}    Evaluate    random.randint(7000,9999)    random,sys    #设置库存为200-999之间的随机数
    Comment    供应商进入商品编辑界面
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Goods/GoodsManage/Edit/${SEARCH_GOOD_ID}
    ${inventory}    Evaluate    random.randint(7000,9999)    random,sys    #设置库存为200-999之间的随机数
    修改库存    ${inventory}    1
    [Teardown]    Close Browsers
