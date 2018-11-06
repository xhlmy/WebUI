*** Settings ***
Resource          ${RESOURCE_PATH}${/}single_service${/}通行证${/}login_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}采购${/}购物车${/}cart_web.robot

*** Keywords ***
采购商已设置默认发票类型
    Buyer Logined Successfully    ${BUYER_MOBILE}    ${BUYER_PWD}
    Ensure The Cart Is Empty
    采购商确认发票类型为专票

采购商确认发票类型为专票
    采购商进入发票信息界面
    #判断发票界面是否在专票界面
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    //div[@class="y_oneTaxContent"]/dl[5]/dt/span[2]    error=不在增值税专用发票界面
    Run Keyword If    '${status}'=='False'    普票和专票的切换
    Wait Until Element Is Visible    //div[@class="y_oneTaxContent"]/dl[5]/dt/span[2]    ${WAIT_TIMEOUT}    未切换到专票页面
    #判断专票是否为默认开票类型
    ${status1}=    Execute Javascript    return $('#y_taxTypeDefault').is(':checked')
    Run Keyword If    '${status1}'=='False'    设置默认开票类型
    Wait Until Element Is Visible    //input[@name="bankName"]    ${WAIT_TIMEOUT}    设置发票为专票，设置失败
    Go Back

普票和专票的切换
    Click Element    //span[@class="oneTax y_taxTab"]    #从普票切换到专票

设置默认开票类型
    Wait Until Element Is Visible    //label[@class="taxlabel"]    ${WAIT_TIMEOUT}    勾选框未出现
    Click Element    //label[@class="taxlabel"]    #点击选中专票中的默认开票类型
    Click Element    y_taxSave    #点击保存
    Reload Page

采购商进入发票信息界面
    Go To    ${PUR_URL}/Member/Tax
    Wait Until Element Is Visible    //span[@id="y_taxSave"]    ${WAIT_TIMEOUT}    发票信息页面未加载成功
