################################################################################
# Переменные-символы.
################################################################################

override EMPTY :=
override TAB := $(EMPTY)	$(EMPTY)
override SPACE := $(EMPTY) $(EMPTY)
override COMMA := ,
override LPAREN := (
override RPAREN := )
override ESC := 
override TARGET_COLOR := $(ESC)[36m
override NO_COLOR := $(ESC)[0m
override define NEWLINE

$(EMPTY)
endef

################################################################################
# Функции.
################################################################################

# Разукрашивает имя таргета.
# 
# $(1) — имя таргета (опционально).
define colorize_target_name
$(TARGET_COLOR)$(1)$(NO_COLOR)
endef

# Функция для приведения файлового пути DOS / Windows к нормализованному виду.
# Заменяет «/» на «\» и удаляет символ «\» в конце строки если тот её
# оканчивает (за исключением, когда файловым путём является корень диска —
# «C:\», например).
# 
# Функция затратна на вызов: под капотом используется вызов оболочки (SHELL).
# 
# $(1) — путь к элементу файловой системы.
define normalize_dos_path
$(if $(1),,$(error Makefile: при вызове функции «normalize_dos_path» отсутствует обязательный аргумент №1))$(shell $(SET_UNICODE_SNIPPET)$(NEWLINE)SETLOCAL ENABLEDELAYEDEXPANSION$(NEWLINE)SET "str=$(1)"$(NEWLINE)SET "str=!str:/=\!"$(NEWLINE)IF "!str:~-1!" == "\" $(LPAREN)$(NEWLINE)$(TAB)IF NOT "!str:~-2!" == ":\" $(LPAREN)$(NEWLINE)$(TAB)$(TAB)SET "str=!str:~0,-1!"$(NEWLINE)$(TAB)$(RPAREN)$(NEWLINE)$(RPAREN)$(NEWLINE)ECHO !str!)
endef

# Функция для приведения файлового пути Unix / Linux к нормализованному виду.
# Удаляет символ «\» в конце строки если тот её оканчивает
# (за исключением, когда файловым путём яаляется непосредственно корень — «/»).
# 
# Функция затратна на вызов: под капотом используется вызов оболочки (SHELL).
# 
# $(1) — путь к элементу файловой системы.
define normalize_unix_path
$(if $(1),,$(error Makefile: при вызове функции «normalize_unix_path» отсутствует обязательный аргумент №1))$(shell str="$(1)"; case "$$str" in /$(RPAREN) ;; */$(RPAREN) str=$${str%/} ;; esac; echo "$$str")
endef

# Приводит относительный путь к CMD-скрипту к его нормализованному состоянию.
# Например, приводит «json/generate» к «json\generate.cmd».
# 
# Функция затратна на вызов: под капотом вызывается функция «normalize_dos_path».
# 
# $(1) — файловый путь (абсолютный или относительный) к скрипту.
define ensure_cmd_script_filepath
$(if $(1),,$(error Makefile: при вызове функции «ensure_cmd_script_filepath» отсутствует обязательный аргумент №1))$(call normalize_dos_path,$(if $(filter .cmd,$(suffix $(1))),$(1),$(1).cmd))
endef

# Приводит относительный путь к CMD-скрипту к его нормализованному абсолютному
# файловому пути. Например, приводит «json/generate» к
# «C:\project\scripts\json\generate.cmd», где «C:\project» — директория,
# в которой содержится текущий Makefile.
# 
# Функция затратна на вызов: под капотом вызывается функция «normalize_dos_path».
# 
# $(1) — файловый путь (абсолютный или относительный) к скрипту.
define ensure_cmd_script_full_filepath
$(if $(1),,$(error Makefile: при вызове функции «ensure_cmd_script_full_filepath» отсутствует обязательный аргумент №1))$(SCRIPTS_DIR)\$(call ensure_cmd_script_filepath,$(1))
endef

# Приводит относительный путь к shell-скрипту к его нормализованному состоянию.
# Например, приводит «json/generate» к «json/generate.sh».
# 
# Функция затратна на вызов: под капотом вызывается функция «normalize_unix_path».
# 
# $(1) — файловый путь (абсолютный или относительный) к скрипту.
define ensure_sh_script_filepath
$(if $(1),,$(error Makefile: при вызове функции «ensure_sh_script_filepath» отсутствует обязательный аргумент №1))$(call normalize_unix_path,$(if $(filter .sh,$(suffix $(1))),$(1),$(1).sh))
endef

# Приводит относительный путь к shell-скрипту к его нормализованному абсолютному
# файловому пути. Например, приводит «json/generate» к
# «/root/project/scripts/json/generate.sh», где «/root/project» — директория,
# в которой содержится текущий Makefile.
# 
# Функция затратна на вызов: под капотом вызывается функция «normalize_unix_path».
# 
# $(1) — файловый путь (абсолютный или относительный) к скрипту.
define ensure_sh_script_full_filepath
$(if $(1),,$(error Makefile: при вызове функции «ensure_sh_script_full_filepath» отсутствует обязательный аргумент №1))$(SCRIPTS_DIR)/$(call ensure_sh_script_filepath,$(1))
endef

# Функция для вызова скриптов из директории «scripts».
# 
# $(1) — относительный путь к скрипту (относительно директории «$(SCRIPTS_DIR)»).
# Если скрипт находится в поддиректории, рекомендуется в качестве разделителя
# директорий писать символ «/», а не «\». Если текущая ОС — Windows, то
# разделитель будет преобразован в «\».
define run_script
$(if $(1),,$(error Makefile: при вызове функции «run_script» отсутствует обязательный аргумент №1))$(if $(filter linux,$(OS)),"$(call ensure_sh_script_full_filepath,$(1))" || { if [ ! -e "$(SCRIPTS_DIR)" ]; then { echo "Директория «$(SCRIPTS_DIR)» не найдена." && exit 1; }; elif [ -d "$(SCRIPTS_DIR)" ]; then echo "«$(SCRIPTS_DIR)» является файлом$(COMMA) а не директорией."; elif [ ! -x "$(SCRIPTS_DIR)" ]; then echo "«У директории «$(SCRIPTS_DIR)» отсутствует атрибут исполнения."; elif [ ! -e "$(call ensure_sh_script_full_filepath,$(1))" ]; then echo "Скрипт «$(call ensure_cmd_script_full_filepath,$(1))» не найден."; elif [ -d "$(call ensure_sh_script_full_filepath,$(1))" ]; then echo "«$(call ensure_cmd_script_full_filepath,$(1))» является директорией$(COMMA) а не скриптом."; elif [ ! -x "$(call ensure_sh_script_full_filepath,$(1))" ]; then echo "У скрипта «$(call ensure_cmd_script_full_filepath,$(1))» отсутствует атрибут исполнения."; elif ! dos2unix < "$(call ensure_sh_script_full_filepath,$(1))" | cmp - "$(call ensure_sh_script_full_filepath,$(1))" > /dev/null; then echo "У скрипта «$(call ensure_sh_script_full_filepath,$(1))» некорректное окончание строк. Используй команду dos2unix \"$(call ensure_sh_script_full_filepath,$(1))\""; else { df -kP . | awk 'NR==2 {printf "Свободного объёма на диске (байт): %d\n"$(COMMA) $4 * 1024}'; free -b | awk '/^Mem:/ {m=$4} /^Swap:/ {s=$4} END {printf "Свободной памяти ОЗУ (байт): %d\n"$(COMMA) m + (s? s:0)}'; echo "Лимиты:"; ulimit -a; exit 1; }; fi; } 1>&2)$(if $(filter windows,$(OS)),$(SET_UNICODE_SNIPPET) && CALL "$(call ensure_cmd_script_full_filepath,$(1))" || ((IF /I NOT EXIST "$(SCRIPTS_DIR)" (ECHO Директория «$(SCRIPTS_DIR)» не найдена.&& EXIT /B 1)) && (IF /I NOT EXIST "$(SCRIPTS_DIR)\" (ECHO «$(SCRIPTS_DIR)» является файлом$(COMMA) а не директорией.&& EXIT /B 1)) && (IF /I NOT EXIST "$(call ensure_cmd_script_full_filepath,$(1))" (ECHO Скрипт «$(call ensure_cmd_script_full_filepath,$(1))» не найден.&& EXIT /B 1)) && (IF /I EXIST "$(call ensure_cmd_script_full_filepath,$(1))\" (ECHO «$(call ensure_cmd_script_full_filepath,$(1))» является директорией$(COMMA) а не скриптом.&& EXIT /B 1)))>&2)
endef

# Функция для вывода сообщения от текущего таргета в терминал.
# 
# $(1) — сообщение для вывода в терминал (необязательно).
# $(2) — файловый дескриптор назначения (например, 1 - stdout, 2 - stderr)
# (необязательно).
define print_msg
$(call print_msg_by_target,$@,$(1),$(2))
endef

# Функция для вывода сообщения от определённого таргета в терминал.
# 
# $(1) — таргет.
# $(2) — сообщение для вывода в терминал (необязательно).
# $(3) — файловый дескриптор назначения (например, 1 - stdout, 2 - stderr)
# (необязательно).
define print_msg_by_target
$(if $(1),,$(error Makefile: при вызове функции «normalize_dos_path» отсутствует обязательный аргумент №1))$(if $(filter linux,$(OS)),@printf "$(call colorize_target_name,%-s): %-s\n" "$(1)" "$(2)"$(if $(3),$(SPACE)1>&$(3)))$(if $(filter windows,$(OS)),@ECHO.$(call colorize_target_name,$(1)): $(2)$(if $(3),$(SPACE)1>&$(3)))
endef

################################################################################
# Переменные.
################################################################################

ifneq ($(OS),Windows_NT)
	override OS := linux
    override SHELL := /usr/bin/env sh
    .SHELLFLAGS := -c
else
    override OS := windows
    override SHELL := $(ComSpec)
    override .SHELLFLAGS := /E:ON$(SPACE)/V:ON$(SPACE)/D$(SPACE)/Q$(SPACE)/C
    override SET_UNICODE_SNIPPET = "$(SystemRoot)\System32\chcp.com"$(SPACE)65001$(SPACE)>$(SPACE)NUL
endif

ifeq ($(OS),linux)
    override MAKEFILE_FULL_FILEPATH := $(CURDIR)/$(MAKEFILE_LIST)
    override MAKEFILE_DIR := $(shell dirname "$(MAKEFILE_FULL_FILEPATH)")
    override SCRIPTS_DIR = $(MAKEFILE_DIR)/scripts
endif
ifeq ($(OS),windows)
    override MAKEFILE_FULL_FILEPATH := $(subst /,\,$(CURDIR)\$(MAKEFILE_LIST))
    override MAKEFILE_DIR := $(shell $(SET_UNICODE_SNIPPET)$(NEWLINE)SET "str="$(NEWLINE)FOR /F "usebackq delims=" %%I IN $(LPAREN)`^"ECHO "$(subst %,%%,$(MAKEFILE_FULL_FILEPATH))"^"`$(RPAREN) DO $(LPAREN)SET "str=%%~dpI"$(RPAREN)$(NEWLINE)IF "%str:~-1%" == "\" $(LPAREN)$(NEWLINE)$(TAB)IF NOT "%str:~-2%" == ":\" $(LPAREN)$(NEWLINE)$(TAB)$(TAB)SET "str=%str:~0$(COMMA)-1%"$(NEWLINE)$(TAB)$(RPAREN)$(NEWLINE)$(RPAREN)$(NEWLINE)IF /I NOT EXIST "%str%" $(LPAREN)$(NEWLINE)$(TAB)ECHO директория «%str%» не существует$(NEWLINE)$(TAB)EXIT /B 1$(NEWLINE)$(RPAREN)$(NEWLINE)IF /I NOT EXIST "%str%\" $(LPAREN)$(NEWLINE)$(TAB)ECHO «%str%» не является директорией$(NEWLINE)$(TAB)EXIT /B 1$(NEWLINE)$(RPAREN)$(NEWLINE)ECHO %str%)
    ifneq ($(.SHELLSTATUS),0)
        $(error Не удалось корректно получить значение для переменной «MAKEFILE_DIR»: $(MAKEFILE_DIR))
    endif
    override SCRIPTS_DIR = $(MAKEFILE_DIR)\scripts
endif
override PROJECT_ROOT := $(MAKEFILE_DIR)
override IS_DIRECT_RUN := false
override PHONY :=

export PROJECT_ROOT
export IS_DIRECT_RUN

################################################################################
# Проверки.
################################################################################

# Проверка, что Makefile не был запущен из другой директории.
ifeq ($(OS),windows)
ifneq ($(subst /,\,$(CURDIR)),$(MAKEFILE_DIR))
$(error Makefile: запрещено использование make с флагом -f. Makefile-файл должен находиться в текущей директории. Попробуй использовать make -C "./some_dir" для указания директории с Makefile-файлом)
endif
else
ifneq ($(CURDIR),$(MAKEFILE_DIR))
$(error Makefile: запрещено использование make с флагом -f. Makefile-файл должен находиться в текущей директории. Попробуй использовать make -C "./some_dir" для указания директории с Makefile-файлом)
endif
endif

# Проверки перед всеми таргетами.
ifeq ($(OS),linux)
    override ERROR := $(shell if [ ! -e "$(MAKEFILE_DIR)" ]; then { echo "директория «$(MAKEFILE_DIR)»$(COMMA) которая бы содержала текущий Makefile$(COMMA) не найдена"; exit 1; }; elif [ ! -e "$(PROJECT_ROOT)" ]; then { echo "директория «$(PROJECT_ROOT)»$(COMMA) которая бы содержала текущий Makefile$(COMMA) не найдена"; exit 1; }; elif [ ! -d "$(MAKEFILE_DIR)" ]; then { echo "«$(MAKEFILE_DIR)» является файлом$(COMMA) а не директорий"; exit 1; }; elif [ ! -d "$(PROJECT_ROOT)" ]; then { echo "«$(PROJECT_ROOT)» является файлом$(COMMA) а не директорий"; exit 1; }; elif [ "$(MAKEFILE_DIR)" = "/" ]; then { echo "значение переменной «MAKEFILE_DIR» равно «/»"; exit 1; }; elif [ "$(PROJECT_ROOT)" = "/" ]; then { echo "значение переменной «PROJECT_ROOT» равно «/»"; exit 1; }; elif [ "$(MAKEFILE_DIR)" = "" ]; then { echo "значение переменной «MAKEFILE_DIR» равно пустой строке"; exit 1; }; elif [ "$(PROJECT_ROOT)" = "" ]; then { echo "значение переменной «PROJECT_ROOT» равно пустой строке"; exit 1; }; elif [ ! -x "$(MAKEFILE_DIR)" ]; then { echo "директория «$(MAKEFILE_DIR)» не имеет атрибута исполняемости"; exit 1; }; elif [ ! -x "$(PROJECT_ROOT)" ]; then { echo "директория «$(PROJECT_ROOT)» не имеет атрибута исполняемости"; exit 1; }; fi;)
endif
ifeq ($(OS),windows)
    override ERROR := $(shell $(SET_UNICODE_SNIPPET)$(NEWLINE)IF /I NOT EXIST "$(MAKEFILE_DIR)" (ECHO директория «$(MAKEFILE_DIR)»$(COMMA) которая бы содержала текущий Makefile$(COMMA) не найдена&& EXIT /B 1) && IF /I NOT EXIST "$(PROJECT_ROOT)" (ECHO директория «$(PROJECT_ROOT)»$(COMMA) которая бы содержала текущий Makefile$(COMMA) не найдена&& EXIT /B 1) && IF /I NOT EXIST "$(MAKEFILE_DIR)\" (ECHO «$(MAKEFILE_DIR)» является файлом$(COMMA) а не директорией&& EXIT /B 1) && IF /I NOT EXIST "$(PROJECT_ROOT)\" (ECHO «$(PROJECT_ROOT)» является файлом$(COMMA) а не директорией&& EXIT /B 1) && IF /I "$(MAKEFILE_DIR)" == "/" (ECHO значение переменной «MAKEFILE_DIR» равно «/»&& EXIT /B 1) && IF /I "$(PROJECT_ROOT)" == "/" (ECHO значение переменной «PROJECT_ROOT» равно «/»&& EXIT /B 1) && IF /I "$(MAKEFILE_DIR)" == "" (ECHO значение переменной «MAKEFILE_DIR» равно пустой строке&& EXIT /B 1) && IF /I "$(PROJECT_ROOT)" == "" (ECHO значение переменной «PROJECT_ROOT» равно пустой строке&& EXIT /B 1))
endif
$(if $(ERROR),$(error Makefile: $(ERROR). Возможно, Makefile составлен с ошибками))
override ERROR :=

################################################################################
# Параметры для таргетов.
################################################################################

# Перестать выводить строки команды:
#.SILENT: <targets>

# Обрабатывать все команды таргета в одной оболочке:
#.ONESHELL: <empty>

# Игнорировать ошибки для указанных таргетов:
.IGNORE: help

# Следующие таргеты не смогут запускаться параллельно и должны вставать в очередь:
#.NOTPARALLEL: <targets>

# Таргет, который будет вызван при запуске «make» без указания таргетов.
.DEFAULT_GOAL := all

.DEFAULT:
ifneq ($(OS),windows)
	@echo "$(call colorize_target_name,Makefile): Неизвестная цель: «$@».\n$(call colorize_target_name,Makefile): Возможно$(COMMA) файл Makefile был составлен некорректно.\n$(call colorize_target_name,Makefile): См. $(call colorize_target_name,make help)." 1>&2; exit 1
else
	@$(shell $(SET_UNICODE_SNIPPET)$(NEWLINE)$(LPAREN)$(NEWLINE)ECHO $(call colorize_target_name,Makefile): Неизвестная цель: «$@».$(NEWLINE)ECHO $(call colorize_target_name,Makefile): Возможно$(COMMA) файл Makefile был составлен некорректно.$(NEWLINE)ECHO $(call colorize_target_name,Makefile): См. $(call colorize_target_name,make help).$(NEWLINE)$(RPAREN) >&2)exit 1
endif

PHONY += help
help: ## Prints help.
ifneq ($(OS),windows)
	@echo "Usage:\n  make [TARGET...]\nTargets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ?.*$$' '$(MAKEFILE_FULL_FILEPATH)' \
	| awk 'BEGIN {FS = ":.*?## ?"} {sub(/^ /, "", $$2); printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
else
	@$(shell $(SET_UNICODE_SNIPPET)$(NEWLINE)SETLOCAL ENABLEDELAYEDEXPANSION$(NEWLINE)$(LPAREN)$(NEWLINE)ECHO Usage:$(NEWLINE)ECHO   make [TARGET...]$(NEWLINE)ECHO Targets:$(NEWLINE)FOR /F "usebackq tokens=1$(COMMA)* delims=:" %%A IN $(LPAREN)`^"TYPE "$(subst !,^!,$(MAKEFILE_FULL_FILEPATH))" ^| FINDSTR /R /C:":.*##"^"`$(RPAREN) DO $(LPAREN)$(NEWLINE)$(TAB)SET "target=%%A"$(NEWLINE)$(TAB)SET "description=%%B"$(NEWLINE)$(TAB)IF NOT "!target:~0$(COMMA)1!" == "$(TAB)" $(LPAREN)$(NEWLINE)$(TAB)$(TAB)FOR /F "usebackq tokens=1$(COMMA)* delims=#" %%a IN $(LPAREN)`^"ECHO$(SPACE).!description!^"`$(RPAREN) DO $(LPAREN)$(NEWLINE)$(TAB)$(TAB)$(TAB)SET "description=%%b"$(NEWLINE)$(TAB)$(TAB)$(RPAREN)$(NEWLINE)$(TAB)$(TAB)IF "!description:~0$(COMMA)1!" == "$(SPACE)" $(LPAREN)$(NEWLINE)$(TAB)$(TAB)$(TAB)SET "description=!description:~1!"$(NEWLINE)$(TAB)$(TAB)$(RPAREN)$(NEWLINE)$(TAB)$(TAB)IF "!target:~10$(COMMA)1!" == "" $(LPAREN)$(NEWLINE)$(TAB)$(TAB)$(TAB)SET "target=!target!$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)"$(NEWLINE)$(TAB)$(TAB)$(TAB)SET "target=!target:~0$(COMMA)10!"$(NEWLINE)$(TAB)$(TAB)$(RPAREN)$(NEWLINE)$(TAB)$(TAB)IF "!description:~0$(COMMA)4!" == " ## " $(LPAREN)$(NEWLINE)$(TAB)$(TAB)$(TAB)SET "description=!description:~4!"$(NEWLINE)$(TAB)$(TAB)$(RPAREN)$(NEWLINE)$(TAB)$(TAB)$(NEWLINE)$(TAB)$(TAB)IF NOT "!description!" == "" $(LPAREN)$(NEWLINE)$(TAB)$(TAB)$(TAB)ECHO.$(SPACE)$(SPACE)$(call colorize_target_name,!target!) !description!$(NEWLINE)$(TAB)$(TAB)$(RPAREN) ELSE $(LPAREN)$(NEWLINE)$(TAB)$(TAB)$(TAB)ECHO.$(SPACE)$(SPACE)$(call colorize_target_name,!target!)$(SPACE)$(NEWLINE)$(TAB)$(TAB)$(RPAREN)$(NEWLINE)$(TAB)$(RPAREN)$(NEWLINE)$(RPAREN)$(NEWLINE)$(RPAREN) 1>&2)exit 0
endif

################################################################################
# Таргеты.
################################################################################

PHONY += all
all: build

build: ## Builds release files.
	$(call print_msg,Создание файлов...)
	@$(call run_script,generate)

PHONY += clean
clean: ## Deletes all generated files.
ifneq ($(OS),windows)
	@[ ! -d "build" ] || rm -ir "build"
else
	@IF /I EXIST "build" (ECHO Удаление директории «%CD%\build»...& RMDIR /S "build")
endif

.PHONY: $(PHONY)
