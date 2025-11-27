.filters
| to_entries[] | .key as $index  # Способ получения нумерации
| .value
| .domains as $domains
| .title as $title
| .selector_groups
| (
    if ($index != 0) then
        "\n" + "! " + $title + " (" + ($domains | join(", ")) + ")"
    else
        "! " + $title + " (" + ($domains | join(", ")) + ")"
    end
),
($domains | join(",")) + "##" + to_entries[].value.selectors[].selectors[]