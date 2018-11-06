*** Settings ***
Resource          ../03__Order/Resources/common.robot
Resource          ../../Resources/order.robot
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
Resource          ../../Resources/coupon.robot

*** Test Cases ***
商业可以对增值税电子普通发票进行开票处理
    已开通电子发票的商业的订单交易完成
    商业可以看到待开票的订单数据
    商业可以开票
    商业可以查询开票进度
    Comment    商业还可以对已开出的蓝票进行冲红
    [Teardown]    Close Browsers

*** Keywords ***
已开通电子发票的商业的订单交易完成
    Given 买家登录并清空购物车
    Ensure The Cart Is Empty
    Buyer Search Good From Index Page    ${SEARCH_GOOD_GYZZ}    ${SEARCH_GOOD_ID}    ${SEARCH_GOOD}
    Buyer Joined Cart From Search Reasult Page    ${SEARCH_GOOD_ID}
    Buyer Confirm Order
    Buyer Submits Order
    Buyer Pay Order
    获取订单支付金额以及订单邮费
    Saler Logined Successfully
    Saler Confirm Order
    Out Cargo
    Comment    Registration Logistics Information
    Comment    获取订单出库金额
    Comment    Comment    商业主动冲红
    Comment    Buyer Receipts Partial Goods
    Comment    Saler Confirms The Unreceipted Goods
    Comment    获取商业确认的冲红金额

商业可以看到待开票的订单数据
    Go To    ${SALES_URL}/Invoice/Default/PendingInvoice?pagename=/console/sales/einvoice/pendingInvoice.html
    Select Frame    iframeBox
    Wait Until Element Is Visible    //input[@name="orderCode"]    ${WAIT_TIMEOUT}    待开票页面未显示
    Input Text    //input[@name="orderCode"]    ${ORDERCODE}
    sleep    2s
    Click Element    searchButton    #点击搜索
    Comment    #检查订单支付金额是否正确
    Comment    sleep    5s
    Comment    ${text2}    Get Text    //td[text()="${ORDERCODE}"]/parent::*/child::td[4]    #获取待开票界面的订单金额
    Comment    @{goodPayPrice}=    Get Regexp Matches    ${text2}    ￥(.*)    1
    Comment    ${orderPrice}    Convert To String    @{goodPayPrice}[0]
    Comment    Should Be Equal    ${orderPrice}    ${orderPayPrice}    #支付订单金额跟待开票中订单金额对比
    Comment    #检查订单出库金额是否正确
    Comment    ${text3}    Get Text    //td[text()="${ORDERCODE}"]/parent::*/child::td[5]    #获取待开票界面的订单出库金额
    Comment    @{goodOutPrice}=    Get Regexp Matches    ${text3}    ￥(.*)    1
    Comment    ${orderOutPriceNew}    Convert To String    @{goodOutPrice}[0]
    Comment    Should Be Equal    ${orderOutPriceNew}    ${orderOutPrice}    #检查待开票界面的出库金额和药销宝中出库金额是否相等
    Comment    #检查订单冲红金额是否正确？？？
    Comment    ${text4}    Get Text    //td[text()="${ORDERCODE}"]/parent::*/child::td[6]    #获取待开票界面的冲红金额
    Comment    @{goodredPrice}=    Get Regexp Matches    ${text4}    ￥(.*)    1
    Comment    ${orderRedPriceNew}    Convert To String    @{goodredPrice}[0]
    Comment    Should Be Equal    ${orderRedPriceNew}    ${orderRedPrice}
    Comment    #检查订单开票金额是否正确？？？
    Comment    ${text5}    Get Text    //td[text()="${ORDERCODE}"]/parent::*/child::td[7]    #获取待开票界面的待开票金额
    Comment    @{ticketPrice}=    Get Regexp Matches    ${text5}    ￥(.*)    1
    Comment    ${ticketPrice}    Convert To String    @{ticketPrice}[0]
    Comment    ${reslutPrice1}    Evaluate    ${orderOutPriceNew}-${orderRedPriceNew}
    Comment    Should Be Equal As Numbers    ${ticketPrice}    ${reslutPrice1}
    Comment    Set Suite Variable    ${ticketPrice}

获取订单支付金额以及订单邮费
    ${text}    Get Text    //table[@class="table table-hover order-list"]/tbody/tr/td[5]/p
    @{goodPrice}=    Get Regexp Matches    ${text}    ¥(.*)    1
    ${orderPayPrice}    Convert To String    @{goodPrice}[0]
    Set Suite Variable    ${orderPayPrice}
    #进入订单详情，获得订单邮费金额
    Click Element    //td[@class="order-oper"]
    Comment    Wait Until Element Is Visible    //div[@class="o_moenybox"]/p[2]    ${WAIT_TIMEOUT}    #等待邮费显示出来
    Comment    ${text1}    Get Text    //div[@class="o_moenybox"]/p[2]
    Comment    @{goodEmailPrice}=    Get Regexp Matches    ${text1}    ¥(.*)    1
    Comment    ${orderEmailPrice}    Convert To String    @{goodEmailPrice}[0]
    Comment    Set Suite Variable    ${orderEmailPrice}
    Comment    Go Back

