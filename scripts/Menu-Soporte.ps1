#requires -Version 5.1

[CmdletBinding()]
param()

$script = Join-Path $PSScriptRoot 'Auditar-Trafico.ps1'
if (-not (Test-Path -LiteralPath $script)) { $script = '.\Auditar-Trafico.ps1' }

function Write-Linea([string]$c = '-', [string]$col = 'Cyan') {
    Write-Host ($c * 68) -ForegroundColor $col
}

function Write-Titulo([string]$txt, [string]$col = 'Cyan') {
    Write-Linea -c '-' -col $col
    $pad = [Math]::Max(0, [Math]::Floor((68 - $txt.Length) / 2))
    Write-Host ((' ' * $pad) + $txt) -ForegroundColor $col
    Write-Linea -c '-' -col $col
}

function Write-MobleyHeader {
    Write-Host '        ⠀⠀⠀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀' -ForegroundColor Cyan
    Write-Host '    ⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀' -ForegroundColor Cyan
    Write-Host '    ⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀' -ForegroundColor Cyan
    Write-Host '    ⠀⠀⠀⠀⠀⢸⡿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⢿⣧⠀⠀⠀⠀⠀' -ForegroundColor Cyan
    Write-Host '    ⢀⣀⣀⣀⣀⣸⣇⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣸⣿⣀⣀⣀⣀⠀' -ForegroundColor White
    Write-Host '    ⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⠉⢙⣿⡿⠿⠿⠿⠿⠿⢿⣿⣿⣿⠿⠿⠿⠿⠿⢿⣿⣛⠉⠁⠀⠀' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⣰⡟⠉⢰⣶⣶⣶⣶⣶⣶⡶⢶⣶⣶⣶⣶⣶⣶⡆⠉⠻⣧⠀⠀⠀' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⢻⣧⡀⠈⣿⣿⣿⣿⣿⡿⠁⠈⢿⣿⣿⣿⣿⣿⠁⠀⣠⡿⠀⠀⠀' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⠀⠙⣿⡆⠈⠉⠉⠉⠉⠀⠀⠀⠀⠉⠉⠉⠉⠁⢰⣿⠋⠀⠀⠀⠀' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⣠⣶⣶⣶⣶⣶⣶⣄⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⠀⠀⠸⣷⡀⠀⠀⣿⠛⠉⠉⠉⠉⠛⣿⠀⠀⢀⾾⠇⠀⠀⠀⠀⠀⠀' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⠀⠀⠀⠘⢿⣦⡀⣿⣄⠀⾾⣷⠀⣠⣿⣀⣴⡟⠁⠀⠀⠀⠀⠀⠀' -ForegroundColor White
    Write-Host '    ⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀' -ForegroundColor Cyan
    Write-Host '    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀' -ForegroundColor Cyan
}

function Write-Info([string]$txt) {
    Write-Host '  i  ' -NoNewline -ForegroundColor Cyan
    Write-Host $txt -ForegroundColor White
}

function Write-Ok([string]$txt) {
    Write-Host '  OK ' -NoNewline -ForegroundColor Green
    Write-Host $txt -ForegroundColor White
}

function Write-Warn([string]$txt) {
    Write-Host '  !  ' -NoNewline -ForegroundColor Yellow
    Write-Host $txt -ForegroundColor White
}

function Write-ErrorMsg([string]$txt) {
    Write-Host '  X  ' -NoNewline -ForegroundColor Red
    Write-Host $txt -ForegroundColor White
}

function Test-Pregunta([string]$txt) {
    Write-Host '  ?  ' -NoNewline -ForegroundColor Cyan
    $resp = Read-Host "$txt (s/n)"
    return ($resp.Trim().ToLower() -eq 's')
}

function Write-Pausar {
    Write-Host "`n  Presione Enter para continuar..." -ForegroundColor Gray
    [void](Read-Host)
}

