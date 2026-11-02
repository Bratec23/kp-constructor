$ErrorActionPreference = 'SilentlyContinue'
Set-Location -LiteralPath $PSScriptRoot
$Host.UI.RawUI.WindowTitle = 'Конструктор КП - Первый Бит'

Write-Host '============================================' -ForegroundColor Magenta
Write-Host '  Конструктор КП - Первый Бит' -ForegroundColor White
Write-Host '============================================' -ForegroundColor Magenta
Write-Host ''

# --- Ищем npm ---
$npm = (Get-Command npm -ErrorAction SilentlyContinue).Source
if (-not $npm) {
  $kimiNpm = "$env:LOCALAPPDATA\Programs\kimi-desktop\resources\resources\runtime\npm.cmd"
  if (Test-Path $kimiNpm) { $npm = $kimiNpm }
}
if (-not $npm) {
  Write-Host '[ОШИБКА] Node.js не найден на этом компьютере.' -ForegroundColor Red
  Write-Host ''
  Write-Host 'Что делать:'
  Write-Host '  Вариант 1 - откройте файл Конструктор-КП.html двойным кликом.'
  Write-Host '              Он работает без установки программ.'
  Write-Host '  Вариант 2 - установите Node.js с https://nodejs.org'
  Write-Host '              и запустите этот файл снова.'
  Write-Host ''
  Read-Host 'Нажмите Enter для выхода'
  exit 1
}

function Test-ServerUp {
  try {
    $c = New-Object System.Net.Sockets.TcpClient
    $c.Connect('127.0.0.1', 3000)
    $c.Close()
    return $true
  } catch { return $false }
}

if (Test-ServerUp) {
  Write-Host 'Сервер уже запущен. Открываю браузер...' -ForegroundColor Green
  Start-Process 'http://localhost:3000'
  exit 0
}

Write-Host 'Запускаю сервер, подождите...' -ForegroundColor Yellow
Start-Process -WindowStyle Minimized -FilePath 'cmd.exe' -ArgumentList '/c', "`"$npm`" run dev -- --port 3000 --strictPort" -WorkingDirectory $PSScriptRoot

$ok = $false
for ($i = 0; $i -lt 90; $i++) {
  Start-Sleep -Seconds 2
  if (Test-ServerUp) { $ok = $true; break }
}

if (-not $ok) {
  Write-Host '[ОШИБКА] Сервер не запустился за 3 минуты.' -ForegroundColor Red
  Write-Host 'Попробуйте файл Конструктор-КП.html - он работает без сервера.'
  Read-Host 'Нажмите Enter для выхода'
  exit 1
}

Write-Host 'Сервер готов. Открываю браузер...' -ForegroundColor Green
Start-Process 'http://localhost:3000'
Write-Host ''
Write-Host 'Приложение работает: http://localhost:3000'
Write-Host 'Чтобы остановить - закройте свернутое окно cmd на панели задач.'
Write-Host ''
Read-Host 'Нажмите Enter, чтобы закрыть это окно (сервер продолжит работать)'
