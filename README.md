# Target-neutral Android runtime lab

Manual-only GitHub Actions harness for an isolated API 35 Android emulator.
The public tree contains no target name, package, APK, test marker, credential,
or finding. Task input and task logic are supplied as repository secrets, and
the only uploaded result is CMS-encrypted evidence retained for one day.

Safety properties:

- standard public Ubuntu runner only;
- exact pinned third-party action commits;
- read-only repository permission;
- no plaintext task input or evidence artifact upload;
- task payload owns product controls and cleanup;
- runner removes acquired input and plaintext evidence on every exit.

