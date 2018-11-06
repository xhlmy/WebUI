*** Settings ***
Resource          library.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}搜索/search_web.robot
Resource          ${RESOURCE_PATH}${/}single_service${/}交易域${/}商品${/}goods_web.robot

*** Keywords ***
Get Inventory From Search Result
    [Arguments]    ${searchGoodId}
    Wait Until Element Is Visible    //li[@data-goodsid="${searchGoodId}"]//span[@id="goodsCard-store"]    ${WAIT_TIMEOUT}    搜索页面库存未显示出来
    ${textinventory}=    Get text    //li[@data-goodsid="${searchGoodId}"]//span[@id="goodsCard-store"]
    ${INVENTORY}    Convert To String    ${textinventory}
    Set Global Variable    ${INVENTORY}

Check Inventory After Submited Order
    Switch Browser    ${BUYER_BROWSER}
    Go To    ${INDEX_URL}/Search/Search?searchType=1&key=${SEARCH_GOOD_GYZZ}&sort=
    Comment    Select Window    ${SEARCH_GOOD_GYZZ}-药品终端网
    Comment    Reload Page
    Wait Until Element Is Visible    jquery=a.relby
    Click Element    jquery=a.relby    #点击采购
    Wait Until Element Is Visible    jquery=input.numinput    ${WAIT_TIMEOUT}    #等待列表展开
    ${INVENTORY_LAST}=    Execute Javascript    return $("#li${SEARCH_GOOD_SPECBINDID}").find("a:contains('${STORE_NAME}')").parents("tr").find("td").eq(2).html()
    Set Global Variable    ${INVENTORY_LAST}
    ${difference}=    Evaluate    ${INVENTORY}-${INVENTORY_LAST}
    Should Be Equal As Strings    ${difference}    ${BUY_NUMBER}
    Go Back

Check Inventory After closed Order
    Switch Browser    ${SALER_BROWSER}
    Go To    ${SALES_URL}/Goods/GoodsManage/Edit/${SEARCH_GOOD_ID}
    Wait Until Element Is Visible    //input[@name="Inventory"]
    #验证关闭订单后冻结库存释放
    ${blockedInventoryNew}    Get Text    //div[@class="disnum"]/span[2]
    ${different}    Evaluate    ${BLOCKED_INVENTORY_LAST}-${blockedInventoryNew}
    Should Be Equal As Strings    ${different}    ${BUY_NUMBER}    出库后释放冻结库存
    #验证关闭订单后库存恢复
    ${inventoryNew}=    Get Element Attribute    //input[@name="Inventory"]@value
    ${difference}=    Evaluate    ${inventoryNew}-${INVENTORY_LAST}
    Should Be Equal As Strings    ${difference}    ${BUY_NUMBER}
