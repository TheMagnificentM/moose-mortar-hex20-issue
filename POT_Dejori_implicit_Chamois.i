# ==============================================================================
# 1. GLOBAL PARAMETERS
# ==============================================================================
[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  order = SECOND
[]

[AuxVariables]
  [force_x] 
  []
  [force_y] 
  []
  [force_z] 
  []
[]
# ==============================================================================
# 2. MESH IMPORT
# ==============================================================================
[Mesh]
  patch_update_strategy = auto 
  patch_size = 1

  [file_mesh]
    type = FileMeshGenerator
    file = 'MOOSE_Mesh_POTDejori.e'
  []
[]

# ==============================================================================
# 3. PHYSICS (SOLID MECHANICS)
# ==============================================================================
[Physics]
  [SolidMechanics]
    [Dynamic]
      [volumetric_domain]
        block = '1 2 3'
        strain = SMALL
        add_variables = true
        use_automatic_differentiation = false
        incremental = true
        generate_output = 'stress_xx stress_yy stress_zz vonmises_stress strain_xx strain_yy strain_zz'
        save_in = 'force_x force_y force_z'
        hht_alpha = -0.414214
      []
    []
  []
[]

# ==============================================================================
# 4. MATERIALS (LINEAR ELASTIC)
# ==============================================================================
# [Materials]
#   [elasticity_steel]
#     type = ComputeIsotropicElasticityTensor
#     block = 'steel_anchor steel_supports'
#     youngs_modulus = 200000.0
#     poissons_ratio = 0.3
#   []
#   [density_steel]
#     type = GenericConstantMaterial
#     block = 'steel_anchor steel_supports'
#     prop_names = 'density'
#     prop_values = 7.85e-9
#   []
#   [stress_steel]
#     type = ComputeLinearElasticStress
#     block = 'steel_anchor steel_supports'
#   []

#   # Concrete
#   [elasticity_concrete]
#     type = ComputeIsotropicElasticityTensor
#     block = 'concrete'
#     youngs_modulus = 41069.0 
#     poissons_ratio = 0.15
#   []
#   [density_concrete]
#     type = GenericConstantMaterial
#     block = 'concrete'
#     prop_names = 'density'
#     prop_values = 2.4e-9
#   []
#   [stress_concrete]
#     type = ComputeLinearElasticStress
#     block = 'concrete'
#   []
# []

[Materials]
  [density_steel]
    type = GenericConstantMaterial
    block = 'steel_anchor steel_supports'
    prop_names = 'density'
    prop_values = 7.85e-9
  []
  [density_concrete]
    type = GenericConstantMaterial
    block = 'concrete'
    prop_names = 'density'
    prop_values = 2.4e-9
  []

  [marmot_steel]
    type = ComputeMarmotMaterialHypoElastic
    block = 'steel_anchor steel_supports'
    marmot_material_name = LINEARELASTIC
    marmot_material_parameters = '200000.0 0.3'
  []
  [marmot_concrete]
    type = ComputeMarmotMaterialHypoElastic
    block = 'concrete'
    marmot_material_name = LINEARELASTIC
    marmot_material_parameters = '41069.0 0.15'
  []

  [char_element_length]
    type = ComputeCharacteristicElementLength
  []
  [dstrain_vgt_conv]
    type = ConvertRankTwoTensorToVoigt
    block = '1 2 3'
    tensor = strain_increment
    tensor_voigt = strain_increment_voigt
    shear_components_twice = true
  []
  [stress_conv]
    type = ConvertRankTwoTensorFromVoigt
    block = '1 2 3'
    tensor = stress
    tensor_voigt = stress_voigt
    shear_components_half = false
  []
  [Jacobian_conv]
    type = ConvertRankFourTensorFromVoigt
    block = '1 2 3'
    tensor = Jacobian_mult
    tensor_voigt = dstress_voigt_dstrain_voigt 
    shear_components_half_ij = false
    shear_components_half_kl = false
    tensor_voigt_uses_row_major_layout = false
  []
[]

# ==============================================================================
# 5. FUNCTIONS (AMPLITUDE)
# ==============================================================================
[Functions]
  [smooth_step]
    type = PiecewiseLinear
    x = '0.0 60.0'
    y = '0.0 1.0'
  []
[]

# ==============================================================================
# 6. BOUNDARY CONDITIONS (BCs)
# ==============================================================================
[BCs]
  [pull_steel]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 'load'
    function = smooth_step
    preset = false
  []

  [fix_z_surface]
    type = DirichletBC
    variable = disp_z          
    boundary = 'z_symm'    
    value = 0.0                      
  []
  [fix_x_node]
    type = DirichletBC
    variable = disp_x        
    boundary = 'x_fix'    
    value = 0.0                      
  []

  [foundation_y]
    type = PenaltyDirichletBC
    variable = disp_y
    boundary = 'bc_left_surface bc_right_surface'
    value = 0.0
    penalty = 40
  []
[]

# ==============================================================================
# 7. CONTACT (MORTAR-PENALTY HYBRID)
# ==============================================================================
[Contact]
  [contact_left_stud_vertical]
    primary = 'cont_surf_stl_l_stud_vert'
    secondary = 'cont_surf_conc_l_stud_vert'
    formulation = mortar_penalty
    penalty = 1e5
    model = coulomb
    friction_coefficient = 0.35
  []
  
  [contact_left_head_horizontal]
    primary = 'cont_surf_stl_l_head_horiz'
    secondary = 'cont_surf_conc_l_head_horiz'
    formulation = mortar_penalty
    penalty = 1e5
    model = coulomb
    friction_coefficient = 0.35
  []
  
  [contact_left_head_vertical]
    primary = 'cont_surf_stl_l_head_vert'
    secondary = 'cont_surf_conc_l_head_vert'
    formulation = mortar_penalty
    penalty = 1e5
    model = coulomb
    friction_coefficient = 0.35
  []
  
  [contact_right_stud_vertical]
    primary = 'cont_surf_stl_r_stud_vert'
    secondary = 'cont_surf_conc_r_stud_vert'
    formulation = mortar_penalty
    penalty = 1e5
    model = coulomb
    friction_coefficient = 0.35
  []
  
  [contact_right_head_horizontal]
    primary = 'cont_surf_stl_r_head_horiz'
    secondary = 'cont_surf_conc_r_head_horiz'
    formulation = mortar_penalty
    penalty = 1e5
    model = coulomb
    friction_coefficient = 0.35
  []
  
  [contact_right_head_vertical]
    primary = 'cont_surf_stl_r_head_vert'
    secondary = 'cont_surf_conc_r_head_vert'
    formulation = mortar_penalty
    penalty = 1e5
    model = coulomb
    friction_coefficient = 0.35
  []
[]

# ==============================================================================
# 8. SOLVER SETTINGS (EXECUTIONER)
# ==============================================================================
[Executioner]
  type = Transient

  [Quadrature]
    order = SECOND
  []

  end_time = 60.0

  automatic_scaling = true

  [TimeIntegrator]
    type = NewmarkBeta
    beta = 0.500000
    gamma = 0.914214
  []

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-2
    cutback_factor = 0.5
    growth_factor = 1.5
    optimal_iterations = 10
  []

  dtmax = 0.5
  
  solve_type = 'NEWTON'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type -snes_linesearch_type'
  petsc_options_value = 'lu       mumps                      basic'
  
  nl_abs_tol = 1e-3
  nl_rel_tol = 5e-3

  l_max_its  = 100
  nl_max_its = 50
[]

# ==============================================================================
# 9. POST PROCESSORS
# ==============================================================================
[Postprocessors]
  [simulation_time]
    type = PerfGraphData
    section_name = Root
    data_type = TOTAL
  []

  [displacement_u_y]
    type = AverageNodalVariableValue
    variable = disp_y
    boundary = 'displacement_anchor'
  []

  [load_rf_y]
    type = NodalSum
    variable = force_y
    boundary = 'load'
  []

  [nonlinear_iterations]
    type = NumNonlinearIterations
  []

  [sum_nonlinear_iterations]
    type = CumulativeValuePostprocessor
    postprocessor = nonlinear_iterations
  []

  [total_increments]
    type = NumTimeSteps
  []
[]

# ==============================================================================
# 10. OUTPUT
# ==============================================================================
[Outputs]
  exodus = true
  print_linear_residuals = false
  csv = true

  [console]
    type = Console
    output_file = true
  []

  [pgraph]
    type = PerfGraphOutput
    execute_on = 'final'
    level = 2
  []
[]