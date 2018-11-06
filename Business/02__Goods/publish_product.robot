*** Settings ***
Resource          Resources/common.robot
Resource          ../../Resources/order.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索${/}search_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}产品.robot
Resource          ${RESOURCE_PATH}${/}combine_service${/}交易域${/}商品${/}goods_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}goods_web.robot

*** Test Cases ***
Saler Publishes Product
    [Documentation]    新品发布
    ...    流程：供应商发布新品种-->供应商发布对应品种的商品-->后台拒绝通过-->供应商重新提交-->后台审核通过-->采购商搜索新商品
    [Tags]
    Given 买家登录并清空购物车
    When Saler Published A New Product
    And Manager Refused To Pass The Product
    And Saler Submited The Product Again
    And Manager Passed The Product
    Then Buyer Can Search The New Goods
    [Teardown]    Close Browsers

Manage Publishes Product
    [Documentation]    后台发布品种
    ...    流程：后台发布新品种-->供应商发布已有品种的商品-->采购商搜索新商品
    [Tags]
    Given 买家登录并清空购物车
    When Manager Pubished A New Product
    And Saler Used The Product To Publish A Goods
    Then Buyer Can Search The New Goods
    [Teardown]    Close Browsers

*** Keywords ***
Saler Published A New Product
    Saler Published Product
    Saler Sets Good Information

Manager Refused To Pass The Product
    Manager Logined Successfully
    Manager Refuses To Pass The Product

Saler Submited The Product Again
    Resubmit Product
    获取商品ID    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}

Buyer Can Search The New Goods
    Buyer Search Good From Index Page    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}    ${GOODSID}    产品${RANDOM_NUMBER}
    [Teardown]    Saler Deletes The Goods

Manager Pubished A New Product
    Manager Logined Successfully
    Manage Publishes A Product

Saler Used The Product To Publish A Goods
    Saler Publishes Good
    Saler Sets Good Information
    获取商品ID    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}

Saler Sets Good Information
    设置店铺商品分类
    Input Text    //input[@name='GoodsPrice']    10    #商品价格
    Input Text    //input[@name='RetailPrice']    15    #建议零售价格
    Input Text    //input[@name='MinNum']    1    #最小采购量
    Click Element    name=Status    #选择上架
    Click Element    id=submitForm
    Wait Until Element Contains    //div[@class="bootbox-body"]    商品发布成功!    ${WAIT_TIMEOUT}    商品发布失败
    Click Element    //button[@data-bb-handler="success"]
    Wait Until Element Is Visible    //dd/p/a

Saler Published Product
    Go To    ${SALES_URL}/Goods/PublishGoods    #进入发布商品页面
    Wait Until Element Is Visible    s_text
    ${RANDOM_NUMBER}    Evaluate    random.randint(1000,9999)    random,sys
    Set Suite Variable    ${RANDOM_NUMBER}
    Input Text    s_text    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Click Element    search
    Wait Until Element Is Visible    //a[@href="/Goods/PublishGoods/Create"]
    Click Element    //a[@href="/Goods/PublishGoods/Create"]
    Wait Until Element Is Visible    form_Action
    Input Text    //input[@name="CommonName"]    产品${RANDOM_NUMBER}
    Input Text    //input[@name="ProductName"]    产品${RANDOM_NUMBER}
    Input Text    //input[@name="BarCode"]    ${RANDOM_NUMBER}${RANDOM_NUMBER}
    Input Text    //input[@name="AllowNo"]    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Input Text    //input[@name="Factory"]    哈药六厂制药有限公司
    Input Text    //input[@name="Specification"]    16粒*3板
    Select Frame    frmFileUpload    #选择上传产品图片框
    Choose File    //input[@name="files[]"]    D:/Cases/Ypzdw/Resources/image/61.jpg
    Unselect Frame
    Select Frame    frmQualifycationUpload    #选择上传产品资质框
    Choose File    //input[@name="files[]"]    D:/Cases/Ypzdw/Resources/image/61.jpg    #${EXECDIR}/Resources/image/61.jpg
    Unselect Frame
    Click Element    //button[@type="submit"]
    Wait Until Element Is Visible    //select[@name='CustomCategoryId']    ${WAIT_TIMEOUT}    #等待商品分类下拉框加载出来

Manager Refuses To Pass The Product
    Go To    ${M_URL}/Product/ProductAudit/Index
    质管审核时搜索新品    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Wait Until Element Contains    //td[@class="text-center"][3]    产品${RANDOM_NUMBER}    ${WAIT_TIMEOUT}    #验证产品是否搜索到
    Click Element    //i[@class="fa fa-edit"]    #进入编辑新品界面
    Wait Until Element Is Visible    //a[@class="btn red"]    ${WAIT_TIMEOUT}    #验证拒绝通过按钮
    Click Element    //a[@class="btn red"]    #点击拒绝通过按钮
    Wait Until Element Is Visible    //form[@id='form_FeedBack']/div[2]/label[2]    ${WAIT_TIMEOUT}    #验证拒绝理由显示
    Click Element    //form[@id='form_FeedBack']/div[2]/label[2]    #选择拒绝理由
    Click Element    //form[@id='form_FeedBack']/div[3]/label    #选择拒绝理由
    Click Element    refuseOk
    Wait Until Element Is Not Visible    //td[@class="text-center"][3]    ${WAIT_TIMEOUT}
    [Teardown]

