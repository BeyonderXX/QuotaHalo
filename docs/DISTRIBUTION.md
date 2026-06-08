# Distribution

This guide explains how to publish QuotaHalo so macOS users can open it without a Gatekeeper "damaged" warning.

## Why macOS Says The App Is Damaged

When a `.app` is downloaded from the internet, macOS attaches a quarantine attribute and asks Gatekeeper to verify it.

The app may be blocked as damaged when:

- The app bundle is unsigned or only ad-hoc signed.
- The code signature is incomplete or invalid.
- The app is not notarized by Apple.
- The release asset came from a draft or untagged GitHub release instead of a normal tagged release.

For public releases, use a real tag such as `v0.1.0`, attach `QuotaHalo.app.zip`, and publish a signed and notarized build.

## Build With Ad-Hoc Signing

For local testing:

```bash
scripts/build-app.sh
scripts/package-release.sh
```

The build script signs the bundle ad-hoc when no `CODESIGN_IDENTITY` is provided. This verifies the bundle structure, but it is not enough for a smooth public download.

## Build With Developer ID Signing

Set your Developer ID Application identity:

```bash
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
scripts/build-app.sh
```

Verify the app:

```bash
codesign --verify --deep --strict --verbose=4 dist/QuotaHalo.app
spctl -a -vvv -t exec dist/QuotaHalo.app
```

## Notarize

Create a zip:

```bash
scripts/package-release.sh
```

Submit it to Apple:

```bash
xcrun notarytool submit dist/QuotaHalo.app.zip --keychain-profile QuotaHalo --wait
```

Staple the notarization ticket:

```bash
xcrun stapler staple dist/QuotaHalo.app
```

Repackage the stapled app:

```bash
scripts/package-release.sh
```

Upload this final file to GitHub Releases:

```text
dist/QuotaHalo.app.zip
```

## Temporary User Workaround

Only do this for apps you built yourself or downloaded from a source you trust.

After unzipping and moving the app to `Applications`, a user can remove the quarantine attribute:

```bash
xattr -dr com.apple.quarantine /Applications/QuotaHalo.app
```

Then open the app again.

This is a workaround, not a proper public release process. Signed and notarized builds are the correct fix.
