﻿function Get-SeedInfo {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    $lines = Get-Content -Path "C:\Users\Greg\Desktop\seed.properties"
    New-Object PSObject -Property @{
    Seed = ($lines |
        Where-Object { $_.StartsWith("seed") }) -split "=" | Select-Object -Last 1
    Algorithm = ($lines |
        Where-Object { $_.StartsWith("algorithm") }) -split "=" | Select-Object -Last 1
    }
}

function Get-DataSources {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    $content = Get-Content -Raw -Path $Path
    $xdoc = New-Object System.Xml.XmlDocument
    $xdoc.LoadXml($content)
    $list = $xdoc.SelectNodes("//struct[var[@name='CLASS']]")
    $data = @()
    foreach($ds in $list){
        $data += New-Object PSObject -Property @{
            Name = $ds.ParentNode.name
            Username = ($ds.OuterXml | Select-Xml "/struct/var[@name='username']/string").Node.'#text'
            Driver = ($ds.OuterXml | Select-Xml "/struct/var[@name='DRIVER']/string").Node.'#text'
            Password =  ($ds.OuterXml | Select-Xml "/struct/var[@name='password']/string").Node.'#text'
            Host = ($ds.OuterXml | Select-Xml -XPath "/struct/var[@name='urlmap']/struct/var[@name='host']/string").Node.'#text'
            Port = ($ds.OuterXml | Select-Xml "/struct/var[@name='urlmap']/struct/var[@name='port']/string").Node.'#text'
            Database = ($ds.OuterXml | Select-Xml "/struct/var[@name='urlmap']/struct/var[@name='database']/string").Node.'#text'
            DatabaseFile = ($ds.OuterXml | Select-Xml "/struct/var[@name='urlmap']/struct/var[@name='databaseFile']/string").Node.'#text'
            SID = ($ds.OuterXml | Select-Xml "/struct/var[@name='urlmap']/struct/var[@name='SID']/string").Node.'#text'
            Url = ($ds.OuterXml | Select-Xml "/struct/var[@name='url']/string").Node.'#text'
        }
    }
    $data
}

function Encrypt-Text {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
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

function Decrypt-Text {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Base64,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
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
Export-ModuleMember -Function Encrypt-Text, Decrypt-Text, Get-DataSources, Get-SeedInfo