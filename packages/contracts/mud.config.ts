import { mudConfig, resolveTableId } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    Direction: [
      "Unknown",
      "Up",
      "Down",
      "Left",
      "Right",
    ]
  },
  systems: {
    PrivateDeFiSystem: {
      openAccess: false,
    }
  },
  tables: {
    Position: {
      schema: {
        x: "int32",
        y: "int32",
      }
    },
    Health: {
      schema: {
        current: "int32",
        max: "int32",
      },
    },
    Strength: {
      schema: "int32",
    },
    EntityInfo: {
      schema: {
        creator: "address",
        name: "string",
        metadataStr: "string",
      }
    },
    EntityOwnership: {
      keySchema: {
        entityId: "bytes32",
        owner: "address",
      },
      schema: {
        balance: "uint256",
      },
    },
    EntityMarketplaceSell: {
      keySchema: {
        entityId: "bytes32",
        seller: "address",
      },
      schema: {
        unitPrice: "uint256",
        amount: "uint256",
      },
    },
    StakingRecord: {
      schema: {
        assetAmountProcessed: "uint256",
        shareBalance: "uint256",
        shareAmountLocked: "uint256",
      },
    },
    DeFi: {
      schema: {
        contractAddress: "address",
      },
    }
  },
  modules: [
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("Position")],
    },
  ]
});
