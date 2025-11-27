@ECHO OFF
CHCP 65001 > NUL
SET "exitcode=255"

SET "CURRENT_DIR=%CD%"
SET "SCRIPT_NAME=%~nx0"
SET "SCRIPT_DIR=%~dp0"
IF "%SCRIPT_DIR:~-1%" == "\" (
    SET "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
)
SET "SCRIPT_CFG=%SCRIPT_DIR%\%~n0.cfg"
SET "SCRIPT_VERSION=0.2.0"
SETLOCAL EnableExtensions EnableDelayedExpansion
PUSHD "!CURRENT_DIR!"
:main
    SET "DATA_DIR=data"
    SET "OUTPUT_DIR=build"
    SET "COSMETIC_FILTERS_OUTPUT_FILE_PATH=cosmetic_filters.txt"
    
    SET "data_dir=!SCRIPT_DIR!\!DATA_DIR!"
    SET "output_dir=!SCRIPT_DIR!\!OUTPUT_DIR!"
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
        
        IF EXIST "!cosmetic_filters_output_path!" (
            ECHO.>> "!cosmetic_filters_output_path!"
        )
        PUSHD "!SCRIPT_DIR!"
        jq -r -f generate_cosmetic_filters.jq "!json_fullpath!" >> "!cosmetic_filters_output_path!"
        POPD
    )
    :_end_loop
    POPD
    
    IF EXIST "!cosmetic_filters_output_path!" (
        ECHO Сгенерированный файл: «!cosmetic_filters_output_path!».
    ) ELSE (
        ECHO Не удалось сгенерировать файл «!cosmetic_filters_output_path!».
        EXIT /B 1
    )
:exit
POPD
ENDLOCAL
EXIT /B 0
