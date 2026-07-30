# Porras AdvMobProg


## Discussion
`setState` is best for local widget state that does not need to be shared. It rebuilds only the widget that owns the state.
`Provider` is better for shared state across multiple widgets or screens. It allows a single source of truth for app-wide state like theme mode.
In this lab, `setState` is used for the counter because the value is local to the counter screen. `Provider` is used for theme switching because the theme should apply across the entire app.

