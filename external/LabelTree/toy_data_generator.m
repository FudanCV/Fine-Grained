function varargout = toy_data_generator(varargin)
% TOY_DATA_GENERATOR MATLAB code for toy_data_generator.fig
%      TOY_DATA_GENERATOR, by itself, creates a new TOY_DATA_GENERATOR or raises the existing
%      singleton*.
%
%      H = TOY_DATA_GENERATOR returns the handle to a new TOY_DATA_GENERATOR or the handle to
%      the existing singleton*.
%
%      TOY_DATA_GENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOY_DATA_GENERATOR.M with the given input arguments.
%
%      TOY_DATA_GENERATOR('Property','Value',...) creates a new TOY_DATA_GENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before toy_data_generator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to toy_data_generator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help toy_data_generator

% Last Modified by GUIDE v2.5 02-Feb-2014 15:59:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @toy_data_generator_OpeningFcn, ...
                   'gui_OutputFcn',  @toy_data_generator_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before toy_data_generator is made visible.
function toy_data_generator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to toy_data_generator (see VARARGIN)

% Choose default command line output for toy_data_generator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes toy_data_generator wait for user response (see UIRESUME)
% uiwait(handles.generator);


% --- Outputs from this function are returned to the command line.
function varargout = toy_data_generator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse press over axes background.
function cordinate_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cordinate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.generator, 'UserData'), 'data')
    label_marker_color_size = get(hObject, 'UserData');
    if isempty(label_marker_color_size) || isempty(label_marker_color_size{1})
        return;
    end
    label = label_marker_color_size{1};
    marker = label_marker_color_size{2};
    color = label_marker_color_size{3};
    markersize = label_marker_color_size{4};
    cp = get(hObject, 'CurrentPoint');
    x = cp(1, 1); y = cp(1, 2);
    line('XData', x, 'YData', y, 'UserData', label, ...
        'Marker', marker, 'MarkerSize', markersize, 'MarkerEdgeColor', color);
