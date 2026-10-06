# `ac_patches` — Self-Hosted Flutter/Dart Over-The-Air (OTA) Patching Platform

A production-grade, fully self-hostable Over-The-Air (OTA) code patching platform for Flutter and Dart, serving as an open, self-hosted alternative to Shorebird.

---

## 🌟 Key Features

* **Multi-Platform Support**: Android (ARM64/x86_64), Windows (x64), Linux, macOS, and iOS.
* **Instant Dart AOT Patching**: Compiles Dart code changes into standalone AOT snapshots in ~5 seconds using `flutter assemble` without rebuilding native C++/Gradle/CMake hosts.
* **100% Self-Hostable**: Simple, lightweight backend built on `AcWeb`, `AcDataDictionary`, `AcSql`, and `AcDataDictionaryAutoApi`.
* **Zero Foreign ORM / Framework Bloat**: No Prisma, Shelf, or Drift; tightly integrated with Autocode ecosystem.
* **Cryptographic Security**: Every patch payload is signed with **Ed25519** and verified using SHA-256 integrity checks before installation.
* **Downgrade Attack Prevention**: Strict monotonic patch sequence enforcement.
* **Automated Crash Protection**: Tracks launch success and failure thresholds. If an OTA patch crashes consecutively (default: 3 times), the runtime automatically purges the bad patch and rolls back to the known-good base release.
* **Staged Rollouts**: Deterministic client-hash-based rollout percentages (1% to 100%) across tracks (`stable`, `beta`).
* **Native Regression Guard**: CLI analyzes project source trees and halts patch compilation if native code (`android/`, `windows/`, Kotlin, Swift, C++, plugins) was modified.

---

## 🏗️ Architecture

The platform is strictly divided into two major layers:

```
                    Developer / CI
                          │
                          ▼
                   ac_patches CLI
                          │
           ┌──────────────┴──────────────┐
           ▼                             ▼
    Flutter Release               Fast Dart AOT
   (Base Store Build)             (5s Assemble)
           │                             │
           └──────────────┬──────────────┘
                          │
                          ▼
                  ac_patches Server
                 (AcWeb + AcSql DAO)
                          │
            ┌─────────────┴─────────────┐
            ▼                           ▼
       Metadata DB               Object Storage
     (PostgreSQL/SQLite)          (MinIO/S3/Disk)
            │
            ▼
     Update Protocol
            │
    ┌───────┴───────┐
    ▼               ▼
 Android         Windows / Desktop
    │               │
    └───────┬───────┘
            ▼
     ac_patches Updater
            │
      Download Patch
            │
    Verify Ed25519 Sig
            │
     Install Pending
            │
         Restart
            │
    Activate on Launch
            │
       Crash Guard
   (Auto-revert if buggy)
```

### Monorepo Structure

```text
ac_patches/
  ├── packages/
  │   ├── ac_patches/            # Umbrella Flutter client plugin & widgets
  │   ├── ac_patches_android/    # Federated Android plugin (AcPatchesActivity & loader)
  │   ├── ac_patches_windows/    # Federated Windows plugin (CMake & C++ loader)
  │   ├── ac_patches_core/       # Shared models, enums, Ed25519 crypto, compatibility
  │   ├── ac_patches_format/     # ACP1 binary archive format, packer & unpacker
  │   └── ac_patches_updater/    # Runtime updater, state manager & crash rollback
  ├── cli/
  │   └── ac_patches_cli/        # Developer CLI tool (`ac_patches`)
  ├── server/
  │   └── ac_patches_server/     # Self-hosted REST backend & storage coordinator
  ├── runtime/
  │   ├── windows/               # C++ runner helper (ac_patches_windows.h)
  │   ├── android/               # Kotlin loader helper (AcPatchesLoader.kt)
  │   ├── linux/                 # Linux GTK helper (ac_patches_linux.h)
  │   └── macos/                 # macOS Swift helper (AcPatchesMacOS.swift)
  ├── templates/
  │   └── github-actions-release-and-patch.yml # CI/CD automation template
  ├── docs/
  │   └── asset_patching_design.md # Asset patching architectural specification
  └── docker/
      ├── Dockerfile             # Multi-stage container build
      └── docker-compose.yml     # Complete self-hosted stack (Server + Postgres + MinIO)
```

---

## 📦 Binary Patch Format (`ACP1`)

Every patch is packaged into an optimized, compact binary envelope:

