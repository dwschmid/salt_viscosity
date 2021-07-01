# salt_viscosity
Explore the deformation map of salt. 
Compares different viscosity models and illustrates the impact of the various input parameters.

## Introduction
Rock salt has two viscous deformation mechanisms: dislocation creep and pressure solution. Dislocation creep is a deformation mechanism that is standardly taken into account in the industry. The associated law is nonlinear and is usually taken as a power law. Pressure solution is known to be active in rock salt but it is seldom considered in applications like cavity closure. The associated law is linear. Here, we investigate the relative importance of each deformation mechanism depending on the conditions encountered at depth (temperature, grain size and salt type). We also present two ways of creating a smooth transition between the linear and nonlinear end members: the Carreau and the Ellis model.

## Code
Running the code will produce the following four figures.


### Figure 1 - Viscosity Model Comparison
Figure 1 shows the apparent viscosities as a function of deformation rates for Newtonian, Power Law, Carreau and Ellis viscosities for a specific rock salt. You can see how smoothly the Carreau and Ellis models do the transition between linear and nonlinear behavior. The Carreau model stays much closer to the two asymptotes compared to the Ellis one.

![alt text](/img/img_01.png "Viscosity Model Comparison")

### Figure 2 - Deformation Map
Figure 2 shows the deformation map for a typical Avery Island salt at 60°C. It illustrates how the two underlying deformation mechanisms are influenced by grain size. For small grain sizes under low deviatoric stress pressure solution governs the deformation of salt, whereas for large grain sizes under high deviatoric stress dislocation creep is the dominating deformation mechanism.

![alt text](/img/img_02.png "Deformation Map")

### Figure 3 - Parameter Influence
Figure 3 shows how changing the input parameters affect the constitutive law and the dominance of the two deformation mechanisms. The reference salt is the same as before: a typical Avery Island salt with a grain size of 7.5 mm at 60°C. Apart from the rate of deformation which has a big impact on the apparent viscosities (and deviatoric stresses), the parameter with the second largest impact is grain size. Temperature and the dislocation creep parameters modify the constitutive equation only slightly.

![alt text](/img/img_03.png "Parameter Influence")

### Figure 4 - Transition
Figure 4 shows the dependency of the transition deformation rate and stress on grain size for different temperatures and salt types. Having identified previously that grain size has a large impact on the constitutive law, this figure focuses on the dependency of the transition deformation rates and stress on the other parameters. The figure shows that they are more affected by different dislocation creep parameters than by different temperatures and that these variations are much smaller than the ones induced by different grain sizes.

![alt text](/img/img_04.png "Transition")

### Further Reading
A detailed description of results that are based on this code is published in ["Long term creep closure of salt cavities", 2018, by J.S. Cornet, M. Dabrowski and D. W. Schmid, International Journal of Rock Mechanics and Mining Sciences](https://www.sciencedirect.com/science/article/abs/pii/S1365160917303970). Additional information can be found in the [PhD thesis by Jan Cornet](https://www.duo.uio.no/bitstream/10852/61641/1/Cornet-PhD-2018.pdf).