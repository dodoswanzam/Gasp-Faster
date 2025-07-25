import { describe, expect, it } from "vitest";
import { simnet, tx } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";

const PROOF_OF_DONATION_CONTRACT = "proof-of-donation";

describe("Proof of Donation Contract", () => {
  it("allows an organization to register", () => {
    const { result } = simnet.callPublicFn(
      PROOF_OF_DONATION_CONTRACT,
      "register-organization",
      [Cl.stringAscii("World Health Foundation")],
      simnet.deployer
    );
    expect(result).toBeOk(Cl.bool(true));

    const orgName = simnet.callReadOnlyFn(
      PROOF_OF_DONATION_CONTRACT,
      "get-organization-name",
      [Cl.principal(simnet.deployer)],
      simnet.deployer
    );
    expect(orgName.result).toStrictEqual(Cl.some(Cl.stringAscii("World Health Foundation")));
  });

  it("allows a user to donate and receive a proof-of-donation NFT", () => {
    // Register the organization first
    simnet.callPublicFn(
      PROOF_OF_DONATION_CONTRACT,
      "register-organization",
      [Cl.stringAscii("Global Charity Org")],
      simnet.deployer
    );

    // Wallet 1 donates to the organization
    const { result } = simnet.callPublicFn(
      PROOF_OF_DONATION_CONTRACT,
      "donate",
      [Cl.principal(simnet.deployer), Cl.stringAscii("For clean water projects")],
      simnet.accounts.get("wallet_1")!
    );

    // Expect the donation to be successful and return token ID 1
    expect(result).toBeOk(Cl.uint(1));

    // Check that wallet_1 is the new owner of the NFT
    const nftOwner = simnet.getNFTOwner(PROOF_OF_DONATION_CONTRACT, "proof-of-donation-nft", 1);
    expect(nftOwner).toBe(simnet.accounts.get("wallet_1")!);
  });
});