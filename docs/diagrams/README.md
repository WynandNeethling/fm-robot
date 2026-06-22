# Diagrams

Shared infrastructure for the robot layer's d2 diagrams ([d2](https://d2lang.com)):
the palette ([`styles.d2`](styles.d2)), the brand font ([`fonts/`](fonts/)), the
[`render.sh`](render.sh) script, and the repo-level `packages` diagram. Per-package
diagrams live with the package they document, in `<package>/doc/diagrams/`, and
import the palette here with a relative path. Each `.d2` is the source of truth;
the matching `.svg` is the generated artifact the docs reference. Edit the `.d2`,
then re-render.

## Render

```bash
./render.sh          # renders every *.d2 in the repo to its *.svg sidecar
```

`render.sh` finds every `.d2` across the repo — repo-level here plus each package's
`doc/diagrams/` — and renders it in place with the brand font. Needs `d2` on
`PATH`. The font ships in [`fonts/`](fonts/), so rendering is self-contained — no
font install, no personal tooling.

## Font

**Geist Mono** — First Motive's brand monospace ([Vercel](https://github.com/vercel/geist-font),
OFL). Ships as `fonts/GeistMono-VF.ttf`. Mono suits the technical tokens the
diagrams carry (`fm_*`, `*.launch.py`, `ros2_control`).

## Palette

Mirrors firstmotive.ai. Defined once in [`styles.d2`](styles.d2), imported with
`...@styles`.

| Token | Hex | Use |
|-------|-----|-----|
| plum | `#3B3443` | role band, borders, edges |
| lavender | `#B6A5C6` | package band |
| cream | `#E7DDC8` | artifact / node band |
| light text | `#ECE2CF` | text on plum |
| deep | `#342E3B` | text on lavender / cream |

## Block Grammar

Every component is a stacked block built as a `grid-rows` container:

```
┌─────────────────┐  role  — human label (plum)
├─────────────────┤  pkg   — package name (lavender), one colour for all packages
├─────────────────┤  art   — artifact / node (cream)
└─────────────────┘
```

- Blocks without a package (hardware plugins) drop the `pkg` band.
- Node/topic graphs use `node` (plum box) + `topic` (cream pill) instead.
- Layout is ELK (straight orthogonal edges); `direction: right` for fan-in.

## Diagrams

Each diagram lives with the package it documents; this folder holds only the
repo-level `packages` overview. The set narrows from package wiring, through robot
state, to control and hardware.

```
docs/diagrams/
  packages               how the four packages connect — ament deps; fm_robot aggregates, fm_control layers on fm_description

fm_description/doc/diagrams/
  robot_state_publisher  where /robot_description comes from — URDF/xacro → xacro → robot_state_publisher
  view_robot             robot state publishing — joint_state_publisher → robot_state_publisher → /tf · /robot_description
  registry               robot registry — fm_description abstracts g1_d · so101 · openarm (variants + mesh strategy)

fm_control/doc/diagrams/
  control                ros2_control graph — controller_manager ↔ resource_manager → hardware interfaces
  control_robot          simulation — /robot_description + /cmd_vel → Sim control plugin → /joint_states · /tf
  hardware               sim_backend → {mock · mujoco · gazebo · isaac · real} → one ros2_control system interface
  xacro                  URDF composition — {robot}.sim.urdf.xacro → geometry + ros2_control.xacro → <hardware>
```

`hardware` is the architectural crux: everything above the `ros2_control` system
interface is identical across every backend, and the dashed `hardware` block in
`control` expands into it. The per-layer detail lives in each package's README;
the system overview is [ARCHITECTURE.md](../ARCHITECTURE.md). The backend plugins
themselves live in [`fm-sim`](https://github.com/first-motive/fm-sim).
