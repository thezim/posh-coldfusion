function Encrypt-Text {
    param(
        [string]$Text,
        [string]$Seed,
        [int]$BlockSize=128,
        [int]$KeySize=128
    )
    
    # get key btes
    $keybytes = [System.Text.Encoding]::UTF8.GetBytes($Seed)
    
    # encrypt data
    $aes = New-Object System.Security.Cryptography.RijndaelManaged
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.BlockSize = $BlockSize
    $aes.KeySize = $KeySize
    $aes.Key = $keybytes
    $aes.GenerateIV()
    $encryptor = $aes.CreateEncryptor()
    $ms = New-Object System.IO.MemoryStream
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $encryptor, "Write")
    $sw = New-Object System.IO.StreamWriter($cs)
    $sw.Write($Text)
    $sw.Close()
    $enc = $ms.ToArray()

    # generate base64 IV + cipher text
    $bytes = New-Object byte[] ($aes.IV.Count + $enc.Count)
    [Array]::Copy($aes.IV, 0, $bytes, 0, $aes.IV.Count)
    [Array]::Copy($enc, 0, $bytes, $aes.IV.Count, $enc.Count)
    [Convert]::ToBase64String($bytes)
}

function Decrypt-CipherText {
    param(
        [string]$Base64,
        [string]$Seed,
        [int]$BlockSize=128,
        [int]$KeySize=128
    )

    # convert to bytes
    $keybytes = [System.Text.Encoding]::UTF8.GetBytes($Seed)
    $encbytes =  [Convert]::FromBase64String($Base64)

    $size = $BlockSize / 8

    # get IV
    $iv = New-Object byte[] $size
    [Array]::Copy($encbytes, $iv, $size)

    # get cipher text
    $enclen = $encbytes.Length - $size
    $enc = New-Object byte[] $enclen
    [Array]::Copy($encbytes, $size, $enc, 0, $enclen)

    # decrypt
    $aes = New-Object System.Security.Cryptography.RijndaelManaged
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.BlockSize = $BlockSize
    $aes.KeySize = $KeySize
    $aes.Key = $keybytes
    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor()
    $ms = New-Object System.IO.MemoryStream -ArgumentList @(,$enc)
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, "Read")
    $sr = New-Object System.IO.StreamReader($cs)
    $sr.ReadToEnd()
}