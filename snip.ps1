. ./def.ps1

echo "Fetching data"
node "./fetch-ready.js"
echo "Data fetched"

$pendingSnippets=(Get-Content './snippet-status.json' | Out-String | ConvertFrom-Json)

foreach ($pendingSnippet in $pendingSnippets) {

    # Preparing Intro
    $bgi = getRandomFile ./bgi

    magick convert $bgi -pointsize 36 -font "Arial" -size 800x -gravity center -background none -splice 0x100 -fill black -annotate +0+0 $pendingSnippet.title ./bgi/temp.jpg
    magick convert $bgi -gravity center -font Arial -pointsize 150 -size 600x -fill white -background none -bordercolor black -border 0 -density 72 caption:$pendingSnippet.title -composite ./bgi/temp.jpg
    echo "Background image prepared!"

    $ibgm = GetRandomFile ./ibgm

    ffmpeg -loop 1 -i ./bgi/temp.jpg -i $ibgm -c:v libx264 -c:a copy -shortest ./snippets/outi.mp4; nexti

    echo "Adding fade effect to intro of $($pendingSnippet.id)"
    ffmpeg -loglevel panic -y -i "./snippets/ini.mp4" -filter_complex `
        "[0:v]fade=type=in:duration=1,fade=type=out:duration=1:start_time=$($duration-1)[v];
         [0:a]afade=type=in:duration=1,afade=type=out:duration=1:start_time=$($duration-1)[a]" -map "[v]" -map "[a]" `
        "./snippets/outi.mp4"; nexti
    echo "Added fade effect to intro of $($pendingSnippet.id)"

    $duration = [int]$(getSnipDuration $pendingSnippet.start $pendingSnippet.end)

    yt-dlp -f best $pendingSnippet.link -o "./videos/$($pendingSnippet.verse).mp4"
    
    echo "Trimming video $($pendingSnippet.id)"
    ffmpeg -loglevel panic -y -i "./videos/$($pendingSnippet.verse).mp4" `
       -vf "select='$(getBetweenClause $pendingSnippet.start $pendingSnippet.end)',setpts=N/FRAME_RATE/TB" `
       -af "aselect='$(getBetweenClause $pendingSnippet.start $pendingSnippet.end)',asetpts=N/SR/TB" `
    "./snippets/out.mp4"; next
    echo "Trimmed video $($pendingSnippet.id)"

    echo "Adding bgm to $($pendingSnippet.id)"
    ffmpeg -loglevel panic -y -i "./bgm/$(Get-ChildItem ./bgm -name | Select-Object -index $(Random $((Get-ChildItem ./bgm).Count)))" -i "./snippets/in.mp4" -filter_complex `
        "[0:a][1:a]amerge,pan=stereo|c0<c0+c2|c1<c1+c3[a]" `
        -map 1:v -map "[a]" -c:v copy -c:a aac -shortest "./snippets/out.mp4"; next
    echo "Added bgm to $($pendingSnippet.id)"

    if($($pendingSnippet.hasLogo) -eq $false){
        echo "Adding logo to $($pendingSnippet.id)"
        ffmpeg -loglevel panic -y -i "./snippets/in.mp4" -i logo.png `
        -filter_complex "overlay=0:0" -c:a copy "./snippets/out.mp4"; next
        echo "Added logo to $($pendingSnippet.id)"
    }

    echo "Adding fade effect to $($pendingSnippet.id)"
    ffmpeg -loglevel panic -y -i "./snippets/in.mp4" -filter_complex `
        "[0:v]fade=type=in:duration=1,fade=type=out:duration=1:start_time=$($duration-1)[v];
         [0:a]afade=type=in:duration=1,afade=type=out:duration=1:start_time=$($duration-1)[a]" -map "[v]" -map "[a]" `
        "./snippets/out.mp4"; next
    echo "Added fade effect to $($pendingSnippet.id)"
    
    ffmpeg -i ./snippets/ini.mp4 -i "./snippets/in.mp4" -filter_complex "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1" -c:v libx264 -c:a aac out.mp4; next

    mv -Force "./snippets/in.mp4" "./snippets/$($pendingSnippet.id).mp4"
}
