$ErrorActionPreference = "Stop"

#Create array with all password symbols
$generatepw = @()            
$generatepw += [char[]]([char]65..[char]90) # Grossbuchstaben            
$generatepw += [char[]]([char]97..[char]122) # Kleinbuchstaben            
$generatepw += 0..9 # Zahlen            
$generatepw += "?","!", "$" ,"%", "+", "-", "*", ">", "<" # Sonderzeichen

$pwlength = 10 #Default password length
$ykmanpath = 'C:\Program Files\Yubico\YubiKey Manager\ykman.exe' #Pfad zum ykman.exe

$prompt = Read-Host "Gewuenschte Passwortlaenge eingeben (Standart ist $pwlength)"
if ($prompt -eq "") {} else { $pwlength = $prompt }

$prompt = Read-Host "Pfad zum ykman.exe eingeben (Standart ist $ykmanpath)"
if ($prompt -eq "") {} else { $ykmanpath = $prompt }
$ykmanpath = $ykmanpath.Trim('"')

Write-Host "Bitte YubiKey verbinden"
Pause

while (1) 
{
    $password =  (Get-Random -InputObject $generatepw -Count $pwlength) -join "" #Generiert das Passwort
    
    Write-Host "Seriennummer des Keys:"
    & "$ykmanpath" "list" "--serials" #Seriennummer ausgeben

    & "$ykmanpath" "otp" "static" "-f" "--keyboard-layout" "DE" "--no-enter" "1" "$password" #Kurzes drücken
    & "$ykmanpath" "otp" "static" "-f" "--keyboard-layout" "DE" "--no-enter" "2" "$password" #langes drücken
    
    Write-Host "Folgendes Passwort wurde generiert und in beide Slots geschrieben:"
    Write-Host $password

    $title    = ""
    $question = "Soll noch ein YubiKey eingerichtet werden?"
    $Choices = @(
        [System.Management.Automation.Host.ChoiceDescription]::new("&Ja", "Noch einen Key einrichten")
        [System.Management.Automation.Host.ChoiceDescription]::new("&Nein", "Nein, das Programm beenden")
    )
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1) 
    if($decision -eq 1)
    {
        Exit
    }
    Write-Host "Bitte konfigurierten YubiKey entfernen, und neuen YubiKey verbinden"
    Pause
}