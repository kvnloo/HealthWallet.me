# HealthWallet — Lane 20 promotion queue

> **Project-local queue, updated October 16, 2026.** This document on a fork-local coordination branch replaces legacy [OSS Factory #79](https://github.com/kvnloo/oss-factory/issues/79). GitHub Issues are disabled in this fork; original PRs, analyses and contributor attribution remain available at their original URLs. This queue is **not** upstream approval, not an app release, and not a real-person health dataset.

## Ready for human fork review

| Priority | Work | Evidence and decision |
| --- | --- | --- |
| P0 | [#1 Documentation: Fasten Onprem and privacy](https://github.com/kvnloo/HealthWallet.me/pull/1), head `bd5bb2732403077b9bca3bc1e7e95774bd46f2b7` | **READY_FOR_HUMAN_REVIEW (fork only):** exact source/documentation checks; [Fasten maintainer statement #629](https://github.com/fastenhealth/fasten-onprem/issues/629) contradicts earlier direct-provider-access claim. Fork PR is non-draft/mergeable. A 2026-10-16 attempt to open an origin PR returned GitHub **403 Resource not accessible by integration**; **no origin PR exists from this work**. Next: human-reviewed origin authorization and a connector with proper origin PR permission; never bypass 403. |

## Needs runtime and requirement proof

| Priority | Work | State / next verification |
| --- | --- | --- |
| P0 | [#2 FHIR reference-range display correction](https://github.com/kvnloo/HealthWallet.me/pull/2), head `e859a0c1b5b9f24889814df9e716133c04596a62` | **CHECK/HOLD:** independent low/high source-unit handling has [hosted standalone Dart CI](https://github.com/kvnloo/HealthWallet.me/actions/runs/38446843326), **not** an actual Flutter app/rendering test. Run 8 existing native Observation cases with permitted dependencies and check missing `unit` vs UCUM `code` and height ft/in labeling before further edits. |
| P1 | [#3 fractional timezone diagnostic](https://github.com/kvnloo/HealthWallet.me/pull/3), head `1b26eb9ab3700529174c1a08e1c0441680642d23`, stacked on #2 | **CHECK/HOLD:** `fhir_r4 0.4.4` fractional-offset defect reproduced in real standalone Dart; fhir-fli maintainers **already fixed it** in `0.6.1`. [Hosted 45/45 plus 10/10 public parser/helper checks](https://github.com/kvnloo/HealthWallet.me/actions/runs/38447032157). App dependency upgrade/API compatibility/Flutter behavior not tested. Do not duplicate original maintainer fix. |
| P1 | Wave 7 `effectivePeriod` period-only date fallback | **LOCAL_ONLY:** source-modelled preview pathway; verify native mapper and desired display policy. View-only share is not persisted import. |
| P1 | Waves 15–16 temporary-share cleanup and filename-collision candidates | **LOCAL_ONLY:** isolated Python-model checks cannot establish native Flutter filesystem behavior. Need bounded native test and lifecycle requirement. |
| P1 | Waves 33–34 FHIR storage ID/cache collision | **LOCAL_ONLY:** modelled SQLite collision is not native Drift evidence. First validate actual DAO/primary-key semantics and migration constraints. |

## Held, existing origin work, and policy

- The original [fhir-fli FHIR R4 version 0.6.1 bug fix](https://pub.dev/packages/fhir_r4/versions/0.6.1/changelog) belongs to its maintainers. Do not present it as new.
- [LifeValue upstream v1.3 PR #69](https://github.com/LifeValue/HealthWallet.me/pull/69) and reporter dev-vinodh's historical iPhone demo-source investigation remain independently owned; preserve reporter dev-vinodh and maintainer alexszilagyi's credit.
- HealthWallet uses GPL-3.0. FHIR/open mHealth, UCUM and LOINC semantics have their own sources; synthetic vectors do not establish medical efficacy or validate device accuracy.
- **No origin-ready app change** until exact source and requirement evidence, native path with negative controls, no overlap with maintainers' work, relevant contribution policy, and explicit scoped human origin-action approval under [factory HITL](https://github.com/kvnloo/oss-factory/blob/main/factory/HITL.md). Linear is retired. No personal data, account pings or implied blanket research consent.

## Trade route and reuse

Local synthetic FHIR input → transparent quality/provenance checks → optional user-owned offline dashboard → separately governed, aggregate-only Evolution Lab research methods. No automatic health score, inference or research export. Keep actual source code and evidence on each implementation PR.

**Update protocol:** Re-check all open fork PRs, reviewer comments, current exact-head CI and upstream duplicates before changing any row. Edit this same file on the `coord/lane20-promotion-queue-20261016` coordination branch; do not open another generic queue or add project details to OSS Factory. The original [factory #79](https://github.com/kvnloo/oss-factory/issues/79) is retained for archival provenance only.
