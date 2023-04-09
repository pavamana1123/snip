function getSnipSeconds($t) {
   $tp=$($t -replace "s","").split("m")
   echo $($($([int]$($tp[0]))*60)+($tp[1]))
}

function getRandomFile($dir) {
    echo $(Get-ChildItem $dir -File | get-random).fullname
}

function getBetweenClause($s, $e) {
    $ss=$s.split(",")
    $es=$e.split(",")


    $bw=""

    for ($i=0; $i -lt $ss.Count; $i++) {
        $bw="$bw+between(t,$(getSnipSeconds $ss[$i]),$(getSnipSeconds $es[$i]))"
    }

    echo $($bw.Trim("+"))
}

function getSnipDuration($s,$e){
    $($([int]$(getSnipSeconds $e))-$([int]$(getSnipSeconds $s)))
}

function next(){
    mv -Force -ErrorAction SilentlyContinue "./snippets/out.mp4" "./snippets/in.mp4"
}

function nexti(){
    mv -Force -ErrorAction SilentlyContinue "./snippets/outi.mp4" "./snippets/ini.mp4"
}