# posh-coldfusion

## Description
A PowerShell module for reading/writing Coldfusion data source passwords.

## Motivation
I needed a way to decrypt/encrypt ColdFusion data source passwords offline that did not require Java and could be run remotely. This has only been written for AES-EBC mode encryption mode and tested with Coldfusion 10. Your mileage may vary with other versions.

## Installation

1. Open a PowerShell prompt.
2. Run `git clone https://github.com/thezim/posh-coldfusion`
3. Run `cd posh-coldfusion`
4. Run `install.ps1`

## Usage

Import the PowerShell Module.
``` powershell
Import-Module -Name posh-coldfusion
```
Read data sources from neo-datasource.xml.
```powershell
Get-DataSources -Path neo-datasource.xml
```
Decrypt data source password.
```powershell
# read sources
$ds = Get-DataSources -Path neo-datasource.xml
# get seed info
$seedinfo = Get-SeedInfo -Path seed.properties
# decrypt using seed info
Decrypt-Text -Base64 ($ds[0].Password) -Seed ($seedinfo.Seed)
```
Encrypt new data source password.
```powershell
# get seed info
$seedinfo = Get-SeedInfo -Path seed.properties
# create cypher text
$cipher = Encrypt-Text -Seed ($seedinfo.Seed) -Text "somepassword"
# read data sources xml
$xml = [xml](Get-Content -Raw -Path neo-datasource.xml)
# set the password
Set-DataSourcePassword -Xml $xml -DataSourceName MyDatSourceName -Password $cipher
```
Note that ```Set-DataSourcePassword``` return the modifed XML an does not directly write to the data source file. **It is highly recommeneded that you ensure you backup the data source file before updating it.**

## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request.

## Credits
[Project Contributors](https://github.com/thezim/posh-coldfusion/graphs/contributors)

## Links
There was a really useful page that described the ColdFusion encrption process along with how it it built the ciphertext but alas I can't find it. If you know it or find it drop an issue and I'll add it.

## License
The MIT License (MIT)

Copyright (c) 2015

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.