商业可以开票
    Wait Until Element Is Visible    //td[text()="${ORDERCODE}"]/parent::*/child::td[10]/button    ${WAIT_TIMEOUT}    #开票按钮未显示    #//td[text()="${ORDERCODE}"]/parent::*/child::td[10]/button
    Click Element    //td[text()="${ORDERCODE}"]/parent::*/child::td[10]/button    #点击开票按钮
    Comment    #检查开票金额是否相等
    Comment    Wait Until Element Is Visible    oldTotalAmount    ${WAIT_TIMEOUT}    #信息确认界面未打开
    Comment    ${price}    Get Text    oldTotalAmount
    Comment    Should Be Equal As Numbers    ${price}    ${ticketPrice}    #信息确认界面的金额与开票金额对比    #${ticketPrice}
    #判断商品是否设置税率
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    jquery=span:contains("设置税率后可见")    ${WAIT_TIMEOUT}
    Run Keyword If    '${status}'=='True'    设置税率
    #判断商品是否设置税收编码
    ${status1}    Run Keyword And Return Status    Wait Until Element Is Visible    jquery=span:contains("请输入税收分类编码")
    Run Keyword If    '${status1}'=='True'    设置税收编码
    #获取开票信息确认界面的开票金额
    ${ticketPrice}    Get Text    //tr[@id="taxRateCount"]/td[1]/span
    Wait Until Element Is Visible    wkq-taxConfig-submit    ${WAIT_TIMEOUT}    确认开票按钮未显示
    Click Element    wkq-taxConfig-submit
    Sleep    2s
    Click Element    searchButton    #点击搜索
    Wait Until Element Is Visible    jquery=td:contains("无相关记录")    ${WAIT_TIMEOUT}    开票未成功

获取订单出库金额
    ${text}    Get Text    //table[@class="table table-striped table-hover"]/tbody/tr/td[7]    #获取药销宝订单列表中的出库金额
    @{goodPrice}=    Get Regexp Matches    ${text}    ¥(.*)    1
    ${orderOutPrice}    Convert To String    @{goodPrice}[0]
    Set Suite Variable    ${orderOutPrice}
    log    ${orderOutPrice}

商业主动冲红
    Click Element    jquery=a:contains("冲红")

获取商业确认的冲红金额
    Wait Until Element Is Visible    //p[@class="txt_r"]    ${WAIT_TIMEOUT}    冲红查询界面的冲红金额未显示
    ${text}    Get Text    //p[@class="txt_r"]    #获取药销宝订单列表中的出库金额
    @{goodRedPrice}=    Get Regexp Matches    ${text}    ¥(.*)    1
    ${orderRedPrice}    Convert To String    @{goodRedPrice}[0]
    Set Suite Variable    ${orderRedPrice}
    log    ${orderRedPrice}

设置税率
    Wait Until Element Is Visible    //select[@name="taxRateSelect"]/option[2]    ${WAIT_TIMEOUT}    税率未显示
    Click Element    //select[@name="taxRateSelect"]/option[2]

设置税收编码
    Wait Until Element Is Visible    jquery=span:contains("请输入税收分类编码")    ${WAIT_TIMEOUT}    设置税收编码框未显示
    Click Element    jquery=span:contains("请输入税收分类编码")
    Wait Until Element Is Visible    //ul[@class="select2-results__options"]/li[3]    ${WAIT_TIMEOUT}    税收编码未显示
    Click Element    //ul[@class="select2-results__options"]/li[3]

商业可以查询开票进度
    Saler Logined Successfully
    查看发票状态是否正确    开票中
    sleep    120s    #等待用友开票
    查看发票状态是否正确    已开票

查看发票状态是否正确
    [Arguments]    ${status}
    Go To    ${SALES_URL}/Invoice/Default/InvoiceQuery?pagename=/console/sales/einvoice/invoiceQuery.html
    Select Frame    iframeBox
    Wait Until Element Is Visible    //input[@name="orderNo"]    ${WAIT_TIMEOUT}    发票查询界面未显示
    Input Text    //input[@name="orderNo"]    ${ORDERCODE}    #${ORDERCODE}
    sleep    2s
    Click Element    searchButton    #点击搜索
    sleep    2s
    Wait Until Element Is Visible    jquery=a:contains("${status}")    ${WAIT_TIMEOUT}    已提交开票申请的票据信息无法查到

商业还可以对已开出的蓝票进行冲红
    Wait Until Element Is Visible    jquery=a:contains("冲红")    ${WAIT_TIMEOUT}    预览按钮未显示
    Click Element    jquery=a:contains("冲红")
