import { expect } from "chai"
import { ethers } from "hardhat"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { Contract } from "ethers"
const newLocal = "../artifacts/contracts/CustomToken.sol/CustomToken.json"
const tokenJSON = require(newLocal)

export interface ShopContext {
  owner: SignerWithAddress
  buyer: SignerWithAddress
  shop: Contract
  erc20: Contract
}

describe("Shop", function () {
  let ctx: ShopContext

  beforeEach(async function () {
    const [owner, buyer] = await ethers.getSigners()

    const MShop = await ethers.getContractFactory("Shop", owner)
    const shop = await MShop.deploy()
    await shop.deployed()

    const erc20 = new ethers.Contract(await shop.token(), tokenJSON.abi, owner)
    ctx = { buyer, owner, shop, erc20 }
  })

  it("should have an owner and a token", async function () {
    expect(await ctx.shop.owner()).to.eq(ctx.owner.address)
    await expect(await ctx.shop.token()).to.be.properAddress
  })

  it("allows to buy", async function () {
    const tokenAmount = 3

    const txData = {
      value: tokenAmount,
      to: ctx.shop.address
    }

    const tx = await ctx.buyer.sendTransaction(txData)
    await tx.wait()

    expect(await ctx.erc20.balanceOf(ctx.buyer.address)).to.eq(tokenAmount)

    await expect(() => tx).to.changeEtherBalance(ctx.shop, tokenAmount)

    await expect(tx).to.emit(ctx.shop, "Bought").withArgs(tokenAmount, ctx.buyer.address)
  })

  it("allows to sell", async function () {
    const tx = await ctx.buyer.sendTransaction({
      value: 3,
      to: ctx.shop.address
    })
    await tx.wait()

    const sellAmount = 2

    const approval = await ctx.erc20.connect(ctx.buyer).approve(ctx.shop.address, sellAmount)

    await approval.wait()

    const sellTx = await ctx.shop.connect(ctx.buyer).sell(sellAmount)

    expect(await ctx.erc20.balanceOf(ctx.buyer.address)).to.eq(1)

    await expect(() => sellTx).to.changeEtherBalance(ctx.shop, -sellAmount)

    await expect(sellTx).to.emit(ctx.shop, "Sold").withArgs(sellAmount, ctx.buyer.address)
  })
})
