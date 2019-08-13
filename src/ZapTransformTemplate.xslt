<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" version="2.0" exclude-result-prefixes="msxsl">
   
  <xsl:output method="xml" indent="yes" />
   
   <xsl:variable name="NumberOfItems" select="count(OWASPZAPReport/site/alerts/alertitem)" />
   <xsl:variable name="generatedDateTime" select="OWASPZAPReport/generated" />
   
   <xsl:template match="/">
   <test-run id="1" name="OWASP Zap Report" fullname="OWASP Zap Report" testcasecount="{$NumberOfItems}" result="Failed" total="{$NumberOfItems}" passed="0" failed="{$NumberOfItems}" inconclusive="0" skipped="0" asserts="{$NumberOfItems}" engine-version="" clr-version="" start-time="{$generatedDateTime}" end-time="{$generatedDateTime}" duration="0">
         
	 <command-line>a</command-line>
         
	 <test-suite type="Assembly" id="" name="OWASP-Assembly" fullname="OWASP-Assembly" runstate="Runnable" testcasecount="{$NumberOfItems}" result="Failed" site="Child" start-time="{$generatedDateTime}" end-time="{$generatedDateTime}" duration="0" total="{$NumberOfItems}" passed="0" failed="{$NumberOfItems}" warnings="0" inconclusive="0" skipped="0" asserts="{$NumberOfItems}">
   <environment machine-name="OWASP Zap Scan" />
	    <test-suite type="TestSuite" id="" name="OWASP-TestSuite" fullname="OWASP-TestSuite" runstate="Runnable" testcasecount="1" result="Failed" site="Child" start-time="{$generatedDateTime}" end-time="{$generatedDateTime}" duration="0" total="1" passed="0" failed="1" warnings="0" inconclusive="0" skipped="0" asserts="1">
           
               <test-suite type="TestFixture" id="" name="OWASP-TestFixture" fullname="OWASP-TestFixture" classname="OWASP-TestFixture" runstate="Runnable" testcasecount="1" result="Failed" site="Child" start-time="{$generatedDateTime}" end-time="{$generatedDateTime}" duration="0" total="1" passed="0" failed="1" warnings="0" inconclusive="0" skipped="0" asserts="1">
                     <xsl:for-each select="OWASPZAPReport/site/alerts/alertitem">
                     <xsl:variable name="AlertName" select="name" />
                     <xsl:variable name="RiskLevel" select="riskdesc" />
                     <xsl:variable name="Description" select="desc" />
                     <xsl:variable name="Solution" select="solution" />
                     <xsl:variable name="OtherInfo" select="otherinfo" />
                     <xsl:variable name="Reference" select="reference" />
			  
                     <xsl:for-each select="instances/instance">
                        <test-case id="" name="{$AlertName}: {method} - {uri}" fullname="{$AlertName}: {method} - {uri}" methodname="OWASP-Zap-Test" classname="" runstate="" seed="" result="Failed" label="Error" start-time="{$generatedDateTime}" end-time="{$generatedDateTime}" duration="0" asserts="">
                           <failure>
                              <message>
RISK LEVEL:
<xsl:value-of select="$RiskLevel" />
                                
Description:
<xsl:value-of select="$Description" />
				 
Solution:
<xsl:value-of select="$Solution" /> 
				 
Evidence:
<xsl:value-of select="evidence" />
				      
                              </message>
                              
                              <stack-trace>
Other Info (if available):
<xsl:value-of select="$OtherInfo" />
                                 
Reference/s (if available):
<xsl:value-of select="$Reference" />
                              </stack-trace>
				   
                           </failure>
                        </test-case>
                     </xsl:for-each>
                  </xsl:for-each>
               </test-suite>
            </test-suite>
         </test-suite>
      </test-run>
   </xsl:template>
</xsl:stylesheet>
