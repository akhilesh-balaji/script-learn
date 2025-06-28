# define widget colors
const WidgetColor = String
const WIDGET_COLOR_DEFAULT = "default"
const WIDGET_COLOR_ACCENT = "accent"
const WIDGET_COLOR_SUCCESS = "success"
const WIDGET_COLOR_WARNING = "warning"
const WIDGET_COLOR_ERROR = "error"

# create CSS classes for all of the widget colors
for name ∈ [WIDGET_COLOR_DEFAULT, WIDGET_COLOR_ACCENT, WIDGET_COLOR_SUCCESS, WIDGET_COLOR_WARNING, WIDGET_COLOR_ERROR]
    # compile CSS and append it to the global CSS style provider state
    add_css!("""
    $name:not(.opaque) {
        background-color: @$(name)_fg_color;
    }
    .$name.opaque {
        background-color: @$(name)_bg_color;
        color: @$(name)_fg_color;
    }
    """)
end

# function to set the accent color of a widget
function set_accent_color!(widget::Widget, color, opaque = true)
    if !(color ∈ [WIDGET_COLOR_DEFAULT, WIDGET_COLOR_ACCENT, WIDGET_COLOR_SUCCESS, WIDGET_COLOR_WARNING, WIDGET_COLOR_ERROR])
        log_critical("In set_color!: Color ID `" * color * "` is not supported")
    end
    for color_type ∈ [WIDGET_COLOR_DEFAULT, WIDGET_COLOR_ACCENT, WIDGET_COLOR_SUCCESS, WIDGET_COLOR_WARNING, WIDGET_COLOR_ERROR]
        remove_css_class!(widget, color_type)
    end
    add_css_class!(widget, color)
    if opaque
        add_css_class!(widget, "opaque")
    else
        remove_css_class!(widget, "opaque")
    end
end

add_css!("""
.mono, .scripttext, .accent, .success {
    font-size: 1.5em;
}
.scripttextw {
    font-size: 1.5em;
    font-family: serif;
    font-style: italic;
    margin-bottom: -35px;
    padding-left: 7px;
    color: #9C90C5;
}
.thelogo {
    margin-top: -10px;
    margin-bottom: -25px;
}
.scripttext, .headerbar_vary * {
    font-family: Nirmala UI;
}
.modetxt {
    font-style: italic;
}
.mono {
    font-family: monospace;
}
.togglebutton {
    transform: scale(1.3,1);
    margin-left: 10px;
    margin-right: 10px;
}
.invisible {
    opacity: 0;
}
.thewriteup {
    margin-top: 10px;
}
""")