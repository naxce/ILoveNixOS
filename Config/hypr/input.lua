hl.config({
    input = {
        kb_layout  = "pl",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse       = 1,
        mouse_refocus      = true,
        sensitivity        = -0.5,
        numlock_by_default = true,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            tap_to_click         = true,
            scroll_factor        = 0.8,
        },
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
        focus_preferred_method   = 0,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
