# Automation-Grid-3 MVP Project Plan

## Goal

Build a multiplayer, 3D procedural factory-building game in Godot 4.
**Focus:** Ground-up multiplayer architecture, terrain generation, building placement, and basic resource processing.
**Deferred:** Events, Weather, Enemies, Tech Tree.

## Architecture Overview

- **Engine:** Godot 4.x (GDScript)
- **Networking:** High-Level Multiplayer API (`ENetMultiplayerPeer`).
  - **Topology:** Listen Server (Host plays and serves).
  - **Authority:** Server-authoritative for game state (terrain, buildings, inventory). Client-side prediction for player movement.
- **Terrain:** Voxel-style or Heightmap-based blocky terrain using `FastNoiseLite`.
  - **Optimization:** Chunks (e.g., 16x16 or 32x32), Multithreaded mesh generation using `RenderingServer` or `SurfaceTool`.
- **Data Structure:**
  - `WorldMap`: Dictionary/HashMap storing `GridCoordinate -> TileData/BuildingData`.

## Directory Structure

```text
res://
├── assets/              # Models, Textures, Materials
├── src/
│   ├── autoload/        # Global singletons (NetworkManager, GameState)
│   ├── core/            # Base classes, Data definitions (ItemResource, BuildingResource)
│   ├── player/          # PlayerController, Camera, Interaction
│   ├── terrain/         # ChunkManager, TerrainGenerator, VoxelMesher
│   ├── buildings/       # FactoryEntity, Belts, Drills
│   ├── ui/              # MainMenu, HUD, InventoryUI
│   └── main/            # Main game scene, Lobby scene
└── resources/           # ScriptableObjects/Resources (Items, Recipes)
```

## Phase 1: Networking Foundation (Priority: High)

_Objective: Establish a stable connection loop where players can join a shared space._

1. **NetworkManager Autoload:** Handle `ENetMultiplayerPeer` creation, hosting, joining, and connection signals.
2. **Lobby UI:** Simple buttons for "Host" and "Join (IP)".
3. **Level Spawner:** System to spawn the "Game World" scene and player pawns for connected peers.
4. **Sync Test:** Verify players can see each other move (using `MultiplayerSynchronizer`).

## Phase 2: Procedural Terrain (Priority: High)

_Objective: Generate a synchronized world._

1. **Data Model:** Define `Chunk` size and storage.
2. **Generation:** Implement `TerrainGenerator` using `FastNoiseLite`.
   - **Optimization:** Run noise calculations and mesh generation on a background thread.
3. **Replication:**
   - Server sends **Seed** to clients.
   - Clients generate geometry locally based on the seed (bandwidth efficient).
   - _Note:_ If terrain is editable later, we will need delta-compression for chunk updates. For MVP (non-editable terrain), Seed syncing is sufficient.
4. **Biomes:** Map noise values to Biome types (Forest, Desert, Snow) and assigning colors/materials.

## Phase 3: Player & Interaction

_Objective: Player navigation and world interaction._

1. **CharacterBody3D:** FPS or TPS controller.
2. **Replication:** Sync Position/Rotation.
3. **Interaction:** Raycast system to detect:
   - Terrain (for building placement).
   - Existing Buildings (for UI/Config).

## Phase 4: Building System (The Core)

_Objective: Place structures on the grid._

1. **Grid System:** Global grid coordinate system (int Vector3).
2. **Building Definitions:** `Resource` files defining:
   - Name, Model, Footprint (1x1, 2x2), Cost.
3. **Placement Logic:**
   - **Client:** Shows "Ghost" building. Checks local validity (collision, cost). Sends `RPC_RequestBuild` to server.
   - **Server:** Validates request (distance, cost, space). Updates `WorldMap`. Spawns actual entity.
   - **Replication:** Server spawns the `Building` node using `MultiplayerSpawner` so all clients see it.

## Phase 5: Resource & Automation Loop

_Objective: Harvest and Process._

1. **Resources:** Define `Item` resources (Iron Ore, Iron Ingot).
2. **Resource Nodes:** Specific terrain blocks or objects that contain infinite/finite resources.
3. **Extractor (Drill):** A building that:
   - Checks terrain below it.
   - Generates items into its internal inventory every N seconds.
4. **Inventory System:** Simple component for Players and Buildings.
5. **Tick System:** A centralized `TickManager` (Server only) to update factories.
   - _Why?_ Godot `_process` varies per frame. Factories need deterministic 1-second or 0.5-second ticks.

## Phase 6: UI & Polish

1. **HUD:** Hotbar for selecting buildings.
2. **Inventory UI:** Window to see player items.
3. **Building UI:** Window to see machine contents/configure it.

---

## Technical Constraints & Standards

- **Coding Style:** GDScript with static typing (`var x: int`) strongly preferred.
- **Commits:** Atomic commits per feature.
- **Testing:** Test multiplayer locally using Godot's "Run 2 instances" debug feature.
