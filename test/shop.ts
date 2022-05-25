import { expect } from "chai"
import { ethers } from "hardhat"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { Shop, CustomToken } from "../typechain"
import { Contract } from "ethers"

export interface ShopContext {
  token: CustomToken
  owner: SignerWithAddress
  buyer: SignerWithAddress
  shop: Shop
  erc20: Contract
}

describe("MShop", function () {
  let ctx: ShopContext

  beforeEach(async function () {
    const [owner, buyer] = await ethers.getSigners()

    const MShop = await ethers.getContractFactory("MShop", owner)
    const shop = await MShop.deploy()
    await shop.deployed()

    const erc20 = new ethers.Contract(await shop.token(), Shop.abi, owner)
    ctx = { buyer, owner, shop, erc20 }
  })

  it("should have an owner and a token", async function () {
    expect(await shop.owner()).to.eq(owner.address)

    expect(await shop.token()).to.be.properAddress
  })

  it("allows to buy", async function () {
    const tokenAmount = 3

    const txData = {
      value: tokenAmount,
      to: shop.address
    }

    const tx = await buyer.sendTransaction(txData)
    await tx.wait()

    expect(await erc20.balanceOf(buyer.address)).to.eq(tokenAmount)

    await expect(() => tx).to.changeEtherBalance(shop, tokenAmount)

    await expect(tx).to.emit(shop, "Bought").withArgs(tokenAmount, buyer.address)
  })

  it("allows to sell", async function () {
    const tx = await buyer.sendTransaction({
      value: 3,
      to: shop.address
    })
    await tx.wait()

    const sellAmount = 2

    const approval = await erc20.connect(buyer).approve(shop.address, sellAmount)

    await approval.wait()

    const sellTx = await shop.connect(buyer).sell(sellAmount)

    expect(await erc20.balanceOf(buyer.address)).to.eq(1)

    await expect(() => sellTx).to.changeEtherBalance(shop, -sellAmount)

    await expect(sellTx).to.emit(shop, "Sold").withArgs(sellAmount, buyer.address)
  })
})