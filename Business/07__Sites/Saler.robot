*** Settings ***
Resource          ../../Resources/library.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot

*** Test Cases ***
Page Check
    Saler Logined Successfully
    Comment    药销宝首页
    订单管理
    商品管理
    [Teardown]    Close Browsers

*** Keywords ***
订单管理
    所有订单
    冲红查询
    评价管理
    发票管理

所有订单
    Go To    ${SALES_URL}/Order/Order/Index
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝订单列表页面未加载
    Click Element    //tbody/tr[1]/td[1]/a
    Wait Until Page Contains    订单信息    error=药销宝订单详情页面未加载

冲红查询
    Go To    ${SALES_URL}/Order/Red/Index
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝冲红列表页面未加载
    Click Element    //tbody/tr[1]/td[1]/a[1]
    Wait Until Page Contains    冲红详细    error=药销宝冲红详情页面未加载

评价管理
    Go To    ${SALES_URL}/Order/Comment/Index
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝评价管理页面未加载

发票管理
    Go To    ${SALES_URL}/Order/Tax/Index
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝发票管理页面未加载
    Click Element    //tbody/tr[1]/td[6]/a
    Wait Until Element Is Visible    billAllBtn    error=药销宝发票管理详情页面未加载

药销宝首页

商品管理
    商品分类
    商品管理列表
    商品快捷发布
    商品发布
    未通过审核商品
    后台商品

商品分类
    Go To    ${SALES_URL}/Goods/ShopGoodsCategory/index
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝商品分类页面未加载
    Click Element    //tbody/tr[1]/td[5]/a
    Wait Until Element Is Visible    //button[@type="submit"]    error=药销宝商品分类编辑页面未加载

商品管理列表
    Go To    ${SALES_URL}/Goods/GoodsPicManage/Index/${SEARCH_GOOD_ID}
    Wait Until Element Is Visible    //li[@data-target="#myModal"]    error=药销宝商品图片管理页面未加载
    Go To    ${SALES_URL}/Goods/Quality/Index/${SEARCH_GOOD_ID}
    Wait Until Element Is Visible    //li[@data-target="#myModal"]    error=药销宝商品质检报告管理页面未加载

商品快捷发布
    Go To    ${SALES_URL_NEW}/product/publish
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝快捷发布列表页面未加载
    Go To    ${SALES_URL_NEW}/product/edit
    Wait Until Element Is Visible    //input[@name="productRawId"]    error=药销宝快捷发布编辑页面未加载

商品发布
    Go To    ${SALES_URL}/Goods/PublishGoods/Index
    Wait Until Element Is Visible    s_text    error=药销宝商品发布页面未加载
    Input Text    s_text    1111
    Click Button    search
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝商品发布不能搜索
    Go To    ${SALES_URL}/Goods/PublishGoods/Create
    Wait Until Element Is Visible    //input[@name="CommonName"]    error=药销宝新品发布页面不能加载

未通过审核商品
    Go To    ${SALES_URL}/Goods/NotApprovedGoods/Index
    Wait Until Page Contains    拒绝理由    error=药销宝未通过审核商品页面未加载

后台商品
    Go To    ${SALES_URL}/ContrlSale/SpecialSupplyGoods/Index
    Wait Until Element Is Visible    //tbody/tr[1]/td[1]    error=药销宝后台商品页面未加载
