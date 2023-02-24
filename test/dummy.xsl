<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="/*" mode="#all">
    <xsl:variable name="test" as="xs:string" select="'hello'"/>
    <xsl:message select="ext:print(map {
          'abc': 22,
          'def': [123,252,'abc',['new']]
        })"/>
    <xsl:message expand-text="yes">
      ==== Watch: #all ====
      test:   {ext:print($test,5,'  ')}
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  
</xsl:stylesheet>