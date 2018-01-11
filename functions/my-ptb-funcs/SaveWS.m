vars = whos;
vars = cellstr({vars.name});
for var = vars
    ws.(var{1}) = eval(var{1});
end