Manager Passed The Product
    Switch Browser    ${MANAGE_BROWSER}
    质管审核时搜索新品    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Wait Until Element Contains    //td[@class="text-center"][3]    产品${RANDOM_NUMBER}
    Click Element    //i[@class="fa fa-edit"]    #进入编辑新品界面
    质管审核产品通过
    [Teardown]

Saler Deletes The Goods
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Goods/GoodsManage/Index    #进入商品管理界面
    Search Text    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Wait Until Page Contains    产品${RANDOM_NUMBER}
    Execute Javascript    $('ul.dropdown-menu').attr('style','display: block;')
    Click Element    //tbody/tr[1]//a[@name='delLink']    #点击删除按钮
    Wait Until Element Is Visible    //button[@class='btn btn-primary']    #等待确认按钮显示
    Click Element    //button[@class='btn btn-primary']    #点击确认按钮
    Wait Until Page Does Not Contain    产品${RANDOM_NUMBER}
    [Teardown]

Manage Publishes A Product
    Go To    ${M_URL}/Product/Product/Index
    Wait Until Element Is Visible    createLink    ${WAIT_TIMEOUT}    #等待新增按钮出现
    Click Element    createLink
    Wait Until Element Is Visible    jquery=span.select2-arrow    ${WAIT_TIMEOUT}    #等待下拉框显示
    Click Element    jquery=span.select2-arrow    #点击下拉框
    Click Element    //div[@id='select2-drop']/ul/li[2]/ul/li/div    #选择一级分类
    Wait Until Element Is Visible    xpath=//select[@class='form-control select2me']    ${WAIT_TIMEOUT}    #等待二级分类下拉框显示
    Select From List By Label    xpath=//select[@class='form-control select2me']    青霉素类    #选择二级分类
    ${RANDOM_NUMBER}    Evaluate    random.randint(1000,9999)    random
    Set Suite Variable    ${RANDOM_NUMBER}
    Input Text    //input[@name='ComName']    产品${RANDOM_NUMBER}    #输入产品名称
    Input Text    //input[@name='AllowNo']    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}    #输入批准文号
    Input Text    //input[@name='Specification']    12粒*3板    #输入规格
    Wait Until Element Is Visible    flag0    ${WAIT_TIMEOUT}    经营类别下拉框未显示
    Select From List By Label    flag0    处方药    #选择必选项
    Wait Until Element Is Visible    flag1    ${WAIT_TIMEOUT}    剂型下拉框未显示
    Select From List By Label    flag1    流浸膏剂    #选择必选项
    Wait Until Element Is Visible    flag2    ${WAIT_TIMEOUT}    类型下拉框未显示
    Select From List By Label    flag2    抗生素制剂    #选择必选项
    Wait Until Element Is Visible    flag3    ${WAIT_TIMEOUT}    服用方式下拉框未显示
    Select From List By Label    flag3    口服    #选择必选项
    Wait Until Element Is Visible    flag4    ${WAIT_TIMEOUT}    易碎品下拉框未显示
    Select From List By Label    flag4    否    #选择必选项
    Select Frame    //iframe[@id='frmFileUpload']    #选择上传产品图片框
    Choose File    xpath=//div[@id="fileupload"]//input    ${EXECDIR}\\Resources\\Image\\61.jpg    #上传图片
    Unselect Frame    #退出产品图片框
    Click Element    //div[@id="s2id_FactoryId"]//span [@class="select2-chosen"]    #弹出生产厂家列表
    Wait Until Element Is Visible    //div[@id='select2-drop']/ul/li/div    ${WAIT_TIMEOUT}
    Click Element    //div[@id='select2-drop']/ul/li/div    #选择生产厂家
    Input Text    //input[@name='BarCode']    ${RANDOM_NUMBER}${RANDOM_NUMBER}${RANDOM_NUMBER}    #输入条形码
    Click Element    //div[@class="radio-list"]/label[1]    #点击激活按钮
    Input Text    //div[@class="col-md-4"]/textarea    产品功效    #输入产品功效
    Click Element    subdata    #点击确认提交
    Wait Until Element Is Visible    KeyWords    ${WAIT_TIMEOUT}
    Input Text    KeyWords    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Click Element    search
    Wait Until Element Contains    //table/tbody/tr/td[4]    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}    ${WAIT_TIMEOUT}    未发布商品成功

Saler Publishes Good
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Goods/PublishGoods    #进入发布商品页面
    Wait Until Element Is Visible    s_text
    Input Text    s_text    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Click Element    search
    Wait Until Element Contains    //td[@class="text-center tallowno"]    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}    ${WAIT_TIMEOUT}
    Click Element    //td[@class="text-center tallowno"]
    Wait Until Element Is Visible    nextPublishLink
    Click Element    nextPublishLink
    Wait Until Element Is Not Visible    nextPublishLink

Resubmit Product
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Goods/NotApprovedGoods/Index    #进入未通过审核商品页面
    Search Text    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Wait Until Element Contains    //table/tbody/tr[1]/td[2]    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}    ${WAIT_TIMEOUT}
    Capture Page Screenshot
    Click Element    jquery=a:contains("编辑")
    Wait Until Element Is Visible    //button[@type="submit"]    ${WAIT_TIMEOUT}    未进入到重新提交商品的编辑页面
    Click Element    //button[@type="submit"]
    Search Text    国药准字H${RANDOM_NUMBER}${RANDOM_NUMBER}
    Wait Until Element Is Not Visible    //table/tbody/tr/td[2]    ${WAIT_TIMEOUT}    重新提交商品信息失败了