function Start-CleanupDownloadedToolkit {
    $directorioToolkit = Split-Path -Parent $PSCommandPath
    $directorioDescargado = Join-Path $env:LOCALAPPDATA 'SoportePC'
    if ($directorioToolkit.TrimEnd('\') -ine $directorioDescargado.TrimEnd('\')) {
        return
    }

    $rutaLiteral = $directorioToolkit.Replace("'", "''")
    $comandoLimpieza = "Start-Sleep -Seconds 2; Remove-Item -LiteralPath '$rutaLiteral' -Recurse -Force -ErrorAction SilentlyContinue"
    Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @(
        '-NoLogo',
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        $comandoLimpieza
    ) | Out-Null
}

function Install-OfficeToolkit {
    $raicesPosibles = @($PSScriptRoot, (Split-Path -Parent $PSScriptRoot))
    $directorioOffice = $null
    foreach ($raiz in $raicesPosibles) {
        $candidato = Join-Path $raiz 'office'
        if ((Test-Path -LiteralPath (Join-Path $candidato 'setup.exe')) -and
            (Test-Path -LiteralPath (Join-Path $candidato 'configuration-Office-x64.xml'))) {
            $directorioOffice = $candidato
            break
        }
    }

    if (-not $directorioOffice) {
        throw 'No se encontraron los archivos de Office. Vuelva a iniciar el menú con conexión a Internet o use el paquete completo del toolkit.'
    }

    $instalador = Join-Path $directorioOffice 'setup.exe'
    $configuracion = Join-Path $directorioOffice 'configuration-Office-x64.xml'
    Write-Info 'Iniciando instalacion de Office con la configuracion incluida...'
    $argumentos = '/configure "{0}"' -f $configuracion
    $proceso = Start-Process -FilePath $instalador -WorkingDirectory $directorioOffice -ArgumentList $argumentos -Wait -PassThru
    if ($proceso.ExitCode -ne 0) {
        throw "El instalador de Office termino con codigo $($proceso.ExitCode)."
    }
    Write-Ok 'Instalacion de Office finalizada correctamente.'
}

function Show-StartupRepairSubmenu {
    while ($true) {
        Clear-Host
        Write-Titulo 'TRIAJE: EQUIPO NO ENCIENDE O NO INICIA' -col Cyan
        Write-Host '  1. No enciende (sin luces, ventilador ni sonido)'
        Write-Host '  2. Enciende, pero no completa POST (luces o pitidos)'
        Write-Host '  3. Pasa el logo, pero Windows no inicia (POST completado)'
        Write-Host '  4. Enciende, pero no hay imagen'
        Write-Host '  5. Registrar el caso en una ficha local'
        Write-Host '  0. Volver al menu principal'
        Write-Host ''
        $seleccion = (Read-Host 'Seleccione una opcion').Trim()
        if ($seleccion -eq '0') { return }

        $destino = $null
        switch ($seleccion) {
            '1' {
                Write-Host ''
                Write-Warn 'Revise la toma con otro dispositivo, el cable/cargador y sus indicadores. Desconecte perifericos USB no esenciales. Siga el procedimiento de descarga electrica indicado por el fabricante y modelo; no abra el equipo.'
                $fabricante = (Read-Host 'Fabricante (Dell/HP)').Trim().ToLowerInvariant()
                if ($fabricante -eq 'hp') { $destino = 'https://support.hp.com/au-en/document/ish_3974055-3873564-16' }
                else { $destino = 'https://www.dell.com/support/contents/en-us/article/product-support/self-support-knowledgebase/fix-common-issues/no-power' }
            }
            '2' {
                Write-Host ''
                Write-Warn 'Anote el modelo exacto, el color y la secuencia repetida de luces o pitidos. No interprete un patron con una guia de otro modelo ni retire componentes.'
                $fabricante = (Read-Host 'Fabricante (Dell/HP)').Trim().ToLowerInvariant()
                if ($fabricante -eq 'hp') {
                    $tipoHp = (Read-Host 'Tipo de equipo (escritorio/notebook)').Trim().ToLowerInvariant()
                    if ($tipoHp -eq 'notebook') { $destino = 'https://support.hp.com/in-en/document/ish_1997719-1528356-16' }
                    else { $destino = 'https://support.hp.com/us-en/document/ish_1997210-1528385-16' }
                }
                else { $destino = 'https://www.dell.com/support/kbdoc/en-us/000125609/resolve-no-power-no-post-no-boot-or-no-video-issues-with-your-dell-computer' }
                Write-Info 'Si el patron apunta a CPU, placa o memoria, es un indicio de hardware y requiere el diagnostico del fabricante o servicio tecnico.'
            }
            '3' {
                Write-Host ''
                Write-Warn 'Esta opcion es solo para un equipo que enciende y completa POST, pero no carga Windows. Antes de usar comandos UEFI, respalde los datos si es posible y confirme las letras de unidad desde WinRE.'
                foreach ($raiz in @($PSScriptRoot, (Split-Path -Parent $PSScriptRoot))) {
                    $candidato = Join-Path $raiz 'Comandos_Paso_a_Paso_Reparacion_Arranque_UEFI.pdf'
                    if (Test-Path -LiteralPath $candidato -PathType Leaf) { $destino = $candidato; break }
                }
                if (-not $destino) { Write-Warn 'No se encontro la guia PDF local. Use la version completa del toolkit.' }
            }
            '4' {
                Write-Host ''
                Write-Warn 'Confirme que el monitor tenga energia, este encendido y use la entrada correcta. En un escritorio, revise el cable de video y pruebe otra pantalla/cable si estan disponibles. No ejecute reparaciones UEFI por falta de imagen.'
                $fabricante = (Read-Host 'Fabricante (Dell/HP)').Trim().ToLowerInvariant()
                if ($fabricante -eq 'hp') { $destino = 'https://support.hp.com/au-en/document/ish_3974055-3873564-16' }
                else { $destino = 'https://www.dell.com/support/kbdoc/en-us/000125609/resolve-no-power-no-post-no-boot-or-no-video-issues-with-your-dell-computer' }
            }
            '5' {
                $marcaCaso = Read-Host 'Fabricante'
                $modeloCaso = Read-Host 'Modelo exacto (no ingrese numero de serie)'
                $sintomaCaso = Read-Host 'Sintoma (sin energia / no POST / no inicia Windows / sin imagen)'
                $codigoCaso = Read-Host 'Patron de luces o pitidos (si aplica)'
                $resultadoCaso = Read-Host 'Pruebas realizadas y resultado'
                $carpetaCasos = 'C:\AuditoriaRed\CasosArranque'
                New-Item -ItemType Directory -Path $carpetaCasos -Force | Out-Null
                $archivoCaso = Join-Path $carpetaCasos ("Caso-arranque-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
                @(
                    'FICHA DE TRIAGE DE ARRANQUE'
                    ('Fecha: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
                    ('Fabricante: {0}' -f $marcaCaso)
                    ('Modelo: {0}' -f $modeloCaso)
                    ('Sintoma: {0}' -f $sintomaCaso)
                    ('Patron de luces/pitidos: {0}' -f $codigoCaso)
                    ('Pruebas y resultado: {0}' -f $resultadoCaso)
                    'Nota: un codigo luminoso orienta el diagnostico y debe contrastarse con la documentacion del modelo exacto.'
                ) | Out-File -LiteralPath $archivoCaso -Encoding UTF8
                Write-Ok "Ficha guardada en $archivoCaso"
            }
            default { Write-Warn 'Opcion no valida.' }
        }
        if ($destino) {
            Start-Process -FilePath $destino
            Write-Host ''
            Write-Info 'Compare el sintoma con la guia oficial del modelo exacto. Un codigo orienta la revision; no confirma por si solo que un componente este dañado.'
        }
        Write-Pausar
    }
}

$opciones = [ordered]@{
    '1'  = @{ Icon = '[1]'; Label = 'Revision preventiva rapida'; Desc = '(5 min - Estado general, red basica y hardware)'; Params = @{ Modo = 'Rapido'; AutoEliminarAlCerrar = $true } }
    '2'  = @{ Icon = '[2]'; Label = 'Limpieza segura'; Desc = '(Temporales, cache y accesos directos rotos; confirma antes de borrar)'; Params = @{ Modo = 'Limpieza'; AutoEliminarAlCerrar = $true } }
    '3'  = @{ Icon = '[3]'; Label = 'Actualizar Windows'; Desc = '(Instala actualizaciones; puede reiniciar el equipo)'; Params = @{ ActualizarWindows = $true; AutoEliminarAlCerrar = $true } }
    '4'  = @{ Icon = '[4]'; Label = 'Optimizar unidades'; Desc = '(Windows elige la optimizacion apropiada por unidad)'; Params = @{ DesfragmentarDiscos = $true; AutoEliminarAlCerrar = $true } }
    '5'  = @{ Icon = '[5]'; Label = 'Reparar Windows'; Desc = '(Diagnostico completo y verificacion DISM/SFC)'; Params = @{ Modo = 'Completo'; IncluirVerificacionSistema = $true; AutoEliminarAlCerrar = $true } }
    '6'  = @{ Icon = '[6]'; Label = 'Reparar cola de impresion'; Desc = '(Elimina trabajos atascados y reinicia Spooler)'; Params = @{ LimpiarColaImpresion = $true; AutoEliminarAlCerrar = $true } }
    '7'  = @{ Icon = '[7]'; Label = 'Instalar Office'; Desc = '(Instalador incluido en la carpeta office)'; Params = $null }
    '8'  = @{ Icon = '[8]'; Label = 'Auditoria completa'; Desc = '(Seguridad, hardware, eventos, servicios y software)'; Params = @{ Modo = 'Completo'; AutoEliminarAlCerrar = $true } }
    '9'  = @{ Icon = '[9]'; Label = 'Auditoria de red'; Desc = '(Muestreo de conexiones y trafico TCP)'; Params = @{ Modo = 'Red'; AutoEliminarAlCerrar = $true } }
    '10' = @{ Icon = '[10]'; Label = 'Comparar auditorias'; Desc = '(Procesos, puertos, servicios y DNS)'; Params = $null }
    '11' = @{ Icon = '[11]'; Label = 'Estado de licencias'; Desc = '(Consulta licencias de Windows y productos Microsoft)'; Params = @{ MostrarLicencias = $true; AutoEliminarAlCerrar = $true } }
    '12' = @{ Icon = '[12]'; Label = 'Rendimiento de Windows'; Desc = '(Informe persistente: inicio, memoria, discos y almacenamiento)'; Params = @{ Modo = 'Rapido'; DuracionMinutos = 5 } }
    '13' = @{ Icon = '[13]'; Label = 'Reparacion de arranque'; Desc = '(UEFI y codigos luminosos Dell/HP; guias oficiales)'; Params = $null }
}

$categorias = [ordered]@{
    'MANTENIMIENTO PREVENTIVO' = @('1', '2', '3', '4', '12')
    'MANTENIMIENTO CORRECTIVO' = @('5', '6', '7')
    'AUDITORIA Y REVISION' = @('8', '9', '10', '11')
    'ARRANQUE Y DIAGNOSTICO DE HARDWARE' = @('13')
}

while ($true) {
    Clear-Host
    Write-Host ''
    Write-MobleyHeader
    Write-Titulo 'DIAGNOSTICO Y SOPORTE PC' -col Cyan
    Write-Host ''

    $colNum = 'Cyan'
    $colIcon = 'White'
    $colLabel = 'White'
    $colDesc = 'Gray'

    foreach ($categoria in $categorias.Keys) {
        Write-Host "  $categoria" -ForegroundColor DarkCyan
        foreach ($k in $categorias[$categoria]) {
            $item = $opciones[$k]
            Write-Host ('  {0}.  ' -f $k) -NoNewline -ForegroundColor $colNum
            Write-Host ('{0}  ' -f $item.Icon) -NoNewline -ForegroundColor $colIcon
            Write-Host ('{0,-29}' -f $item.Label) -NoNewline -ForegroundColor $colLabel
            Write-Host $item.Desc -ForegroundColor $colDesc
        }
        Write-Host ''
    }

    Write-Host ''
    Write-Linea -c '-' -col DarkCyan
    Write-Host '   0.  ' -NoNewline -ForegroundColor $colNum
    Write-Host 'Salir del Menu' -ForegroundColor $colLabel
    Write-Linea -c '-' -col DarkCyan
    Write-Host ''
    Write-Info 'Los procesos muestran una confirmacion antes de ejecutarse.'
    Write-Info 'Rendimiento conserva su informe en C:\AuditoriaRed; las demas opciones temporales indican cuando se borraran sus evidencias.'
    Write-Host ''

    Write-Host '  Seleccione una opcion: ' -NoNewline -ForegroundColor Cyan
    $opc = (Read-Host).Trim()

    if ($opc -eq '0' -or $opc.ToLower() -eq 'q') {
        Write-Host ''
        Write-Info 'Cerrando sesion de soporte... Hasta luego.'
        Start-CleanupDownloadedToolkit
        Start-Sleep -Seconds 1
        break
    }

    if ($opciones.Contains($opc)) {
        $sel = $opciones[$opc]

        if ($opc -eq '13') {
            Show-StartupRepairSubmenu
            continue
        }

        if ($opc -eq '10') {
            $carpetaSalida = 'C:\AuditoriaRed'
            $auditorias = @(Get-ChildItem -LiteralPath $carpetaSalida -Directory -Filter 'Auditoria-*' -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending)
            if ($auditorias.Count -eq 0) {
                Write-Warn 'No hay auditorias anteriores disponibles en C:\AuditoriaRed.'
                Write-Pausar
                continue
            }
            Write-Host ''
            Write-Info 'Seleccione la auditoria anterior:'
            for ($indiceAuditoria = 0; $indiceAuditoria -lt $auditorias.Count; $indiceAuditoria++) {
                Write-Host ('  {0}. {1} ({2})' -f ($indiceAuditoria + 1), $auditorias[$indiceAuditoria].Name, $auditorias[$indiceAuditoria].LastWriteTime)
            }
            $seleccionAuditoria = 0
            if (-not [int]::TryParse((Read-Host 'Numero de auditoria'), [ref]$seleccionAuditoria) -or
                $seleccionAuditoria -lt 1 -or $seleccionAuditoria -gt $auditorias.Count) {
                Write-Warn 'Seleccion no valida.'
                Write-Pausar
                continue
            }
            $sel.Params = @{ Modo = 'Red'; AuditoriaAnterior = $auditorias[$seleccionAuditoria - 1].FullName; AutoEliminarAlCerrar = $true }
        }

        Write-Host ''
        Write-Linea -c '.' -col DarkCyan
        Write-Info ('Va a ejecutar: {0}' -f $sel.Label)
        Write-Linea -c '.' -col DarkCyan
        Write-Host ''

        if (-not (Test-Pregunta 'Confirma?')) {
            Write-Warn 'Operacion cancelada, volviendo al menu.'
            Write-Pausar
            continue
        }

        Clear-Host
        Write-Titulo ('EJECUTANDO: {0}' -f $sel.Label.ToUpper()) -col Yellow
        Write-Host ''

        try {
            if ($opc -eq '7') {
                Install-OfficeToolkit
            }
            else {
                $paramsSplat = $sel.Params
                & $script @paramsSplat
                Write-Host ''
                Write-Ok 'Proceso completado exitosamente.'
            }
        }
        catch {
            Write-Host ''
            Write-ErrorMsg ('Error al ejecutar: {0}' -f $_.Exception.Message)
            if ($_.Exception.InnerException) {
                Write-Host ('  Detalle interno: {0}' -f $_.Exception.InnerException.Message) -ForegroundColor Yellow
            }
            if ($_.InvocationInfo.ScriptLineNumber) {
                $archivoError = if ($_.InvocationInfo.ScriptName) { $_.InvocationInfo.ScriptName } else { $script }
                Write-Host ('  Archivo: {0}' -f $archivoError) -ForegroundColor Yellow
                Write-Host ('  Línea: {0} | Comando: {1}' -f $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.Line.Trim()) -ForegroundColor Yellow
            }
            if ($_.ScriptStackTrace) {
                Write-Host ('  Pila: {0}' -f $_.ScriptStackTrace) -ForegroundColor DarkYellow
            }
        }

        Write-Pausar
    }
    else {
        Write-Host ''
        Write-Warn ('"{0}" no es una opcion valida. Ingrese un numero del 1 al 13, o 0 para salir.' -f $opc)
        Write-Pausar
    }
}
