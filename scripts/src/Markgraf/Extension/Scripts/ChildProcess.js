import { spawnSync } from "node:child_process";

export const spawnSyncImpl = (command) => (args) => () => {
  const r = spawnSync(command, args, { stdio: "inherit" });
  return r.status === null ? -1 : r.status;
};
