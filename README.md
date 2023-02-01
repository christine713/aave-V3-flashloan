# aave-V3-flashloan
deploy aave v3 flashloan smart contract on **Georli** test network

## Get started
在goerli 建立兩個ERC20 token

<img width="188" alt="image" src="https://user-images.githubusercontent.com/44830858/216009939-38245ac8-bce7-480a-afe6-385881042353.png">

在uniswap創建三個交易對，分別是：

DAI-tkB 100:10000

tkB-tkA 10000:10000

tkA-DAI 40000:2500

## deploy on Remix

在remix上deploy時需帶入aave provider:

```
0xc4dCB5126a3AfEd129BC3668Ea19285A9f56D15D
```
使用 `requestFlashloan` function

```
DAI address: 0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464
Amount:1000000000000000000
```


## transcation
[Etherscan 交易明細](https://goerli.etherscan.io/tx/0x67fc8a326605399724b998c6b9fe9b06a6bf7f7420817e2df4af7d1798adde3c)

<img width="955" alt="截圖 2023-02-01 下午6 01 01" src="https://user-images.githubusercontent.com/44830858/216011766-d14c4a47-eae6-4e14-a4d4-70fc80d2f601.png">
