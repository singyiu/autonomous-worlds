import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import { Direction } from "../layers/phaser/constants";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { worldSend }: SetupNetworkResult,
  { }: ClientComponents
) {
  const spawn = (x: number, y: number) => {
    worldSend("spawn", [x, y]);
  };

  const move = (direction: Direction) => {
    worldSend("move", [direction]);
  }

  const stakingDeposit = () => {
    worldSend("stakingDeposit", [{value: 1000}]);
  }

  const stakingRedeem = () => {
    worldSend("stakingRedeem", [200]);    
  }

  return {
    spawn,
    move,
    stakingDeposit,
    stakingRedeem,
  };
}
