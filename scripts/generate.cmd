@ECHO OFF
CHCP 65001 > NUL
SET "exitcode=255"

IF NOT "%IS_DIRECT_RUN%" == "false" (
	ECHO Данный скрипт запрещено вызывать вручную. Используй `make` в директории с файлом Makefile.>&2
	EXIT /B 1
)
IF "%PROJECT_ROOT%" == "" (
	ECHO Не указана обязательная переменная окружения «PROJECT_ROOT». Используй `make` в директории с файлом Makefile.>&2
	EXIT /B 1
)
IF /I NOT EXIST "%PROJECT_ROOT%" (
	ECHO Директория «%PROJECT_ROOT%» не найдена.>&2
	EXIT /B 1
)
IF /I NOT EXIST "%PROJECT_ROOT%\" (
	ECHO «%PROJECT_ROOT%» не является директорией.>&2
	EXIT /B 1
)

SET "CURRENT_DIR=%CD%"
SET "SCRIPT_NAME=%~nx0"
SET "SCRIPT_DIR=%~dp0"
IF "%SCRIPT_DIR:~-1%" == "\" (
    SET "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
)
SET "SCRIPT_CFG=%SCRIPT_DIR%\%~n0.cfg"
SET "SCRIPT_VERSION=0.3.0"

SET "DATA_DIR=data"
SET "OUTPUT_DIR=build"
SET "COSMETIC_FILTERS_OUTPUT_FILE_PATH=cosmetic_filters.txt"
SET "HEADER_FILE_PATH=template\cosmetic_filters-header.txt"

SETLOCAL EnableExtensions EnableDelayedExpansion
PUSHD "!CURRENT_DIR!"
:main
	SET "data_dir=!PROJECT_ROOT!\!DATA_DIR!"
	SET "output_dir=!PROJECT_ROOT!\!OUTPUT_DIR!"
	IF NOT EXIST "!output_dir!" (
		MKDIR "!output_dir!"
	)
	SET "output_json_dir=!output_dir!\json"
	IF NOT EXIST "!output_json_dir!" (
		MKDIR "!output_json_dir!"
	)
	SET "cosmetic_filters_output_path=!OUTPUT_DIR!\!COSMETIC_FILTERS_OUTPUT_FILE_PATH!"
	IF EXIST "!cosmetic_filters_output_path!" (
		DEL /Q "!cosmetic_filters_output_path!"
	)
	
	PUSHD "!data_dir!"
	FOR /F "usebackq delims=" %%i IN (`^"DIR /A:-d /B "!data_dir!"^"`) DO (
		SET "yaml_fullpath=%%~dpnxi"
		IF "!yaml_fullpath!" == "" (
			GOTO _end_loop
		)
		SET "yaml_filename_stem=%%~ni"
		IF "!yaml_filename_stem!" == "" (
			GOTO _end_loop
		)
		
		SET "json_fullpath=!output_json_dir!\!yaml_filename_stem!.json"
		
		yq -o=json "!yaml_fullpath!" > "!json_fullpath!"
	)
	:_end_loop
	POPD
	
	REM Создание файла «dataset.json».
	SET "merged_json=!output_dir!\dataset.json"
	SET "json_fullpaths_args_list="
	FOR /F "usebackq delims=" %%i IN (`^"DIR /A:-d /B "!output_json_dir!"^"`) DO (
		SET "json_file=!output_json_dir!\%%~i"
		IF "!json_fullpaths_args_list!" == "" (
			SET "json_fullpaths_args_list="!json_file!""
		) ELSE (
			SET "json_fullpaths_args_list=!json_fullpaths_args_list! "!json_file!""
		)
	)
	jq --slurp "." !json_fullpaths_args_list! > "!merged_json!"
	
	REM Создание файла «cosmetic_filters.txt».
	SET "header_file_path=!PROJECT_ROOT!\!HEADER_FILE_PATH!"
	IF EXIST "!header_file_path!" (
		TYPE "!header_file_path!" > "!cosmetic_filters_output_path!"
		ECHO.>> "!cosmetic_filters_output_path!"
	)
	PUSHD "!PROJECT_ROOT!"
	jq -r -f "misc\jq\generate_cosmetic_filters.jq" "!merged_json!" >> "!cosmetic_filters_output_path!"
	POPD
	
	REM Проверки.
	IF EXIST "!cosmetic_filters_output_path!" (
		FC "!cosmetic_filters_output_path!" "!header_file_path!" > NUL
		SET "exitcode=!ERRORLEVEL!"
		IF "!exitcode!" == "0" (
			ECHO Не удалось сгенерировать файл «!cosmetic_filters_output_path!».
			EXIT /B 1
		) ELSE (
			ECHO Сгенерированный файл: «!cosmetic_filters_output_path!».
		)
	) ELSE (
		ECHO Не удалось сгенерировать файл «!cosmetic_filters_output_path!».
		EXIT /B 1
	)
:exit
POPD
ENDLOCAL
EXIT /B 0
