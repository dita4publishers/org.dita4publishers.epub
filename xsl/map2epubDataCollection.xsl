<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:df="http://dita2indesign.org/dita/functions" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:relpath="http://dita2indesign/functions/relpath" 
  xmlns:glossdata="http://dita4publishers.org/glossdata"
  xmlns:applicability="http://dita4publishers.org/applicability" 
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  xmlns:local="urn:functions:local" 
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:date="java:java.util.Date"
  xmlns:enum="http://dita4publishers.org/enumerables" 
  expand-text="true"
  exclude-result-prefixes="local xs df xsl relpath glossdata date">
  <!-- ===================================================================
       Data collection override for EPUB processing
       
       Includes image references in the collected data so we can then
       copy them into the EPUB.
    
    -->
  
  <xsl:template mode="construct-enumerable-structure" match="*[contains-token(@class, 'topic/image')]">
    <xsl:call-template name="construct-enumerated-element">
      <xsl:with-param name="additional-attributes" as="attribute()*">
        <xsl:sequence select="@*"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>