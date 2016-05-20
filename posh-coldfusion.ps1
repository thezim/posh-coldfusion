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
Decrypt-CipherText -Seed $seed -Base64 $ciphertext