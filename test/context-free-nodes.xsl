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
  
  <ext:data-island name="test"/>
  <ext:content name="test">some content</ext:content>
  <!-- test comment -->
  <?pi href="abcd"?>
  
  <xsl:template match="/*" mode="#all">
    <xsl:variable name="text" as="xs:string" select="unparsed-text('../sample/data.json')"/>
    <xsl:variable name="jsonObject" as="map(*)" select="parse-json($text)"/>
    <xsl:variable name="langItemsInit" as="array(*)" select="$jsonObject?languages"/>
    <xsl:variable name="langItems" as="array(*)" select="array:append($langItemsInit, (1111,2222,3333, .))"/>
    <xsl:variable name="newElement" as="element()" select="ext:newElement()"/>
    <xsl:variable name="newAttribute" as="attribute()" select="ext:newAttribute()"/>
    <xsl:variable name="newText" as="text()" select="ext:newText()"/>
    <xsl:variable name="newComment" as="comment()" select="ext:newComment()"/>
    <xsl:variable name="newPI" as="processing-instruction()" select="ext:newProcessingInstruction()"/>
    
    <xsl:message expand-text="yes">
      ==== serializing nodes====
      context:      {ext:print(.,10,'  ')}
      element:      {ext:print($newElement,12,'  ')}
      attribute:    {ext:print($newAttribute,12,'  ')}
      newText:      {ext:print($newText,12,'  ')}
      newComment:   {ext:print($newComment,12,'  ')}
      newPI:        {ext:print($newPI,12,'  ')}
      newNamespace: {ext:print(ext:newNamespace())}
      newNamespace2:{ext:print(ext:newNamespace2())}
      newNamespace3:{ext:print(ext:newNamespace3(doc('')/*))}

      ==== serializing maps/arrays/sequences ====
      -- fn:serialize() --
      label 1:  {serialize($langItems(1),map{'method':'adaptive'})}
      label 2:  {serialize($langItems(2),map{'method':'adaptive'})}
      label 3:  {serialize($langItems,map{'method':'adaptive'})}
      
      -- ext:print() --
      label 1:   {ext:print($langItems(1),7,'  ')}
      label 2:   {ext:print($langItems(2),7,'  ')}
      label 300: {ext:print($langItems,7,'  ')}
    </xsl:message>
    
    <result>
      <xsl:sequence select="ext:buildResultTree($langItems)"/> 
    </result>
    
  </xsl:template> 
  
  <xsl:function name="ext:newElement" as="element()">
    <test-element id="1839" class="'back 8'"/>
  </xsl:function>
  
  <xsl:function name="ext:newText" as="text()">
    <xsl:text>The quick brown fox</xsl:text>
  </xsl:function>
  
  <xsl:function name="ext:newComment" as="comment()">
    <xsl:comment select="'A remarkable day'"/>
  </xsl:function>
  
  <xsl:function name="ext:newNamespace" as="namespace-node()">
    <xsl:namespace name="smp" select="'com.sample.namespace'"/>
  </xsl:function>
  
  <xsl:function name="ext:newNamespace2" as="namespace-node()">
    <xsl:namespace name="{''}" select="'com.sample.namespace'"/>
  </xsl:function>
  
  <xsl:function name="ext:newNamespace3" as="namespace-node()">
    <xsl:param name="c.x" as="element()"/>
    <xsl:sequence select="$c.x/namespace::node()[1]"/>
  </xsl:function>
  
  <xsl:function name="ext:newProcessingInstruction" as="processing-instruction()">
    <xsl:processing-instruction name="class" select="'187:198:200'"/>
  </xsl:function>
  
  <xsl:function name="ext:newAttribute" as="attribute()">
    <xsl:attribute name="test-attribute" select="'82-77-187'"/>
  </xsl:function>
</xsl:stylesheet>