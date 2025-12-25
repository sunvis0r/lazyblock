.filters
| to_entries[] | .key as $index | .value  # Способ получения нумерации

# Итерируемся по каждому сайту.

# Инициализация и переинициализация переменных.
| .title as $title
| .domains as $domains

| .selector_groups

# Добавление заголовка:
# ```
# ! Google (google.com)
# ```
| (
    (if ($index != 0) then "\n" else "" end) +
    "! " + $title + " (" + ($domains | join(", ")) + ")"
),

# Итерируемся по каждой группе фильтров.

# Добавление самого фильтра:
# ```
# google.com##footer
# ```
(
    to_entries[].value |
    
    # Инициализация и переинициализация переменных.
    .super_selector? as $super_selector |
    (if ((has("redefine_domains")) and
        (.redefine_domains | type == "array") and
        (.redefine_domains != "") and
        (.redefine_domains | length > 0)
       )
    then
        .redefine_domains
    else
        $domains
    end) as $domains |
    
    ($domains | join(",")) + "##" +
    
    # Итерируемся по каждому селектору.
    (
        .selectors[]
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
)