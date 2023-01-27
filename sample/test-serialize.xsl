<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math"
                xmlns:ext="xpath.result.to.json"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:import href="../src/xpath-result-serializer.xsl"/>
  
  <xsl:template match="/*" mode="#all">
    <xsl:variable name="children" as="element()*" select="*"/>
    <xsl:variable name="id" as="xs:integer" select="1789"/>
    <xsl:copy>
      <xsl:variable name="val" as="map(*)" 
        select="map {
            'start': map {
              $id: $children
            },
            'end' : 'paris &amp; london',
            'date': current-date()
          }"/>
      <xsl:message select="ext:serializeXPathResult($val)"/>
      <result>
        <xsl:sequence select="ext:buildResultTree($val)"/> 
      </result>
    </xsl:copy>
  </xsl:template>
  
  
  
</xsl:stylesheet>