function DemoIGA_Laplace2D
clc; clear; close all;

%% Include package
import Utility.BasicUtility.*
import Geometry.*
import Domain.*
import Operation.*

%% Geometry data input
xml_path = './ArtPDE_IGA_Lens_bottom_left.art_geometry';
% ArtPDE_IGA_Lens_bottom_left; ArtPDE_IGA_Plane4_refined
geo = GeometryBuilder.create('IGA', 'XML', xml_path);
nurbs_topology = geo.topology_data_{1};

%% Domain create
iga_domain = DomainBuilder.create('IGA');

%% Basis create
nurbs_basis = iga_domain.generateBasis(nurbs_topology);

%% Nurbs tools create
nurbs_tool = NurbsTools(nurbs_basis);

nurbs_data = nurbs_topology.domain_patch_data_.nurbs_data_;
t_1 = linspace(nurbs_data.knot_vectors_{1}(1), nurbs_data.knot_vectors_{1}(end), 11);
t_2 = linspace(nurbs_data.knot_vectors_{2}(1), nurbs_data.knot_vectors_{2}(end), 10);

nurbs_tool.knotInsertion({t_1(2:end-1) t_2(2:end-1)});

%% Variable define   
var_t = iga_domain.generateVariable('temperature', nurbs_basis,...
                                    VariableType.Scalar, 1);      
%% Test variable define
test_t = iga_domain.generateTestVariable(var_t, nurbs_basis);

%% Set domain mapping - > physical domain to parametric domain
iga_domain.setMapping(nurbs_basis);

%% Operation define (By User)
operation1 = Operation();
operation1.setOperator('grad_test_dot_grad_var');

%% Expression acquired
exp1 = operation1.getExpression('IGA', {test_t, var_t});

%% Integral variation equations
% Domain integral
doamin_patch = nurbs_topology.getDomainPatch();
iga_domain.calIntegral(doamin_patch, exp1);

%% Constraint (Acquire prescribed D.O.F.)


bdr_patch = nurbs_topology.getBoundayPatch('xi_1');
iga_domain.generateConstraint(bdr_patch, var_t, {1, @()0});

bdr_patch = nurbs_topology.getBoundayPatch('eta_0');
iga_domain.generateConstraint(bdr_patch, var_t, {1, @()0});

bdr_patch = nurbs_topology.getBoundayPatch('eta_1');
iga_domain.generateConstraint(bdr_patch, var_t, {1, @()0});

bdr_patch = nurbs_topology.getBoundayPatch('xi_0');
iga_domain.generateConstraint(bdr_patch, var_t, {1, @()1});
%% Nurbs tools create & plot nurbs
import Utility.NurbsUtility.NurbsTools
nurbs_tool = NurbsTools(nurbs_basis);

figure; hold on; grid on; axis equal;
nurbs_tool.plotNurbs();
nurbs_tool.plotControlMesh();

% control_point = doamin_patch.nurbs_data_.control_points_(:,1:3);
% xlabel('x'); ylabel('y'); zlabel('z'); 
% for i = 1:size(control_point,1)
%     text(control_point(i,1), control_point(i,2), control_point(i,3), num2str(i), 'FontSize',14);
% end

hold off;
%% Solve domain equation system
iga_domain.solve('default');

%% Data Interpolation
import Interpolation.IGA.Interpolation;
t_interpo = Interpolation(var_t);
[x, data, element] = t_interpo.DomainDataSampling();

%% Show result (Post-Processes)
fv.vertices = [x(:,1:2), data.value{1}];
fv.faces = element;
fv.facevertexcdata = data.value{1};

figure; hold on; grid on; axis equal;
patch(fv,'CDataMapping','scaled','EdgeColor',[.7 .7 .7],'FaceColor','interp','FaceAlpha',1);
title('ArtPDE Laplace problem... (IGA)')
view([0 90]);
hold off;
%% Show result
disp(var_t);
end
