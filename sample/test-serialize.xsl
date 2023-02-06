<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:ext="com.deltaxml.xpath.result.print"
                expand-text="yes"
                version="3.0">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:import href="../src/xpath-result-serializer-color.xsl"/>
  
  <xsl:template match="/*" mode="#all">
    <xsl:variable name="text" as="xs:string" select="unparsed-text('data.json')"/>
    <xsl:variable name="jsonObject" as="map(*)" select="parse-json($text)"/>
    <xsl:variable name="langItems" as="array(*)" select="$jsonObject?languages"/>
    <xsl:message expand-text="yes">
      ==== Root element ====
      languages-count:  {node-name() => ext:print(9,'  ')}
      colorNodes:  {ext:print((*,*/@*),9,'  ')}
      
    </xsl:message>
    <xsl:copy>    
      <xsl:message expand-text="yes">
        ==== data====
        context:     {ext:print(.,10,'  ')}
        language:    {ext:print($langItems,10,'  ')}
      </xsl:message>
      
      <result>
        <xsl:sequence select="ext:buildResultTree($langItems)"/> 
      </result>
    </xsl:copy>
    
  </xsl:template> 
</xsl:stylesheet>