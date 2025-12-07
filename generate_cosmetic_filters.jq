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
    | .super_selector as $super_selector
    | .selectors[]
    | (
        if ($super_selector != null) and ($super_selector != "")
        then
            $super_selector + " "
        else
            ""
        end
    ) + .selectors[]
)
