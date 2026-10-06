# Native capture provenance

These twelve iPhone/iPad screenshots were restored from the successful CI build job for app-code commit `dee2d3691e6cbf0ddaef3be037ad1aa15b78352c`.

- Run: https://github.com/lanray07/PipeBoss-AI/actions/runs/37407322146
- Build job: 112087647023
- Reader: `tools/read-ci-screenshots.mjs`, which validates all twelve PNG payloads and SHA-256 checksums.
- Captures show actual SwiftUI app views with the repository's Debug-only screenshot fixtures. Those fixtures are absent from the signed Release app.
- The four screenshot marketing panels use dashboard, diagnosis, tools and result. Full captured viewports are placed on new RGB marketing canvases; app content is not redrawn or generated.
- Duo outer compositions use the iPhone capture; Duo inner compositions use the iPad capture to show the responsive app interface. These are not native Duo Simulator captures or evidence of physical Duo compatibility.

The owner requested translated marketing captions in all fifty App Store locales. The app interface stays English, disclosed in the footer. Listing metadata is not translated by this workflow.
