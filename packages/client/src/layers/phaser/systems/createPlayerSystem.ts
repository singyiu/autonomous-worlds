import { Has, defineEnterSystem, defineSystem, defineUpdateSystem, getComponentValueStrict, hasComponent, setComponent } from "@latticexyz/recs";
import { PhaserLayer } from "../createPhaserLayer";
import { Animations, TILE_HEIGHT, TILE_WIDTH } from "../constants";
import { pixelCoordToTileCoord, tileCoordToPixelCoord } from "@latticexyz/phaserx";

export function createPlayerSystem(layer: PhaserLayer) {
  const {
    world,
    networkLayer: {
      components: {
        Position,
        StakingRecord,
        DeFiSingleton,
      },
      systemCalls: {
        spawn
      },
      playerEntity,
      singletonEntity,
    },
    scenes: {
      Main: {
        objectPool,
        input,
        camera,
        phaserScene,
      },
    },
  } = layer;

  const textControl = phaserScene?.add?.text(-600, -220, "Movement: WASD, Staking: P, Redeem: L");
  const textTVL = phaserScene?.add?.text(-600, -180, "TVL: 0 ETH");

  input.pointerdown$.subscribe((event) => {
    if (playerEntity && hasComponent(Position, playerEntity)) return;

    const x = event.pointer.worldX;
    const y = event.pointer.worldY;

    const position = pixelCoordToTileCoord({ x, y }, TILE_WIDTH, TILE_HEIGHT);
    if (position.x === 0 && position.y === 0) return;

    spawn(position.x, position.y);
  });

  defineEnterSystem(world, [Has(Position)], ({ entity }) => {
    const playerObj = objectPool.get(entity, "Sprite");
    playerObj.setComponent({
      id: 'animation',
      once: (sprite) => {
        sprite.play(Animations.GolemIdle);
      }
    });

    const textObj = objectPool.get(entity+"StakingRecordText", "Text");
    textObj.setComponent({
      id: 'visible',
      once: (text) => {
        text.setVisible(false);
      }
    });
  });

  defineSystem(world, [Has(Position)], ({ entity }) => {
    const position = getComponentValueStrict(Position, entity);
    const pixelPosition = tileCoordToPixelCoord(position, TILE_WIDTH, TILE_HEIGHT);

    const playerObj = objectPool.get(entity, "Sprite");

    playerObj.setComponent({
      id: 'position',
      once: (sprite) => {
        sprite.setPosition(pixelPosition.x, pixelPosition.y);

        /*
        const isPlayer = entity === playerEntity;
        if (isPlayer) {
          camera.centerOn(pixelPosition.x, pixelPosition.y);
        }
        */
      }
    });

    const textObj = objectPool.get(entity+"StakingRecordText", "Text");
    textObj.setComponent({
      id: 'position',
      once: (text) => {
        text.setPosition(pixelPosition.x - 8, pixelPosition.y - 32);
        text.setVisible(true);
      }
    });
  });

  defineSystem(world, [Has(StakingRecord)], ({ entity }) => {
    const stakingRecord = getComponentValueStrict(StakingRecord, entity);
    const textObj = objectPool.get(entity+"StakingRecordText", "Text");
    textObj.setComponent({
      id: 'text',
      once: (text) => {
        text.setText(`S ${stakingRecord.shareBalance}\nU ${stakingRecord.shareUnlocked}`);
      }
    });

    //const defiSingleton = getComponentValueStrict(DeFiSingleton, singletonEntity);
    //textTVL?.setText(`TVL: ${defiSingleton.totalAssetAmount} ETH`);
  });

  defineSystem(world, [Has(DeFiSingleton)], ({ entity }) => {
    const defiSingleton = getComponentValueStrict(DeFiSingleton, singletonEntity);
    textTVL?.setText(`TVL: ${defiSingleton.totalAssetAmount} ETH`);
  });
}