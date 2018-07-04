function Demo
clc; clear; close all;

%% Generate domain mesh
domain = DomainBuilder('Mesh');

%% Generate integration rule
integration_rule = IntegrationRule(domain);

%% Generate function space
function_space = FunctionSpace(domain);

%% Define material property
material = MaterialBank('Mooney');

%% Define variables
%u = Variable('displacement', 3);
delta_u = Variable('displacement_increment', 3);

%% Dof manager
dof_manager = DofManager(delta_u, function_space);
%global_id = dof_manager.global_id(function_space.non_zero_basis(1));

%% Boundary & Initial conditions
displacement = zeros(domain.node_number, domain.dim);

% u1 = 0 for Face 6
% u2 = 0 for Face 3
% u3 = 0 for Face 1
% u1 = lambda for Face 4

lambda = 0.1;
prescribed_bc = PrescribedDisplacement([], domain.boundary_connectivity(6,:), [1 1 1 1], [0 0 0 0]);
prescribed_bc = PrescribedDisplacement(prescribed_bc, domain.boundary_connectivity(3,:), [2 2 2 2], [0 0 0 0]);
prescribed_bc = PrescribedDisplacement(prescribed_bc, domain.boundary_connectivity(1,:), [3 3 3 3], [0 0 0 0]);
prescribed_bc = PrescribedDisplacement(prescribed_bc, domain.boundary_connectivity(4,:), [1 1 1 1], lambda*[1 1 1 1]);



%% Assembling
[ residual, tangent_matrix ] = Assembler( integration_rule, function_space, material, dof_manager, displacement );



end

