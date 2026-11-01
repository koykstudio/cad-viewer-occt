# Open CASCADE Technology source for CAD Viewer

CAD Viewer (KoykStudio, Microsoft Store, package `KoykStudio.CADViewerDWGDXFSTEPSTLViewerandConverte`) opens STEP,
IGES and BREP files with **Open CASCADE Technology (OCCT) 7.9.3**, used under the **GNU Lesser General Public License
2.1 with the OCCT exception** (`LICENSE-LGPL-2.1.txt`, `OCCT_LGPL_EXCEPTION.txt`).

This repository is where we provide the source of the OCCT we ship, as the licence asks.

## What we ship

- OCCT 7.9.3, **unmodified**: upstream tag [`V7_9_3`](https://github.com/Open-Cascade-SAS/OCCT/releases/tag/V7_9_3).
  The source archive is attached to this repository's release **OCCT 7.9.3**
  (`V7_9_3.tar.gz`, SHA-256 `5ecf094ec6b12d5413dfb851d8c3590c354058aee556e32e408bdfbf8c357d57`,
  identical to GitHub's archive of that tag).
- Built for Windows x64 and ARM64 with `build/build-occt.ps1` (CMake, Ninja, MSVC 14.44; toolkits only, no
  visualization, FreeType, Tcl/Tk, TBB, VTK or RapidJSON).
- The DLLs are installed as separate files in the app's `occt\` folder and loaded dynamically by our own bridge
  (`OcctBridge.dll`, a "work that uses the library"; not part of this source offer).

## Using your own build

CAD Viewer can load a modified OCCT: build it (for example with `build/build-occt.ps1` and your changes), then in the
app choose **Settings > Advanced > Use my own Open CASCADE build** and pick the folder with `TKernel.dll` and the
other toolkits. The app checks the version when a model opens.

## Contact

support@koykstudio.com. This offer is valid for at least three years after the last version of CAD Viewer that
includes this OCCT version.
