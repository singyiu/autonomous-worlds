/* Autogenerated file. Do not edit manually. */

import { TableId } from "@latticexyz/utils";
import { defineComponent, Type as RecsType, World } from "@latticexyz/recs";

export function defineContractComponents(world: World) {
  return {
    Position: (() => {
      const tableId = new TableId("", "Position");
      return defineComponent(
        world,
        {
          x: RecsType.Number,
          y: RecsType.Number,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    Health: (() => {
      const tableId = new TableId("", "Health");
      return defineComponent(
        world,
        {
          current: RecsType.Number,
          max: RecsType.Number,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    Strength: (() => {
      const tableId = new TableId("", "Strength");
      return defineComponent(
        world,
        {
          value: RecsType.Number,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    EntityInfo: (() => {
      const tableId = new TableId("", "EntityInfo");
      return defineComponent(
        world,
        {
          creator: RecsType.String,
          name: RecsType.String,
          metadataStr: RecsType.String,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    EntityOwnership: (() => {
      const tableId = new TableId("", "EntityOwnership");
      return defineComponent(
        world,
        {
          balance: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    EntityMarketplaceSell: (() => {
      const tableId = new TableId("", "EntityMarketplac");
      return defineComponent(
        world,
        {
          unitPrice: RecsType.BigInt,
          amount: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    StakingRecord: (() => {
      const tableId = new TableId("", "StakingRecord");
      return defineComponent(
        world,
        {
          assetAmountProcessed: RecsType.BigInt,
          shareBalance: RecsType.BigInt,
          shareUnlocked: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    DeFi: (() => {
      const tableId = new TableId("", "DeFi");
      return defineComponent(
        world,
        {
          contractAddress: RecsType.String,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    DeFiSingleton: (() => {
      const tableId = new TableId("", "DeFiSingleton");
      return defineComponent(
        world,
        {
          totalAssetAmount: RecsType.BigInt,
          totalShareAmount: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
  };
}
