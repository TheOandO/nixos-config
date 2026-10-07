# PDF Reader Project: Context and Progress Guide

Paste this file into a new chat so you don't need to re-explain the project. It covers the project, my setup, what is already built, the decisions made, and what comes next.

## How I want to be helped

- I'm learning as I build. Walk me through code **one script/piece at a time** and explain what each part does, not just working code.
- I'm on **NixOS**, so anything that installs or runs tools should work there (nix-shell, no global installs).
- Check current docs when an API might have changed. I'm on a very recent Expo SDK, and many tutorials are outdated.

## The project

A Kindle-style mobile PDF reader for casual readers, built by me and a friend.

- Import PDFs from the phone, keep them in a local library.
- Read in **book mode** (one page at a time, horizontal swipe) or **scroll mode** (vertical continuous).
- **Exact resume position** (page, mode, zoom, scroll offset, optional text anchor).
- **Position bookmarks**, dark mode, offline use, favorites, recently read.
- Local-first: no account needed for v1. PostgreSQL backend, sync and AI search come later.
- Platforms: Android and iPhone (v1). Web/desktop not required.

Spec stack: React Native + Expo + TypeScript, local storage on device. Backend (friend's part): Node.js + TypeScript, PostgreSQL, Prisma.

### My role: Dev A (Mobile App Lead)

Responsible for: Expo app, PDF import, local library, reader, book mode, scroll mode, resume position, bookmarks, dark mode. Main goal: make the app feel good to use. Do **not** start backend integration yet.

First success target (reached): import a PDF and see it in the library.

### Sprint 1 tasks (from our plan)

1. App screens: LibraryScreen, ReaderScreen, BookmarkScreen, SettingsScreen. Navigation: Library -> Reader, Library -> Settings, Reader -> Bookmarks.
2. PDF import (picker -> copy to app storage -> local record -> show in library).
3. Open PDF in Reader by `documentId`.
4. Reading modes (book/scroll), saved preference.
5. Exact resume position (MVP: page number, mode, progress %, updatedAt; later: scroll offset, zoom, text snippet, page coordinates).
6. Position bookmarks (create, list, open, delete).

### Data models (from the plan)

```ts
type LocalDocument = {
  id: string; title: string; originalFileName: string; localUri: string;
  fileHash?: string; fileSize?: number; pageCount?: number; thumbnailUri?: string;
  dateAdded: string; lastOpenedAt?: string; isFavorite: boolean; isFinished: boolean;
};

type ReaderSettings = {
  defaultReadingMode: "book" | "scroll";
  theme: "light" | "dark" | "system";
  keepScreenAwake: boolean;
  tapZonesEnabled: boolean;
};

type ReadingPosition = {
  id: string; documentId: string; pageNumber: number; progressPercent: number;
  readingMode: "book" | "scroll"; scrollOffsetY?: number;
  pageCoordinateX?: number; pageCoordinateY?: number; zoomScale?: number;
  topVisibleText?: string; updatedAt: string;
};

type Bookmark = {
  id: string; documentId: string; label?: string; pageNumber: number;
  readingMode: "book" | "scroll"; scrollOffsetY?: number;
  pageCoordinateX?: number; pageCoordinateY?: number; zoomScale?: number;
  textPreview?: string; createdAt: string; updatedAt: string;
};
```

## My environment

- OS: **NixOS**. Dev shell via `shell.nix` at the repo root, entered with `nix-shell`.
- Node: I wanted **24.19.0**. `nodejs_24` in nixpkgs gives the latest 24.x, so exact pinning needs a pinned nixpkgs commit (find it on nixhub.io). It currently works for me.
- `shell.nix` is kept out of git using `.git/info/exclude` (a local-only ignore file).
- Example `shell.nix`:

```nix
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [
    nodejs_24
    git
    watchman
  ];

  shellHook = ''
    echo "Node $(node --version) ready"
  '';
}
```

- No iPhone, no Mac, and no physical Android phone. Testing happens on an **Android emulator**. iOS testing is not possible for now (a real device build needs a paid Apple Developer account, and the iOS Simulator needs macOS).

### Git and GitHub

- Monorepo: `apps/api` (friend's Node backend) and `apps/mobile` (my Expo app).
- Remote: `AnhTRJotnar/Postgres-Project` on GitHub, over **SSH**. My account is `TheOandO`; the repo belongs to my friend, so I need collaborator access.
- I work on my own branch, **`khanh`**, and merge into `main` through a pull request. If histories are unrelated, merge `origin/main` into my branch first with `--allow-unrelated-histories`.
- SSH setup: ed25519 key added to GitHub, remote URL set with `git remote set-url origin git@github.com:AnhTRJotnar/Postgres-Project.git`.
- Known issue: home-manager's `programs.ssh` created `~/.ssh/config` as a symlink into `/nix/store`, and OpenSSH reported "Bad owner or permissions". Workaround: replace the symlink with a real file (`cp --remove-destination "$(readlink -f ~/.ssh/config)" ~/.ssh/config; chmod 600 ~/.ssh/config`), or stop managing the file with home-manager. The declarative form is `programs.ssh.matchBlocks."*".addKeysToAgent = "yes";`.

## Versions

- **Expo SDK 57** (`expo ~57.0.26`, `expo-file-system ~57.0.7`, `expo-document-picker ~57.0.3`).
- Template: `blank-typescript` (no Expo Router; navigation is React Navigation).
- `expo-file-system` uses the **new class API**: `File`, `Directory`, `Paths`. The old functions (`copyAsync`, `getInfoAsync`, `FileSystem.documentDirectory`, ...) **throw at runtime**. Avoid tutorials that use them. A `expo-file-system/legacy` import still exists.
- Install packages with `npx expo install ...` (not plain `npm install`) so versions match the SDK.
- Storage: `@react-native-async-storage/async-storage` (works in Expo Go). `react-native-mmkv` was skipped because it needs a native build; the repository module hides the storage choice, so swapping later touches one file.

## What is built (all in `apps/mobile`)

Folder layout (feature-based):

```
apps/mobile/
  App.tsx
  src/
    app/navigation/types.ts
    database/repositories/documentRepository.ts
    shared/types/document.ts
    features/
      library/screens/LibraryScreen.tsx
      reader/screens/ReaderScreen.tsx        (placeholder)
      bookmarks/screens/BookmarkScreen.tsx   (placeholder)
      settings/screens/SettingsScreen.tsx    (placeholder)
      import/services/importPdf.ts
```

**Navigation** (`App.tsx`): `NavigationContainer` + `createNativeStackNavigator<RootStackParamList>()` with screens Library, Reader, Bookmarks, Settings. Initial route is Library.

**Route types** (`src/app/navigation/types.ts`):

```ts
export type RootStackParamList = {
  Library: undefined;
  Reader: { documentId: string };
  Bookmarks: { documentId: string };
  Settings: undefined;
};
```

**Storage** (`documentRepository.ts`): AsyncStorage key `"documents"` holds a JSON array of `LocalDocument`. Functions: `getAllDocuments()` and `addDocument(doc)` (new document goes first).

**Import** (`importPdf.ts`):
1. `DocumentPicker.getDocumentAsync({ type: "application/pdf", copyToCacheDirectory: true })`. Return `null` if canceled.
2. Create `Directory(Paths.document, "pdfs")` with `create({ idempotent: true, intermediates: true })`.
3. Copy the picked file to `File(pdfDir, "<uuid>.pdf")` with `await source.copy(destination)`. UUID from `Crypto.randomUUID()` (expo-crypto).
4. Hash with `destination.info({ md5: true }).md5`; if an existing document has the same hash, delete the copy and throw "This PDF is already in your library."
5. Build the `LocalDocument` (`title` = file name without `.pdf`, `localUri` = `destination.uri`, `fileSize` = `destination.size`) and save it.

**Library screen**: `FlatList` of document cards, loaded with `useFocusEffect` + `getAllDocuments()`. An "Import PDF" button calls `importPdf()` and shows errors in an `Alert`. Tapping a card navigates to `Reader` with `{ documentId }`. Empty state: "Your library is empty".

## Current state

Working:
- Navigation between all four screens.
- Importing a PDF: it is copied into app storage, listed in the library, and persists across app restarts. Duplicate detection works.

Not working yet:
- **The Reader only shows the document ID.** Nothing renders the PDF yet.

Done by me outside this guide:
- Cloud development build via EAS Build is finished. (Confirm that `react-native-pdf` and its dependencies were included in that build; a library added after the build needs a new build.)

## Next steps

1. **Emulator.** Set up an Android emulator on NixOS (needs KVM: check `ls -l /dev/kvm`; plan roughly 4 GB RAM and 10 to 15 GB disk). Add the emulator package and a system image through `androidenv` in `shell.nix`. Install the EAS-built `.apk` on it, then run `npx expo start` so the dev build connects to Metro.
2. **PDF viewer.** Use `react-native-pdf` (it also needs `react-native-blob-util`). Verify the versions are compatible with Expo SDK 57 **before** building, since a wrong combination wastes a cloud build.
3. **Reader screen.** Look up the document by `documentId` from the repository, load `localUri` in the viewer, update `lastOpenedAt`, and make going back to the library work.
4. **Reading modes.** Book mode (single page, horizontal swipe, page indicator) and scroll mode (vertical continuous), with a toggle and a saved preference.
5. **Resume position.** MVP first: page number, reading mode, progress %, updatedAt. Save on page change; restore on open. Advanced fields afterwards.
6. **Bookmarks.** Bookmark button in the reader, list screen with open and delete.
7. **Polish.** Dark mode, favorites, recently read, "Continue reading".

## Known pitfalls and notes

- **Stored paths on iOS.** `localUri` stores the absolute path. On iOS the app container path can change after updates, which breaks saved paths. Before shipping, store only the file name (`<id>.pdf`) and rebuild the URI from `Paths.document` when opening.
- **Lines and positions.** PDFs often have no real line numbers, so call the feature "exact reading position", not "exact line". Scanned PDFs can only use page coordinates.
- **Native modules.** `react-native-pdf` and `react-native-mmkv` do not run in Expo Go; they need a development build.
- **NixOS.** Tools like nvm/fnm download binaries that usually don't run on NixOS. Use nixpkgs instead. Local Android builds hit a Gradle `aapt2` problem on NixOS, which is one reason to build in the cloud with EAS.
- **Commands run from the right folder.** `npx expo ...` must run in `apps/mobile` (where `package.json` lives), inside `nix-shell`.
