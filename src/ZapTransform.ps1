$XslPath = "/tmp/nunit/ZapTransformTemplate.xslt"
$XmlInputPath = "/tmp/report/Report.xml"
$XmlOutputPath = "/tmp/report/Converted-OWASP-ZAP-Report.xml"

$XslTransform = New-Object System.Xml.Xsl.XslCompiledTransform

$XslTransform.Load($XslPath)
$XslTransform.Transform($XmlInputPath,$XmlOutputPath)