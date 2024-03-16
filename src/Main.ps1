#Clear Screen
cls


##Returns List with top 20 process
function getPCProcess() {
    $amount = 20;
    $process = Get-Process | Select-Object Name, CPU -First $amount | Sort-Object CPU -Descending;

    
    ##Get Sum of cpu process
    $totalCpu = ($process | Measure-Object CPU -Sum).Sum;


    [string] $output = "`nTotal CPU: " + $totalCpu + "`n";

    write-host "`n########## PC-Prozesse ##########";
    write-host $output -ForegroundColor Red;

    return $process;
}


##Returns List with top 20 services 
function getPCService() {
    $amount = 20;

    $service = Get-Service | Select-Object Name, Status -First $amount | Sort-Object Status -Descending;
    

    return $service;
}

##Returns List with all files and folders of given Path
function getFolderContent([string] $path) {
    $content = get-childitem -Path $path | Select-Object Name, Mode, Length, Extension, CreationTime, FullName;

    
    foreach($i in $content) {
        [string] $fileType = "";

        ###Get Type
        if ($i.Mode -like "d-----") {
            $fileType = "Directory";
        } else {
            $fileType = "File";
        }

        [string] $output = "Name: " + $i.Name + "`tLength: " + $i.Length + "`tCT: " + $i.CreationTime + "`tPath: " + $i.FullName;                
    }

    return $content;
}


function exportToFile([string]$fileType, [string]$exportPath) {
    $p = getPCProcess;
    $s = getPCService;

    $fullPathP = $exportpath + "Prozesse." + $fileType;
    $fullPathS = $exportpath + "Dienste." + $fileType;
    
    switch($fileType) {
        "HTML" {
            $p | convertto-html > $fullPathP;
            $s | convertto-html > $fullPathS;
            write-host "HTML exported";
        }

        "XML" {
            $p | Export-Clixml $fullPathP;
            $s | Export-Clixml $fullPathS;
            write-host "XML exported";

        }

        "CSV" {
            $p | Export-csv $fullPathP;
            $s | Export-csv $fullPathS;
            write-host "CSV exported";

        }

        default {
            write-host "File not supported!";
        }
    }
}

function getComputerInfo() {
    [string] $output = "";

    #Betriebsystem Info
    $os = Get-CimInstance Win32_OperatingSystem;

    ##Betriebssystemname
    $osName = $os.Caption;

    #Betriebsystem Version
    $osVersion = $os.Version;

    #Ram Speicher
    $ram = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb;
   
    # CPU-Informationen abrufen
    $cpuInfo = (Get-WmiObject Win32_Processor).Name;

     ##Datum
    $date = (get-date).ToString("yyyy-MM-dd");

    # CPU-Name anzeigen
    $output = "Betriebsystem: " + $osName + "`nVersion: " + $osVersion + "`nArbeitsspeicher: " + $ram + "Gb`nProzesser(CPU): " + $cpuInfo + "`nDatum: " + $date;

   

    Start-Sleep -Seconds 2

    return $output | Out-String;
}