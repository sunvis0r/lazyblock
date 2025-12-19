.filters
| to_entries[] | .key as $index  # Способ получения нумерации
| .value
| .domains as $domains
| .title as $title
| .selector_groups

# Добавление заголовка:
# ```
# ! Google (google.com)
# ```
| (
    if ($index != 0) then
        "\n" + "! " + $title + " (" + ($domains | join(", ")) + ")"
    else
        "! " + $title + " (" + ($domains | join(", ")) + ")"
    end
),

# Добавление самого фильтра:
# ```
# google.com##footer
# ```
($domains | join(",")) + "##" +
(
    to_entries[].value
    | .super_selector? as $super_selector
    | .selectors[]
    | # Выполняется перемножение матриц (т.е. для каждого подселектора
      # генерируется фильтр с каждым из родительских селекторов).
      ( 
        if $super_selector == null then
            ""
        elif ($super_selector | type) == "array" then
            ($super_selector[] + " ")
        else
            $super_selector + " "
        end
    ) + .selectors[]
)