| Offset | Field | Length | Description |
|---|---|---|---|
| 0 | Magic | 4 bytes | `ACP1` (`0x41 0x43 0x50 0x31`) |
| 4 | Format Version | 2 bytes | Uint16 (`1`) |
| 6 | Compression | 2 bytes | Uint16 (`0` = None, `1` = Gzip) |
| 8 | Manifest Length | 4 bytes | Uint32 length of JSON manifest |
| 12 | Manifest JSON | variable | UTF-8 encoded `AcPatchManifest` |
| ... | Sig Length | 2 bytes | Uint16 (`64`) |
| ... | Signature | 64 bytes | Raw Ed25519 cryptographic signature |
| ... | Payload Length | 8 bytes | Uint64 length of AOT snapshot |
| ... | Payload Bytes | variable | ELF shared library (`app.so`) |

---

## 🚀 Quick Start

### 1. Start the Self-Hosted Server

Using Docker Compose:
```bash
cd ac_patches/docker
docker-compose up -d
```

Or run standalone with SQLite:
```bash
cd ac_patches/server/ac_patches_server
dart run bin/server.dart --port 8080 --db-path ./patches_data.db
```

### 2. Configure Your Flutter App

In your Flutter project root:
```bash
# Initialize ac_patches config and generate Ed25519 keys
dart run f:/Packages/AutoCode/Github/autocode-dart/ac_patches/cli/ac_patches_cli/bin/ac_patches.dart init --server-url http://localhost:8080
```

This creates `ac_patches.yaml` and your signing keys (`ac_patches_key.priv` and `ac_patches_key.pub`).

### 3. Build & Register Base Release

```bash
dart run f:/Packages/AutoCode/Github/autocode-dart/ac_patches/cli/ac_patches_cli/bin/ac_patches.dart release windows
```

### 4. Ship an OTA Patch

When you make changes to your Dart application code:
```bash
# Compiles AOT snapshot in ~5s, signs with Ed25519, packs ACP1, uploads & publishes
dart run f:/Packages/AutoCode/Github/autocode-dart/ac_patches/cli/ac_patches_cli/bin/ac_patches.dart patch windows --publish --rollout 100
```

### 5. Client Integration

Add `ac_patches` to your `pubspec.yaml`:

```yaml
dependencies:
  ac_patches:
    path: path/to/ac_patches
```

In `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ac_patches/ac_patches.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize runtime updater
  await AcPatches.instance.initialize(
    serverUrl: 'http://localhost:8080',
    appId: 'com.example.myapp',
    releaseId: '1.0.0+1',
    buildNumber: 1,
    baseReleaseHash: 'sha256:...',
    publicKeyBase64: '<YOUR_PUBLIC_KEY>',
    platform: AcEnumPatchPlatform.windows,
    architecture: AcEnumPatchArchitecture.x86_64,
    patchesDirectory: Directory('./patches'),
  );

  // Confirm healthy launch (resets crash counter)
  await AcPatches.instance.markHealthy();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AcPatchAutoUpdater(
      autoDownload: true,
      onDownloadComplete: (state) {
        print('Patch downloaded! Will activate on next restart.');
      },
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}
```

---

## 🛠️ CLI Reference

| Command | Description |
|---|---|
| `ac_patches doctor` | Diagnoses Flutter SDK, Dart SDK, keys, and server connectivity |
| `ac_patches init` | Initializes project configuration and Ed25519 signing keys |
| `ac_patches keys generate` | Generates a new Ed25519 cryptographic key pair |
| `ac_patches release <platform>` | Builds base release binary and registers release with server |
| `ac_patches patch <platform>` | Fast-compiles Dart AOT, signs, packs, and uploads OTA patch |
| `ac_patches publish` | Promotes an uploaded patch to a track with staged rollout |
| `ac_patches rollback` | Rolls back a track to a previous patch or base release |
| `ac_patches status` | Displays active releases, tracks, patch deployments, and telemetry |
| `ac_patches inspect` | Inspects an ACP1 archive and verifies its cryptographic signature |

---

## 🛡️ Crash Protection & Rollback Guarantee

1. Every time a patched app launches, the failure counter increments in atomic persistent storage.
2. Once the Flutter UI renders and passes basic checks, `AcPatches.instance.markHealthy()` is called, resetting the counter to 0.
3. If an OTA patch introduces a fatal startup crash before `markHealthy()` is reached across 3 consecutive launches, the runtime automatically removes `patches/active/app.so` and falls back safely to the base store release.
