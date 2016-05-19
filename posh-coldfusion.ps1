$seed = "4E1C4C42AC14152C"
$enc = "60OO4KORzVHnJ5TGgye0YvWqKmZ1hH5NYjFaEYSrrq9DHu4i7/3+8WWcDCiqORGf"

$keybytes = [System.Text.Encoding]::UTF8.GetBytes($seed)
$encbytes =  [Convert]::FromBase64String($enc)

$algorithm = New-Object System.Security.Cryptography.RijndaelManaged
$algorithm.Mode = [System.Security.Cryptography.CipherMode]::CBC
$algorithm.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
$algorithm.BlockSize = 128
$algorithm.KeySize = 128
$algorithm.Key = $keybytes
$decryptor = $algorithm.CreateDecryptor()
$ms = New-Object System.IO.MemoryStream -ArgumentList @(,$encbytes)
$cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, "Read")
$sr = New-Object System.IO.StreamReader($cs)
$sr.ReadToEnd()