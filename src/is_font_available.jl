"""
    is_font_available(font_name::AbstractString) -> Bool

Return `true` if a font with the given name can be located by
`FreeTypeAbstraction.findfont`, and `false` otherwise.

This function attempts to resolve `font_name` to an installed font using
FreeTypeAbstraction’s font-discovery mechanism. If the font is found,
`true` is returned. If `findfont` throws an exception—such as when the
font is missing or not registered on the system—the function catches the
error and returns `false`.

# Examples
```julia
julia> is_font_available("Helvetica")
true

julia> is_font_available("NonexistentFontXYZ")
false
"""
function is_font_available(font_name)
    try
        FreeTypeAbstraction.findfont(font_name::String)
        return true
    catch
        return false
    end
end

export is_font_available