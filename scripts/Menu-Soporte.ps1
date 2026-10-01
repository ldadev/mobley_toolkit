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

function Show-PeripheralSubmenu {
    while ($true) {
        Clear-Host
        Write-Titulo 'ORIENTACION DE PERIFERICOS' -col Cyan
        Write-Host '  1. Impresoras'
        Write-Host '  2. Monitores y pantallas'
        Write-Host '  3. Teclados'
        Write-Host '  4. Mouse / raton'
        Write-Host '  5. Registrar caso en ficha local'
        Write-Host '  0. Volver al menu principal'
        Write-Host ''
        $seleccion = (Read-Host 'Seleccione una opcion').Trim()
        if ($seleccion -eq '0') { return }

        switch ($seleccion) {
            '1' {
                Show-PeripheralProblemGuide -Tipo 'Impresora'
                Write-Titulo 'IMPRESORAS' -col Yellow
                try {
                    $impresorasDetectadas = @(Get-Printer -ErrorAction Stop | Select-Object Name, PrinterStatus, DriverName, PortName)
                    if ($impresorasDetectadas.Count -gt 0) { $impresorasDetectadas | Format-Table -AutoSize | Out-Host }
                    else { Write-Info 'Windows no reporto impresoras instaladas.' }
                }
                catch { Write-Warn 'No se pudo consultar Get-Printer; revise la vista de impresoras de Windows.' }
                Write-Host '  Revise: energia, papel, atascos y luces del equipo; confirme que Windows y la impresora muestran el mismo estado.'
                Write-Host '  En USB, conecte directamente al equipo y pruebe otro puerto/cable. En red, confirme que impresora y PC esten en la red esperada.'
                Write-Host '  En Windows, revise la cola, estado predeterminado y puerto. No borre la cola ni reinstale el controlador sin registrar el error.'
                Start-Process 'ms-settings:printers' -ErrorAction SilentlyContinue
            }
            '2' {
                Show-PeripheralProblemGuide -Tipo 'Monitor'
                Write-Titulo 'MONITORES Y PANTALLAS' -col Yellow
                Write-Host '  Revise energia del monitor, indicador, brillo, entrada seleccionada y cable en ambos extremos.'
                Write-Host '  En escritorio, pruebe un cable/puerto o monitor conocido como funcional. En portatil, compare pantalla integrada con una externa si esta disponible.'
                Write-Host '  Si Windows detecta la pantalla, revise modo de proyeccion, resolucion y frecuencia; no fuerce valores fuera de las especificaciones del monitor.'
                Start-Process 'ms-settings:display' -ErrorAction SilentlyContinue
                Show-PnpPeripheralInventory -Clase 'Monitor'
            }
            '3' {
                Show-PeripheralProblemGuide -Tipo 'Teclado'
                Write-Titulo 'TECLADOS' -col Yellow
                Write-Host '  USB: reconecte directamente, pruebe otro puerto y verifique si funcionan otras teclas. Inalambrico: revise bateria, receptor y emparejamiento.'
                Write-Host '  Pruebe el teclado en otra aplicacion y abra el teclado en pantalla con osk.exe para distinguir hardware de entrada de Windows.'
                Write-Host '  Si falla antes de iniciar sesion, compare con otro teclado compatible; no desinstale dispositivos sin un metodo alternativo de entrada.'
                Start-Process 'osk.exe' -ErrorAction SilentlyContinue
                Show-PnpPeripheralInventory -Clase 'Keyboard'
            }
            '4' {
                Show-PeripheralProblemGuide -Tipo 'Mouse'
                Write-Titulo 'MOUSE / RATON' -col Yellow
                Write-Host '  USB: conecte directamente y pruebe otro puerto. Inalambrico: revise bateria, receptor y emparejamiento.'
                Write-Host '  Pruebe otra superficie y otro mouse. Si el cursor se mueve pero los clics fallan, compare botones y rueda en mas de una aplicacion.'
                Write-Host '  En portatil, compare mouse externo con panel tactil y compruebe si la tecla de funcion desactivo el panel.'
                Start-Process 'ms-settings:devices' -ErrorAction SilentlyContinue
                Show-PnpPeripheralInventory -Clase 'Mouse'
            }
            '5' {
                $tipoCaso = Read-Host 'Periferico (impresora/monitor/teclado/mouse)'
                $fabricanteCaso = Read-Host 'Fabricante (opcional)'
                $modeloCaso = Read-Host 'Modelo (opcional; no ingrese numero de serie)'
                $conexionCaso = Read-Host 'Conexion (USB/red/Bluetooth/inalambrica/otra)'
                $sintomaCaso = Read-Host 'Sintoma observado'
                $pruebasCaso = Read-Host 'Comprobaciones realizadas y resultados'
                $carpetaCasos = 'C:\AuditoriaRed\CasosPerifericos'
                New-Item -ItemType Directory -Path $carpetaCasos -Force | Out-Null
                $archivoCaso = Join-Path $carpetaCasos ("Caso-periferico-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
                @(
                    'FICHA DE ORIENTACION DE PERIFERICOS'
                    ('Fecha: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
                    ('Periferico: {0}' -f $tipoCaso)
                    ('Fabricante: {0}' -f $fabricanteCaso)
                    ('Modelo: {0}' -f $modeloCaso)
                    ('Conexion: {0}' -f $conexionCaso)
                    ('Sintoma: {0}' -f $sintomaCaso)
                    ('Comprobaciones y resultados: {0}' -f $pruebasCaso)
                ) | Out-File -LiteralPath $archivoCaso -Encoding UTF8
                Write-Ok "Ficha guardada en $archivoCaso"
            }
            default { Write-Warn 'Opcion no valida.' }
        }
        Write-Pausar
    }
}

function Show-PnpPeripheralInventory {
    param([Parameter(Mandatory)][string]$Clase)
    if (-not (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue)) {
        Write-Info 'Este Windows no ofrece Get-PnpDevice en esta sesion; omitiendo inventario.'
        return
    }
    try {
        $dispositivos = @(Get-PnpDevice -Class $Clase -ErrorAction Stop |
            Select-Object Status, FriendlyName | Select-Object -First 20)
        if ($dispositivos.Count -gt 0) { $dispositivos | Format-Table -AutoSize | Out-Host }
        else { Write-Info 'No se encontraron dispositivos de esta clase en el inventario PnP.' }
    }
    catch { Write-Info 'No fue posible leer el inventario PnP de esta clase.' }
}

function Show-PeripheralProblemGuide {
    param([Parameter(Mandatory)][ValidateSet('Impresora', 'Monitor', 'Teclado', 'Mouse')][string]$Tipo)
    while ($true) {
        Clear-Host
        Write-Titulo ("SINTOMAS COMUNES: {0}" -f $Tipo.ToUpperInvariant()) -col Cyan
        Write-Info 'Las causas son posibilidades, no un diagnostico confirmado. Elija el sintoma mas parecido.'
        switch ($Tipo) {
            'Impresora' {
                Write-Host '  1. No imprime / aparece sin conexion'
                Write-Host '  2. Rayas horizontales o calidad deficiente'
                Write-Host '  3. Atasco o no toma el papel'
            }
            'Monitor' {
                Write-Host '  1. Lineas horizontales o verticales'
                Write-Host '  2. Sin señal / pantalla negra'
                Write-Host '  3. Parpadeo o imagen intermitente'
            }
            'Teclado' {
                Write-Host '  1. No responde / algunas teclas fallan'
                Write-Host '  2. Escribe caracteres distintos o repetidos'
                Write-Host '  3. Teclado inalambrico se desconecta'
            }
            'Mouse' {
                Write-Host '  1. Cursor no se mueve o salta'
                Write-Host '  2. Clics o rueda fallan'
                Write-Host '  3. Mouse inalambrico se desconecta'
            }
        }
        Write-Host '  0. Volver'
        $caso = (Read-Host 'Seleccione el sintoma').Trim()
        if ($caso -eq '0') { return }
        Write-Linea -c '-' -col DarkCyan
        switch (('{0}:{1}' -f $Tipo, $caso)) {
            'Impresora:1' {
                Write-Host 'POSIBLES CAUSAS: sin energia, cable/red desconectados, cola pausada, impresora incorrecta o controlador/puerto.'
                Write-Host 'PRUEBE: estado y pantalla de la impresora; cable USB directo o misma red; cola sin pausa; imprima pagina de prueba desde Windows y desde la impresora si tiene esa opcion.'
                Write-Host 'INTERPRETACION: si la pagina interna sale bien pero la de Windows no, revise conexion, cola o controlador. Registre el codigo antes de borrar trabajos o reinstalar.'
            }
            'Impresora:2' {
                Write-Host 'POSIBLES CAUSAS: consumible bajo/dañado, cabezal sucio o desalineado, papel/configuracion incorrectos; depende de tecnologia y modelo.'
                Write-Host 'PRUEBE: imprima pagina de calidad interna, confirme tipo/tamano de papel y revise niveles. Use limpieza/alineacion solo desde el menu o utilidad oficial del fabricante.'
                Write-Host 'INTERPRETACION: si el defecto tambien aparece en la pagina interna, probablemente esta en consumible o mecanismo; conserve una muestra y revise servicio del modelo. No abra zonas calientes de una laser.'
            }
            'Impresora:3' {
                Write-Host 'POSIBLES CAUSAS: papel humedo, mal cargado, guias apretadas, objeto/fragmento atascado o mecanismo de toma.'
                Write-Host 'PRUEBE: cancele el trabajo desde la pantalla, apague segun el manual y retire papel accesible en el sentido indicado. No tire con fuerza ni introduzca herramientas.'
                Write-Host 'INTERPRETACION: atascos repetidos en el mismo punto pueden indicar rodillos o sensor; documente ubicacion y codigo y escale a servicio.'
            }
            'Monitor:1' {
                Write-Host 'POSIBLES CAUSAS: cable/conector, puerto/adaptador, interferencia o panel del monitor; tambien puede ser la salida grafica.'
                Write-Host 'PRUEBE: abra el menu OSD del monitor; reconecte el cable; pruebe otro cable/puerto y, si es posible, otra pantalla o equipo. Compare si las lineas aparecen en el OSD y en la imagen de otro dispositivo.'
                Write-Host 'INTERPRETACION: lineas en el OSD o con varias fuentes apuntan al monitor; si solo ocurren con un PC/puerto, revise salida grafica, adaptador o controlador. No presione el panel.'
            }
            'Monitor:2' {
                Write-Host 'POSIBLES CAUSAS: monitor sin energia/entrada incorrecta, cable, modo de proyeccion o equipo que no completa POST.'
                Write-Host 'PRUEBE: indicador y entrada OSD; cable en ambos extremos; seleccione Windows+P y pruebe la pantalla correcta. Pruebe otra pantalla/cable conocido.'
                Write-Host 'INTERPRETACION: si tampoco aparece logo/BIOS, no empiece por reparar Windows; clasifique como no-video o no-POST segun luces y actividad.'
            }
            'Monitor:3' {
                Write-Host 'POSIBLES CAUSAS: cable/puerto, frecuencia o resolucion incompatible, controlador o panel.'
                Write-Host 'PRUEBE: otro cable/puerto; restaure frecuencia recomendada por Windows y la especificacion del monitor; compare con otra pantalla. En Administrador de tareas, observe si tambien parpadea.'
                Write-Host 'INTERPRETACION: si solo parpadea una aplicacion, revise esa aplicacion; si afecta todo Windows, contraste controlador y pantalla. No instale controladores de terceros.'
            }
            'Teclado:1' {
                Write-Host 'POSIBLES CAUSAS: puerto/cable/receptor, bateria, tecla trabada, configuracion de accesibilidad o falla del teclado.'
                Write-Host 'PRUEBE: conexion USB directa y otro puerto; en inalambrico, bateria y receptor; use osk.exe y pruebe el teclado en otra aplicacion/equipo.'
                Write-Host 'INTERPRETACION: si falla tambien en otro equipo, probable teclado; si el teclado en pantalla funciona, revise conexion/configuracion. Si hubo liquido, desconecte y no lo vuelva a energizar.'
            }
            'Teclado:2' {
                Write-Host 'POSIBLES CAUSAS: idioma/distribucion, Bloq Num, tecla atascada, repeticion configurada o teclado defectuoso.'
                Write-Host 'PRUEBE: revise idioma de entrada y Bloq Num; escriba en otra aplicacion; pruebe teclado en pantalla y otro teclado.'
                Write-Host 'INTERPRETACION: si otro teclado escribe bien, revise el dispositivo original; si ambos producen el mismo simbolo, revise distribucion/configuracion de Windows.'
            }
            'Teclado:3' {
                Write-Host 'POSIBLES CAUSAS: bateria baja, fuera de alcance, emparejamiento perdido o interferencia.'
                Write-Host 'PRUEBE: cargue/cambie bateria, acerque el dispositivo, reconecte receptor USB y confirme modo de emparejamiento. En Bluetooth, revise Configuracion > Bluetooth y dispositivos.'
                Write-Host 'INTERPRETACION: si otros accesorios Bluetooth tambien fallan, revise Bluetooth del PC; si solo falla este teclado, compare en otro equipo.'
            }
            'Mouse:1' {
                Write-Host 'POSIBLES CAUSAS: superficie/sensor, cable/puerto, bateria, receptor o panel tactil deshabilitado.'
                Write-Host 'PRUEBE: superficie mate y limpia; USB directo a otro puerto; bateria/receptor; compare con otro mouse o el panel tactil.'
                Write-Host 'INTERPRETACION: si falla en otro equipo, probable mouse; si varios dispositivos fallan en el mismo puerto, revise puerto/PC.'
            }
            'Mouse:2' {
                Write-Host 'POSIBLES CAUSAS: suciedad/desgaste de botones o rueda, configuracion, aplicacion o controlador.'
                Write-Host 'PRUEBE: compare clic izquierdo/derecho y rueda en varias aplicaciones; revise configuracion de botones/velocidad; pruebe otro mouse.'
                Write-Host 'INTERPRETACION: si falla solo en una aplicacion, revise esa aplicacion; si el problema sigue al mouse en otro PC, probable falla fisica.'
            }
            'Mouse:3' {
                Write-Host 'POSIBLES CAUSAS: bateria, alcance, receptor desconectado, emparejamiento o interferencia.'
                Write-Host 'PRUEBE: cambie/cargue bateria, acerque el mouse y reconecte el receptor. En Bluetooth, confirme que este emparejado y conectado en Configuracion.'
                Write-Host 'INTERPRETACION: pruebe otro puerto/receptor o equipo antes de cambiar controladores. Microsoft recomienda comprobar energia, alcance y emparejamiento en fallas Bluetooth.'
            }
            default { Write-Warn 'Sintoma no valido.' }
        }
        Write-Linea -c '-' -col DarkCyan
        Write-Pausar
    }
}

function Show-CoreHardwareSubmenu {
    while ($true) {
        Clear-Host
        Write-Titulo 'FUENTE DE PODER, CABLEADO Y MEMORIA RAM' -col Cyan
        Write-Host '  1. No enciende, se apaga o reinicia (fuente/adaptador)'
        Write-Host '  2. Ethernet sin conexion o intermitente (cable de red)'
        Write-Host '  3. Reinicios, errores o no completa POST (memoria RAM)'
        Write-Host '  4. Registrar caso en una ficha local'
        Write-Host '  0. Volver al menu principal'
        Write-Host ''
        $seleccion = (Read-Host 'Seleccione una opcion').Trim()
        if ($seleccion -eq '0') { return }
        Write-Linea -c '-' -col DarkCyan

        switch ($seleccion) {
            '1' {
                Write-Titulo 'FUENTE DE PODER / ADAPTADOR' -col Yellow
                Write-Host 'POSIBLES CAUSAS: toma/cable, cargador incompatible o defectuoso, proteccion activada, fuente, placa u otro componente. El sintoma por si solo no identifica la pieza.'
                Write-Host 'PRUEBE: confirme una toma funcional y conexiones externas; revise danos visibles, olor a quemado o ruido anormal. Desconecte y escale si hay olor, humo, chispas o liquido.'
                Write-Host 'PRUEBA DEL FABRICANTE: algunos Dell de escritorio tienen BIST en la fuente. Use solo el boton y procedimiento descritos para el modelo exacto; no todos lo incluyen.'
                Write-Warn 'Nunca abra una fuente de poder ni haga pruebas con clips/cables. La reparacion interna corresponde a personal calificado.'
                Start-Process 'https://www.dell.com/support/kbdoc/en-us/000125185/how-to-troubleshoot-the-power-supply-unit-psu-of-a-dell-desktop-computer' -ErrorAction SilentlyContinue
            }
            '2' {
                Write-Titulo 'CABLEADO ETHERNET' -col Yellow
                Write-Host 'POSIBLES CAUSAS: cable/clip, puerto del PC o switch, adaptador deshabilitado, VLAN/autenticacion o servicio de red.'
                Write-Host 'PRUEBE: asiente ambos conectores; revise danos y luces de enlace; compare con un cable conocido y otro puerto autorizado. Una luz de enlace confirma enlace fisico, no acceso a Internet.'
                Write-Host 'AISLAMIENTO: si el mismo cable/puerto funciona con otro equipo, revise adaptador/configuracion del PC; si varios equipos fallan, escale puerto, VLAN o red.'
                Write-Host 'CONSULTA DE SOLO LECTURA en PowerShell:' -ForegroundColor Cyan
                Write-Host '  Get-NetAdapter -Physical | Format-Table Name, Status, LinkSpeed -AutoSize'
                Write-Host '  ipconfig /all'
                Start-Process 'ms-settings:network-ethernet' -ErrorAction SilentlyContinue
                Start-Process 'https://support.microsoft.com/es-es/windows/experience/connectivity-networking/fix-ethernet-connection-problems-in-windows' -ErrorAction SilentlyContinue
            }
            '3' {
                Write-Titulo 'MEMORIA RAM' -col Yellow
                Write-Host 'SINTOMAS POSIBLES: errores de memoria/POST, pantallazos azules, bloqueos o reinicios. Tambien pueden deberse a otros componentes o controladores.'
                Write-Host 'PRUEBE SI WINDOWS INICIA: guarde el trabajo y ejecute mdsched.exe; la prueba solicita reiniciar. Registre el resultado y el codigo exacto del error.'
                Write-Host 'SI WINDOWS NO INICIA: use el diagnostico UEFI del fabricante si el modelo lo ofrece (en algunos HP: Esc y luego F2 al encender).'
                Write-Warn 'No retire ni cambie modulos con el equipo conectado. La manipulacion fisica requiere manual del modelo, desconexion total y precauciones ESD; escale si no esta autorizado.'
                Start-Process 'https://support.hp.com/ca-en/document/ish_2854458-2733239-16' -ErrorAction SilentlyContinue
            }
            '4' {
                $tipoHardware = Read-Host 'Componente (fuente/adaptador/cable Ethernet/RAM)'
                $marcaHardware = Read-Host 'Fabricante del equipo/componente (opcional)'
                $modeloHardware = Read-Host 'Modelo exacto (opcional; no ingrese numero de serie)'
                $sintomaHardware = Read-Host 'Sintoma, luces o codigo de error'
                $pruebasHardware = Read-Host 'Pruebas realizadas y resultados'
                $carpetaCasos = 'C:\AuditoriaRed\CasosHardwareRed'
                New-Item -ItemType Directory -Path $carpetaCasos -Force | Out-Null
                $archivoCaso = Join-Path $carpetaCasos ("Caso-hardware-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
                @(
                    'FICHA DE ORIENTACION DE HARDWARE Y RED'
                    ('Fecha: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
                    ('Componente: {0}' -f $tipoHardware)
                    ('Fabricante: {0}' -f $marcaHardware)
                    ('Modelo: {0}' -f $modeloHardware)
                    ('Sintoma/codigo: {0}' -f $sintomaHardware)
                    ('Pruebas y resultados: {0}' -f $pruebasHardware)
                    'Nota: los sintomas orientan; confirme con pruebas del fabricante antes de reemplazar componentes.'
                ) | Out-File -LiteralPath $archivoCaso -Encoding UTF8
                Write-Ok "Ficha guardada en $archivoCaso"
            }
            default { Write-Warn 'Opcion no valida.' }
        }
        Write-Linea -c '-' -col DarkCyan
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
    '14' = @{ Icon = '[14]'; Label = 'Orientacion de perifericos'; Desc = '(Impresoras, monitores, teclados y mouse)'; Params = $null }
    '15' = @{ Icon = '[15]'; Label = 'Fuente, memoria y cableado'; Desc = '(Fuente de poder, RAM y Ethernet)'; Params = $null }
}

$categorias = [ordered]@{
    'MANTENIMIENTO PREVENTIVO' = @('1', '2', '3', '4', '12')
    'MANTENIMIENTO CORRECTIVO' = @('5', '6', '7')
    'AUDITORIA Y REVISION' = @('8', '9', '10', '11')
    'ARRANQUE Y DIAGNOSTICO DE HARDWARE' = @('13')
    'PERIFERICOS' = @('14')
    'ENERGIA, MEMORIA Y RED' = @('15')
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
        if ($opc -eq '14') {
            Show-PeripheralSubmenu
            continue
        }
        if ($opc -eq '15') {
            Show-CoreHardwareSubmenu
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
        Write-Warn ('"{0}" no es una opcion valida. Ingrese un numero del 1 al 15, o 0 para salir.' -f $opc)
        Write-Pausar
    }
}
