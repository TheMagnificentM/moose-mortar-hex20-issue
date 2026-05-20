# MOOSE Mortar Penalty Contact Anomaly with HEX20 Elements

This repository contains a two short examples and visualization data demonstrating unexpected behavior when using second-order (HEX20) elements with mortar penalty contact in MOOSE.

## Problem Description
I am modeling a standard **pull-out test** involving steel and concrete interfaces. 
Initially, standard Mortar Contact using Lagrange Multipliers was tested, but it consistently led to severe convergence issues. Therefore, the setup was switched to `Mortar-Penalty-Contact`.

### Element Type Comparison (The Core Issue)
* **HEX8 Elements (Works correctly):** When the exact same setups are simulated using linear 8-node hexahedral elements (`HEX8`), the contact behaves exactly as expected. The steel and concrete interfaces separate and lift off from each other cleanly without any numerical issues.
* **HEX20 Elements (Anomalous behavior):** When switching to second-order 20-node hexahedral elements (`HEX20`), an anomaly occurs at the contact interfaces:
  * The **mid-side nodes** at the contact surface appear to displace significantly more than the corresponding **corner nodes**.
  * This leads to an unphysical, "wavy" or heavily distorted deformation profile along the contact interface, instead of a clean separation.

## Repository Structure & Contents
The repository is organized to show that the issue is independent of the chosen material model. 

### Folders
* **`mesh/`**: Contains the common Exodus mesh file used for the simulations.
* **`mortar_linear-moose-material/`**: Contains the input file using MOOSE's built-in linear elastic material, the simulation output files, and a load-displacement curve.
* **`mortar_linear-external-material/`**: Contains the input file using an external linear material provided by the material modeling toolbox MARMOT via the Chamois interface, along with its output files and load-displacement curve.

### Screenshots / Images
To visualize the issue, several screenshots from ParaView are included directly in the repository root:

**1. Global Displacement Overviews:**
* `displacement_linear-moose-material.png` (Built-in MOOSE material)
* `displacement_linear-marmot-material.png` (External MARMOT material)
* `displacement_gradienenhanced-marmot-material.png` (Complex gradient-enhanced concrete model, MARMOT) *(Note: The full input files for this concrete model are not included here as they do not add further value for debugging the contact. However, because concrete deforms significantly more than the linear materials, this image shows the mid-node distortion most clearly).*

**2. Mid-Side Node Distortion (Close-ups):**
These images highlight the unphysical element distortion at the contact interface:
* `linear-moose_mid-node-distortion.png` (Built-in MOOSE material)
* `linear-marmot_mid-node-distortion.png` (External MARMOT material)
* `gradientenhanced-marmot_mid-node-distortion.png` *(Note: The full input files for this concrete model are not included here as they do not add further value for debugging the contact. However, because concrete deforms significantly more than the linear materials, this image shows the mid-node distortion most clearly).*

## Environment & Versions
* **MOOSE Version:** `snapshot-20-10-27-53033-g845befc6fb`
*Note: The external material used in the external setup is provided by the material modeling toolbox [MARMOT](https://github.com/MAteRialMOdelingToolbox/Marmot) and coupled via the [Chamois](https://github.com/matthiasneuner/chamois) interface. They are linked here simply as a reference in case anyone is interested in the source of the other material models.*
