function setActivePanel(panel)
% Highlight the given uipanel in red and record it as the active panel.
% The active panel is stored in the GUI figure's appdata ('activePanel');
% retrieve it with getappdata(guifig,'activePanel').

global guifig

panels = findobj(guifig,'type','uipanel');
if isprop(panel,'BorderColor')
    % R2023a and later: ShadowColor/HighlightColor are deprecated
    set(panels,'BorderType','line','BorderColor',[.5 .5 .5]);
    set(panel,'BorderColor','r');
else
    set(panels,'BorderType','line','HighlightColor',[.5 .5 .5]);
    set(panel,'HighlightColor','r');
end
setappdata(guifig,'activePanel',panel);
