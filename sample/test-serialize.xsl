<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math"
                xmlns:ext="com.deltaxml.xpath.result.print"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:import href="../src/xpath-result-serializer.xsl"/>
  <xsl:template match="/*" mode="#all">
    
    <xsl:copy>
      <xsl:variable name="text" as="xs:string" select="unparsed-text('data.json')"/>
      <xsl:variable name="jsonObject" as="map(*)" select="parse-json($text)"/>
      <xsl:variable name="langItems" as="array(*)" select="$jsonObject?languages"/>
      
      <xsl:message expand-text="yes">
        ==== Root element ====
        languages-count:  {array:size($langItems) => ext:println()}
      </xsl:message>
      <xsl:variable name="itemSequence" as="map(*)*" 
        select="array:flatten($langItems)"/>
      
      <xsl:for-each select="$itemSequence">
        <xsl:message>
          position:       {ext:print(position())}
          remaining:      {ext:print(., 12, '  ')}
        </xsl:message>
      </xsl:for-each>
      
      <!-- <xsl:for-each select="$itemSequence">
           <xsl:message>
           position:       {ext:print(position())}
          id:             {ext:print(?id)}
          aliases:        {ext:print(?aliases) => serialize(map {'method': 'adaptive'})}
          remaining:
          {ext:print(map:remove(., ('aliases', 'id')))}
        </xsl:message>
           </xsl:for-each> -->
      
      <result>
        <xsl:sequence select="ext:buildResultTree(map:remove($itemSequence[1], ('aliases', 'id')))"/> 
      </result>
    </xsl:copy>
    
  </xsl:template>
  
  
  
</xsl:stylesheet>