$7z = "C:\Program Files\7-Zip\7z"

dotnet publish -c Release Doubleclicker/Doubleclicker.csproj

cp Doubleclicker/bin/Release/net7.0/win-x64/publish/Doubleclicker.exe .

php generateChecksum.php > checksum.as
& $7z a -tzip tm-doubleclicker.op *.as info.toml Doubleclicker.exe regTpl.reg