% elseif strcmp(get(handles.generator, 'UserData'), 'model_tree')
%     data = get(handles.read_model_tree, 'UserData');
%     if isempty(data)
%         return;
%     end
%     lines = data{1};
%     start = data{2};
%     nary = data{3};
%     h_last = data{4};
%     if ~isempty(h_last)
%         delete(h_last);
%         if start > size(lines, 2) - nary + 1
%             set(handles.read_model_tree, 'UserData', {});
%             set(handles.generator, 'UserData', 'data');
%             return;
%         end
%     end
%     h_last = zeros(nary + 1, 1);
%     [X, Y] = meshgrid(0:0.01:1, 0:0.01:1);
%     X = reshape(X, [], 1);
%     Y = reshape(Y, [], 1);
%     scores = zeros(size(X, 1), nary);
%     for i = start : start + nary - 1
%         fprintf('hyperplane: %g * x + %g * y + %g = 0\n', ...
%             lines(:, i));
%         w = lines(1:2, i);
%         b = lines(3, i);
%         if w(1) > w(2)
%             y = 0 : 1;
%             x = ( - b - w(2) .* y) ./ w(1);
%         else
%             x = 0 : 1;
%             y = ( - b - w(1) .* x) ./ w(2);
%         end
%         fprintf('line: (%g, %g) -- (%g, %g)\n', x(1), y(1), x(2), y(2));
%         h_last(i - start + 1) = line('XData', x, 'YData', y);
%         scores(:, i - start + 1) = sum(bsxfun(@times, [X, Y], w'), 2) + b;
%     end
%     [~, label] = max(scores, [], 2);
%     h_last(nary + 1) = scatter(X, Y, 24, label);
%     start = start + nary;
%     set(handles.read_model_tree, 'UserData', {lines, start, nary, h_last});
elseif strcmp(get(handles.generator, 'UserData'), 'model')
    data = get(handles.read_model, 'UserData');
    W = data{1};
    i = data{2};
    h_line = data{3};
    intv = str2double(get(handles.edit_intv, 'String'));
    if i > size(W, 1)
        set(handles.generator, 'UserData', 'data');
        delete(h_line);
        set(handles.edit_intv, 'String', '0.001');
        return;
    end
    if intv > 0
        for h = i : size(W, 1)
            fprintf('hyperplane: %g * x + %g * y + %g = 0\n', W(h, 1:3));
            w1 = W(h, 1); w2 = W(h, 2); b = W(h, 3);
            if w1 ~= 0 && w2 / w1 > -1 && w2 / w1 < 1
                y = 0 : 1;
                x = (- b - w2 .* y) ./ w1;
                y_neg_margin = 0 : 1;
                x_neg_margin = (- 1 - b - w2 .* y_neg_margin) ./ w1;
                y_pos_margin = 0 : 1;
                x_pos_margin = (1 - b - w2 .* y_pos_margin) ./ w1;
            else
                x = 0 : 1;
                y = (- b - w1 .* x) ./ w2;
                x_neg_margin = 0 : 1;
                y_neg_margin = (- 1 - b - w1 .* x_neg_margin) ./ w2;
                x_pos_margin = 0 : 1;
                y_pos_margin = (1 - b - w1 .* x_pos_margin) ./ w2;
            end
            fprintf('line %d: (%g, %g) -- (%g, %g)\n', h, x(1), y(1), x(2), y(2));
            new_h_line(1) = line(x, y, 'LineWidth', 1.5);
            new_h_line(2) = line(x_neg_margin, y_neg_margin, 'LineWidth', 1, 'LineStyle', '--');
            new_h_line(3) = line(x_pos_margin, y_pos_margin, 'LineWidth', 1, 'LineStyle', '--');
            delete(h_line);
            pause(intv / 1000);
            h_line = new_h_line;
        end
        i = size(W, 1);
        set(handles.edit_intv, 'String', '0');
    else
        fprintf('hyperplane: %g * x + %g * y + %g = 0\n', W(i, 1:3));
        w1 = W(i, 1); w2 = W(i, 2); b = W(i, 3);
        if w1 ~= 0 && w2 / w1 > -1 && w2 / w1 < 1
            y = 0 : 1;
            x = (- b - w2 .* y) ./ w1;
            y_neg_margin = 0 : 1;
            x_neg_margin = (- 1 - b - w2 .* y_neg_margin) ./ w1;
            y_pos_margin = 0 : 1;
            x_pos_margin = (1 - b - w2 .* y_pos_margin) ./ w1;
        else
            x = 0 : 1;
            y = (- b - w1 .* x) ./ w2;
            x_neg_margin = 0 : 1;
            y_neg_margin = (- 1 - b - w1 .* x_neg_margin) ./ w2;
            x_pos_margin = 0 : 1;
            y_pos_margin = (1 - b - w1 .* x_pos_margin) ./ w2;
        end
        fprintf('line %d: (%g, %g) -- (%g, %g)\n', i, x(1), y(1), x(2), y(2));
        new_h_line(1) = line(x, y, 'LineWidth', 1.5);
        new_h_line(2) = line(x_neg_margin, y_neg_margin, 'LineWidth', 1, 'LineStyle', '--');
        new_h_line(3) = line(x_pos_margin, y_pos_margin, 'LineWidth', 1, 'LineStyle', '--');
        delete(h_line);
    end
    set(handles.read_model, 'UserData', {W, i+1, new_h_line});
end
    



% fprintf('hyperplane: %g * x + %g * y + %g = 0\n', lines(:, i));
% if w(1) > w(2)
%     y = 0 : 1;
%     x = ( - b - w(2) .* y) ./ w(1);
% else
%     x = 0 : 1;
%     y = ( - b - w(1) .* x) ./ w(2);
% end
% fprintf('line: (%g, %g) -- (%g, %g)\n', x(1), y(1), x(2), y(2));
% h_line(num_of_nodes) = ...
%     line('XData', x, 'YData', y, 'Visible', 'off');



function editlabel_Callback(hObject, eventdata, handles)
% hObject    handle to editlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
label = get(hObject, 'String');
if isnan(label)
    return;
end
label_marker_color_size = get(hObject, 'UserData');
ind = find(strcmp(label, label_marker_color_size(:, 1)), 1);
if isempty(ind)
    ind = find(cellfun(@isempty, label_marker_color_size(:,1)), 1);
    if isempty(ind)
        labelrgb_new = cell(2*size(label_marker_color_size,1), size(label_marker_color_size,2));
        labelrgb_new(1:size(label_marker_color_size,1), :) = label_marker_color_size;
        labelrgb_new(size(label_marker_color_size,1)+1:end, 2:4) = label_marker_color_size(:, 2:4);
        ind = size(label_marker_color_size, 1) + 1;
        label_marker_color_size = labelrgb_new;
    end
    label_marker_color_size{ind, 1} = label;
    set(hObject, 'UserData', label_marker_color_size);
end
set(handles.cordinate, 'UserData', label_marker_color_size(ind, :));


% Hints: get(hObject,'String') returns contents of editlabel as text
%        str2double(get(hObject,'String')) returns contents of editlabel as a double


% --- Executes during object creation, after setting all properties.
function editlabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
label_marker_color_size = cell(13 * 8, 4);
all_markers = cell(13, 1);
all_markers{1} = '+'; all_markers{2} = 'o'; all_markers{3} = '*';
all_markers{4} = '.'; all_markers{5} = 'x'; all_markers{6} = 's';
all_markers{7} = 'd'; all_markers{8} = '^'; all_markers{9} = 'v';
all_markers{10} = '>'; all_markers{11} = '<'; all_markers{12} = 'p';
all_markers{13} = 'h';
all_colors = cell(8, 1);
all_colors{1} = 'y'; all_colors{2} = 'm'; all_colors{3} = 'c';
all_colors{4} = 'r'; all_colors{5} = 'g'; all_colors{6} = 'b';
all_colors{7} = 'w'; all_colors{8} = 'k';
for i = 1 : length(label_marker_color_size)
    marker = all_markers{mod(i, length(all_markers)) + 1};
    color = all_colors{mod(i, length(all_colors)) + 1};
    label_marker_color_size{i, 2} = marker;
    label_marker_color_size{i, 3} = color;
    if marker == '.'
        markersize = 24;
    else
        markersize = 12;
    end
    label_marker_color_size{i, 4} = markersize;
end
set(hObject, 'UserData', label_marker_color_size);


% --- Executes on button press in savedata.
function savedata_Callback(hObject, eventdata, handles)
% hObject    handle to savedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uiputfile('../data.txt', '生成数据文件');
dots = findobj(handles.cordinate, 'Type', 'line');
if isempty(dots) || isempty(filename)
    return;
end
file = fopen([path,filename], 'w');
if file == -1
    return;
end
X = zeros(2, length(dots));
Y = zeros(1, length(dots));
for i = length(dots) : -1 : 1
    x = get(dots(i), 'XData');
    y = get(dots(i), 'YData');
    label = get(dots(i), 'UserData');
    fprintf(file, '%s 1:%f 2:%f\n', label, x, y);
    X(:, i) = [x; y];
    Y(i) = str2num(label);
end
save([path,filename, '.mat'], 'X', 'Y');
fclose(file);


% --- Executes during object creation, after setting all properties.
function cordinate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cordinate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate cordinate



function savepath_Callback(hObject, eventdata, handles)
% hObject    handle to savepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savepath as text
%        str2double(get(hObject,'String')) returns contents of savepath as a double


% --- Executes during object creation, after setting all properties.
function savepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cleardata.
function cleardata_Callback(hObject, eventdata, handles)
% hObject    handle to cleardata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dots = findobj(handles.cordinate, 'Type', 'line');
delete(dots);
dots = findobj(handles.cordinate, 'Type', 'hggoup');
delete(dots);
set(handles.cordinate, 'XLimMode', 'manual', 'YLimMode', 'manual', ...
    'XLim', [0 1], 'YLim', [0 1]);


% --- Executes on button press in readdata.
function readdata_Callback(hObject, eventdata, handles)
% hObject    handle to readdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.*', '读取数据文件', '../data');
if path == 0
    return;
end
file = fopen([path, filename], 'r');
if file == -1
    return;
end
label_marker_color_size = get(handles.editlabel, 'UserData');
while ~feof(file)
    tline = fgetl(file);
    label = sscanf(tline, '%s', 1);
    data = sscanf(tline, '%*s %*d:%f %*d:%f');
    x = data(1); y = data(2);
    ind = find(strcmp(label, label_marker_color_size(:,1)), 1);
    if isempty(ind)
        ind = find(cellfun(@isempty, label_marker_color_size(:,1)), 1);
        if isempty(ind)
            labelrgb_new = cell(2*size(label_marker_color_size,1), size(label_marker_color_size,2));
            labelrgb_new(1:size(label_marker_color_size,1), :) = label_marker_color_size;
            labelrgb_new(size(label_marker_color_size,1)+1:end, 2:4) = label_marker_color_size(:, 2:4);
            ind = size(label_marker_color_size, 1) + 1;
            label_marker_color_size = labelrgb_new;
        end
        label_marker_color_size{ind, 1} = label;
        set(handles.editlabel, 'UserData', label_marker_color_size);
    end
    marker = label_marker_color_size{ind, 2};
    color = label_marker_color_size{ind, 3};
    markersize = label_marker_color_size{ind, 4};
    line('XData', x, 'YData', y, 'UserData', label, ...
        'Marker', marker, 'MarkerSize', markersize, 'MarkerEdgeColor', color);
end
fclose(file);


% % --- Executes on button press in read_model_svm_light.
% function read_model_svm_light_Callback(hObject, eventdata, handles)
% % hObject    handle to read_model_svm_light (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% [filename, path] = uigetfile('*.*', '读取线性模型', '../data');
% if path == 0
%     return;
% end
% file = fopen([path, filename], 'r');
% if file == -1
%     return;
% end
% for i = 1 : 9
%     fgetl(file);
% end
% SV = fscanf(file, '%d', 1) - 1;
% fgetl(file);
% b = fscanf(file, '%f', 1);
% fgetl(file);
% xi = zeros(2, SV);
% w = zeros(2, 1);
% for i = 1 : SV
%     alphaiyi = fscanf(file, '%f', 1);
%     xi(:, i) = fscanf(file, '%*d:%f %*d:%f #\n', 2);
%     w = w + alphaiyi * xi(:, i);
% end
% fprintf('hyperplane: %g * x + %g * y = %g\n', w(1), w(2), b);
% if w(1) > w(2)
%     y = 0 : 1;
%     x = (b - w(2) .* y) ./ w(1);
% else
%     x = 0 : 1;
%     y = (b - w(1) .* x) ./ w(2);
% end
% fprintf('line: (%g, %g) -- (%g, %g)\n', x(1), y(1), x(2), y(2));
% set(handles.cordinate, 'XLimMode', 'auto', 'YLimMode', 'auto');
% line(x, y);
% fclose(file);


% --- Executes on button press in read_model.
function read_model_Callback(hObject, eventdata, handles)
% hObject    handle to read_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.*', '读取线性模型', '../data');
if path == 0
    return;
end
set(handles.cordinate, 'XLimMode', 'auto', 'YLimMode', 'auto');
W = dlmread([path, filename]);
fprintf('hyperplane: %g * x + %g * y + %g = 0\n', W(1, 1:3));
w1 = W(1, 1); w2 = W(1, 2); b = W(1, 3);
if w1 ~= 0 && w2 / w1 > -1 && w2 / w1 < 1
    y = 0 : 1;
    x = (- b - w2 .* y) ./ w1;
    y_neg_margin = 0 : 1;
    x_neg_margin = (- 1 - b - w2 .* y_neg_margin) ./ w1;
    y_pos_margin = 0 : 1;
    x_pos_margin = (1 - b - w2 .* y_pos_margin) ./ w1;
else
    x = 0 : 1;
    y = (- b - w1 .* x) ./ w2;
    x_neg_margin = 0 : 1;
    y_neg_margin = (- 1 - b - w1 .* x_neg_margin) ./ w2;
    x_pos_margin = 0 : 1;
    y_pos_margin = (1 - b - w1 .* x_pos_margin) ./ w2;
end
fprintf('line: (%g, %g) -- (%g, %g)\n', x(1), y(1), x(2), y(2));
h_line(1) = line(x, y, 'LineWidth', 1.5);
h_line(2) = line(x_neg_margin, y_neg_margin, 'LineWidth', 1, 'LineStyle', '--');
h_line(3) = line(x_pos_margin, y_pos_margin, 'LineWidth', 1, 'LineStyle', '--');
set(hObject, 'UserData', {W, 2, h_line});
set(handles.generator, 'UserData', 'model');


% --- Executes on button press in toggle_zoom.
function toggle_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value')
    if get(handles.toggle_pan, 'Value')
        pan off;
        set(handles.toggle_pan, 'Value', 0);
    end
    zoom on;
else
    zoom off;
end
% Hint: get(hObject,'Value') returns toggle state of toggle_zoom


% --- Executes on button press in toggle_pan.
function toggle_pan_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value')
    if get(handles.toggle_zoom, 'Value')
        zoom off;
        set(handles.toggle_zoom, 'Value', 0);
    end
    pan on;
else
    pan off;
end
    
% Hint: get(hObject,'Value') returns toggle state of toggle_pan


% % --- Executes on button press in read_model_tree.
% function read_model_tree_Callback(hObject, eventdata, handles)
% % hObject    handle to read_model_tree (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% [filename, path] = uigetfile('*.*', '读取线性模型', '../data');
% if path == 0
%     return;
% end
% file = fopen([path, filename], 'r');
% if file == -1
%     return;
% end
% num_of_nodes = 0;
% while ~feof(file)
%     line_str = fgetl(file);
%     if ischar(line_str)
%         if ~isempty(strfind(line_str, 'LabelTreeNode'))
%             num_of_nodes = num_of_nodes + 1;
%         end
%     end
% end
% set(handles.cordinate, 'XLimMode', 'manual', 'YLimMode', 'manual', ...
%     'XLim', [0 1], 'YLim', [0 1]);
% num_of_nodes = num_of_nodes - 1;
% lines = zeros(3, num_of_nodes);
% num_of_nodes = 0;
% frewind(file)
% while ~feof(file)
%     line_str = fgetl(file);
%     if ischar(line_str)
%         w = sscanf(line_str, '    w        = %g %g', 2);
%         if isempty(w)
%             continue;    
%         end
%         line_str = fgetl(file);
%         b = sscanf(line_str, '    b        = %g', 1);
%         if num_of_nodes == 0
%             line_str = fgetl(file);
%             n_nary = length(regexp(line_str, '\<0x\w{9}\>'));
%             num_of_nodes = num_of_nodes + 1;
%             continue;
%         end
%         lines(:, num_of_nodes) = [w; b];
%         num_of_nodes = num_of_nodes + 1;
%     end
% end
% fclose(file);
% set(hObject, 'UserData', {lines, 1, n_nary, []});
% set(handles.generator, 'UserData', 'model_tree');


% --- Executes on mouse motion over figure - except title and menu.
function generator_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to generator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cp = get(handles.cordinate, 'CurrentPoint');
x = cp(1, 1); y = cp(1, 2);

str = sprintf('坐标：[%.3f, %.3f]', x, y);
set(handles.show_cordinate, 'String', str);


% --- Executes on mouse press over figure background.
function generator_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to generator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_intv_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intv as text
%        str2double(get(hObject,'String')) returns contents of edit_intv as a double


% --- Executes during object creation, after setting all properties.
function edit_intv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_axis.
function save_axis_Callback(hObject, eventdata, handles)
% hObject    handle to save_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uiputfile('../data/', '保存图形');
saveas(handles.cordinate, [path, filename]);
